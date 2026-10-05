// 一次性诊断脚本：校验指定配置文件，对 oneOf/anyOf 汇总错误展开字段级原因。
// 用法: dart run tool/diagnose_schema.dart <配置文件路径>
import 'dart:convert';
import 'dart:io';

import 'package:json_schema_builder/json_schema_builder.dart';

void main(List<String> args) {
  final configPath = args.isNotEmpty
      ? args.first
      : 'assets/configs/demo_config.json';
  final schemaMap =
      jsonDecode(File('assets/schemas/singbox_schema.json').readAsStringSync())
          as Map<String, dynamic>;
  // 与 SingBoxSchemaValidator.fromMap 一致：剥掉 $schema 保证离线
  schemaMap.remove(r'$schema');
  final config =
      jsonDecode(File(configPath).readAsStringSync()) as Map<String, dynamic>;

  final validator = Schema.fromMap(schemaMap);
  final errors = validator.validateSync(config);

  // 按错误类型汇总
  final byType = <String, int>{};
  for (final e in errors) {
    byType[e.error.name] = (byType[e.error.name] ?? 0) + 1;
  }
  stdout.writeln('共 ${errors.length} 处错误，按类型汇总: $byType\n');

  // 对 oneOf/anyOf 汇总错误做二次诊断
  var diagnosed = 0;
  for (final error in errors) {
    if (error.error != ValidationErrorType.oneOfNotMet &&
        error.error != ValidationErrorType.anyOfNotMet) {
      continue;
    }
    diagnosed++;
    stdout.writeln('--- ${error.toErrorString()}');
    _diagnose(schemaMap, config, error.path);
    stdout.writeln();
  }
  stdout.writeln('（其中 $diagnosed 处为 oneOf/anyOf 汇总错误，已展开诊断）');
}

/// 对单个 oneOf/anyOf 错误：取实例、定位分支、按判别字段复核
void _diagnose(Map<String, dynamic> rootSchema, dynamic config, List<String> path) {
  // 1. 沿 path 取实例值
  dynamic instance = config;
  for (final seg in path) {
    if (instance is List) {
      instance = instance[int.parse(seg)];
    } else if (instance is Map) {
      instance = instance[seg];
    } else {
      stdout.writeln('  ↳ 路径 ${path.join('.')} 无法在配置中取值');
      return;
    }
  }

  // 2. 沿 path 在 schema 上导航取节点（解析 $ref），拿 oneOf/anyOf 分支
  final node = _schemaAt(rootSchema, path);
  if (node == null) {
    stdout.writeln('  ↳ 无法在 schema 中定位该路径的节点');
    return;
  }
  final branches = (node['oneOf'] ?? node['anyOf']) as List?;
  if (branches == null) {
    stdout.writeln('  ↳ 该节点无 oneOf/anyOf 分支');
    return;
  }

  // 3. 实例判别字段 type 与分支 const 匹配
  if (instance is! Map || !instance.containsKey('type')) {
    stdout.writeln('  ↳ 实例缺少 type 判别字段，无法选择分支；实例: '
        '${_brief(instance)}');
    return;
  }
  final typeValue = instance['type'];
  Map<String, dynamic>? matched;
  for (final b in branches) {
    final constValue = ((b as Map)['properties'] as Map?)?['type'];
    if (constValue is Map && constValue['const'] == typeValue) {
      matched = Map<String, dynamic>.from(b);
      break;
    }
  }
  if (matched == null) {
    final supported = branches
        .map((b) => (((b as Map)['properties'] as Map?)?['type'] as Map?)?['const'])
        .whereType<String>()
        .toList();
    stdout.writeln('  ↳ type="$typeValue" 不在本版 schema 支持的类型中'
        '（本版共 ${supported.length} 种）');
    stdout.writeln('     支持的类型: ${supported.join(", ")}');
    return;
  }

  // 4. 用「分支 + 根 $defs/$id 上下文」构建子 schema 单独校验
  final subSchema = <String, dynamic>{
    r'$id': rootSchema[r'$id'],
    r'$defs': rootSchema[r'$defs'],
    ...matched,
  };
  final subErrors = Schema.fromMap(subSchema).validateSync(instance);
  if (subErrors.isEmpty) {
    stdout.writeln('  ↳ type="$typeValue" 分支单独校验通过（异常情况，请人工检查）');
    return;
  }
  stdout.writeln('  ↳ type="$typeValue"，按该分支复核出 ${subErrors.length} 处:');
  for (final e in subErrors.take(5)) {
    stdout.writeln('     - ${e.toErrorString()}');
  }
  if (subErrors.length > 5) {
    stdout.writeln('     ...其余 ${subErrors.length - 5} 处略');
  }
}

/// 沿实例 path 在 schema 原始 map 上导航（properties/items/$ref），返回该位置的 schema 节点
Map<String, dynamic>? _schemaAt(Map<String, dynamic> rootSchema, List<String> path) {
  dynamic node = rootSchema;
  for (final seg in path) {
    node = _deref(rootSchema, node);
    if (node is! Map) return null;
    final isIndex = RegExp(r'^\d+$').hasMatch(seg);
    if (isIndex && node['items'] != null) {
      node = node['items'];
    } else if ((node['properties'] as Map?)?.containsKey(seg) ?? false) {
      node = node['properties'][seg];
    } else {
      return null;
    }
  }
  final resolved = _deref(rootSchema, node);
  return resolved is Map<String, dynamic> ? resolved : null;
}

/// 循环解析 $ref（仅处理 #/ 开头的内部指针）
dynamic _deref(Map<String, dynamic> rootSchema, dynamic node) {
  var guard = 0;
  while (node is Map && node.containsKey(r'$ref') && guard++ < 10) {
    final ref = node[r'$ref'] as String;
    if (!ref.startsWith('#/')) return node;
    dynamic target = rootSchema;
    for (final p in ref.substring(2).split('/')) {
      if (target is Map) {
        target = target[p];
      } else if (target is List) {
        target = target[int.parse(p)];
      } else {
        return node;
      }
    }
    node = target;
  }
  return node;
}

String _brief(Object? value) {
  final s = jsonEncode(value);
  return s.length > 200 ? '${s.substring(0, 200)}...' : s;
}
