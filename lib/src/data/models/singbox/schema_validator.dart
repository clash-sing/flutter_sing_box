import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:json_schema_builder/json_schema_builder.dart';

import '../../../constants/flutter_sing_box_constants.dart';

// 错误类型随校验器一并暴露，调用方无需直接依赖 json_schema_builder
export 'package:json_schema_builder/json_schema_builder.dart'
    show ValidationError, ValidationErrorType;

/// 校验 sing-box 配置是否符合官方 JSON Schema（draft 2020-12）。
///
/// schema 约 470KB，[fromMap] 构建有解析开销，构建一次后应复用实例；
/// 正式环境经 [instance] 获取缓存实例。
class SingBoxSchemaValidator {
  final Schema _schema;

  /// 缓存已构建的实例：schema 约 470KB，重复构建纯浪费
  static SingBoxSchemaValidator? _cachedInstance;

  const SingBoxSchemaValidator._(this._schema);

  /// 从插件 asset 加载 schema 并缓存，后续调用零开销。
  ///
  /// [assetLoader] 仅供测试注入（纯 dart 测试无 asset bundle，传文件
  /// 读取）；注入的 loader 同样会填充缓存，测试隔离用 [resetCache]。
  static Future<SingBoxSchemaValidator> instance({
    Future<String> Function(String assetPath)? assetLoader,
  }) async {
    final cached = _cachedInstance;
    if (cached != null) return cached;
    final loader = assetLoader ?? rootBundle.loadString;
    final raw = await loader(FlutterSingBoxConstants.schemaConfig);
    return _cachedInstance = SingBoxSchemaValidator.fromMap(
      jsonDecode(raw) as Map<String, dynamic>,
    );
  }

  /// 重置 [instance] 缓存，仅供测试隔离使用。
  @visibleForTesting
  static void resetCache() => _cachedInstance = null;

  /// 从已解码的 schema JSON 构建。
  ///
  /// 顶层 `$schema` 声明指向远程元模式（json-schema.org），保留它会让
  /// [validateSync] 尝试联网抓取该元模式（离线环境直接抛异常）；本包固定
  /// 按 2020-12 规则校验，该声明无实际作用，这里剥掉以保证纯离线校验。
  /// 顶层 `$id` 则保留：注册表靠它建立 `#/$defs/...` 内部引用的解析基准。
  factory SingBoxSchemaValidator.fromMap(Map<String, dynamic> schemaMap) {
    final map = Map<String, dynamic>.from(schemaMap);
    map.remove(r'$schema');
    return SingBoxSchemaValidator._(Schema.fromMap(map));
  }

  /// 校验配置（通常为 SingBox.toJson() 的输出）。
  ///
  /// 返回错误列表，空列表即合法；每项可用 [ValidationError.toErrorString]
  /// 直接输出带路径的可读信息。
  List<ValidationError> validateSync(Map<String, dynamic> config) =>
      _schema.validateSync(config);

  /// 对 oneOf/anyOf 汇总类错误做二次诊断，返回供日志附加的可读行。
  ///
  /// 上游 json_schema_builder 在 oneOf/anyOf 匹配 0 个分支时只报一句
  /// "matched 0"、丢弃全部子分支的具体原因（sing-box 的 outbound/inbound
  /// 均为按 type 判别的 oneOf，看不出到底哪个字段非法）。此方法沿错误
  /// 路径取出配置实例与 schema 分支做递归诊断：
  ///
  /// - 实例带 type 判别字段时按 const 选中分支单独复核，展开字段级错误；
  /// - 复核出的子错误若仍是 oneOf/anyOf 汇总错误（嵌套组合器，如
  ///   outbound → tls → certificate_sha256 的 string/byte 数组二选一），
  ///   继续递归展开，受 [_maxDiagnoseDepth] 层数限制；
  /// - 无法按 type 判别时（实例非对象或分支无 type const，典型如各种
  ///   anyOf）逐分支复核，列出各自的首条失败原因，不再直接放弃。
  ///
  /// 非组合器错误、路径失效等无法诊断的情况返回空列表。
  List<String> diagnoseCombinatorError(
    Map<String, dynamic> config,
    ValidationError error,
  ) {
    if (error.error != ValidationErrorType.oneOfNotMet &&
        error.error != ValidationErrorType.anyOfNotMet) {
      return const [];
    }
    try {
      return _diagnoseCombinator(config, error.path);
    } catch (_) {
      // 诊断属锦上添花，任何意外都不应波及校验/导入主流程
      return const [];
    }
  }

  /// 每处汇总错误最多展开的子错误条数，防刷屏
  static const _maxSubShown = 5;

  /// 嵌套组合器递归展开的最大层数，防深嵌套 schema 递归爆炸
  static const _maxDiagnoseDepth = 3;

  /// 逐分支兜底时最多列出的分支数，防刷屏
  static const _maxBranchesShown = 6;

  List<String> _diagnoseCombinator(
    Map<String, dynamic> config,
    List<String> path,
  ) =>
      _diagnoseNode(_schemaNodeAt(path), _valueAt(config, path), path, 0);

  /// 诊断一个 oneOf/anyOf 节点：能按 type 判别就选中分支复核，
  /// 否则（实例非对象 / 分支无 type const / 未知 type 且分支全无 const）
  /// 落到逐分支兜底。
  List<String> _diagnoseNode(
    Map<String, dynamic>? node,
    Object? instance,
    List<String> fullPath,
    int depth,
  ) {
    final branches = (node?['oneOf'] ?? node?['anyOf']) as List?;
    if (node == null || instance == null || branches == null) {
      return const ['无法定位该路径的配置或 schema 分支'];
    }
    if (instance is Map && instance.containsKey('type')) {
      final typeValue = instance['type'];
      Map<String, dynamic>? matched;
      for (final branch in branches) {
        if (_branchTypeConst(branch) == typeValue) {
          matched = Map<String, dynamic>.from(branch as Map);
          break;
        }
      }
      if (matched != null) {
        return _expandBranch(typeValue, matched, instance, fullPath, depth);
      }
      final supported = branches
          .map((b) => _branchTypeConst(b))
          .whereType<String>()
          .toList();
      if (supported.isNotEmpty) {
        return [
          'type="$typeValue" 不在本版 schema 支持的类型中（本版共 '
              '${supported.length} 种）',
          '支持的类型: ${supported.join(", ")}',
        ];
      }
      // 实例带 type 但分支全无 type const：与无判别字段同路，逐分支兜底
    }
    return _perBranch(branches, instance, fullPath, depth);
  }

  /// 按 type 判别选中的分支单独复核，展开子错误
  List<String> _expandBranch(
    Object typeValue,
    Map<String, dynamic> matched,
    Object instance,
    List<String> fullPath,
    int depth,
  ) {
    final subErrors = _withRootContext(matched).validateSync(instance);
    if (subErrors.isEmpty) {
      return ['type="$typeValue"，该分支单独复核通过（异常情况，请人工检查）'];
    }
    return [
      'type="$typeValue"，按该分支复核出 ${subErrors.length} 处:',
      for (final sub in subErrors.take(_maxSubShown))
        ..._describeOrExpand(sub, matched, instance, fullPath, depth),
      if (subErrors.length > _maxSubShown)
        '  ...其余 ${subErrors.length - _maxSubShown} 处略',
    ];
  }

  /// 单条子错误的输出：组合器汇总错误且未达深度上限时递归展开，
  /// 其余直接描述（路径拼回原位置，分支内校验的 path 是相对分支根的）
  List<String> _describeOrExpand(
    ValidationError sub,
    Map<String, dynamic> schemaNode,
    Object instance,
    List<String> fullPath,
    int depth,
  ) {
    final isCombinator = sub.error == ValidationErrorType.oneOfNotMet ||
        sub.error == ValidationErrorType.anyOfNotMet;
    final nestedPath = [...fullPath, ...sub.path];
    if (isCombinator && depth < _maxDiagnoseDepth) {
      return [
        '  - 嵌套组合器错误 at path #root${_location(nestedPath)}，展开:',
        for (final line in _diagnoseNode(
          _schemaNodeUnder(schemaNode, sub.path),
          _valueAt(instance, sub.path),
          nestedPath,
          depth + 1,
        ))
          '    $line',
      ];
    }
    return ['  - ${_describe(sub, prefix: fullPath)}'];
  }

  /// 无法按 type 判别时的兜底：逐分支复核，列出各自的首条失败原因
  List<String> _perBranch(
    List branches,
    Object instance,
    List<String> fullPath,
    int depth,
  ) {
    final lines = <String>['无法按 type 判别选择分支，逐分支复核:'];
    for (final (i, branch) in branches.take(_maxBranchesShown).indexed) {
      final branchMap = Map<String, dynamic>.from(branch as Map);
      final errors = _withRootContext(branchMap).validateSync(instance);
      if (errors.isEmpty) {
        lines.add('  - 分支 ${i + 1}: 复核通过（异常情况，请人工检查）');
        continue;
      }
      final first = errors.first;
      final isCombinator = first.error == ValidationErrorType.oneOfNotMet ||
          first.error == ValidationErrorType.anyOfNotMet;
      final nestedPath = [...fullPath, ...first.path];
      if (isCombinator && depth < _maxDiagnoseDepth) {
        lines.add('  - 分支 ${i + 1}: 嵌套组合器错误，展开:');
        lines.addAll(
          _diagnoseNode(
            _schemaNodeUnder(branchMap, first.path),
            _valueAt(instance, first.path),
            nestedPath,
            depth + 1,
          ).map((line) => '    $line'),
        );
      } else {
        lines.add('  - 分支 ${i + 1}: ${_describe(first, prefix: fullPath)}');
      }
    }
    if (branches.length > _maxBranchesShown) {
      lines.add('  ...其余 ${branches.length - _maxBranchesShown} 个分支略');
    }
    return lines;
  }

  /// 分支 properties.type.const 的判别值（无判别结构时返回 null）
  static Object? _branchTypeConst(Object branch) =>
      (((branch as Map)['properties'] as Map?)?['type'] as Map?)?['const'];

  /// 用「分支 + 根 $defs/$id 上下文」构建子 schema 单独复核，
  /// 分支内的 $ref（如 #/$defs/IPAddress）靠根 $id 基准解析
  Schema _withRootContext(Map<String, dynamic> branch) {
    final rootMap = _schema.value;
    return Schema.fromMap({
      r'$id': rootMap[r'$id'],
      r'$defs': rootMap[r'$defs'],
      ...branch,
    });
  }

  /// 子错误描述：路径拼回原位置（分支内校验的 path 是相对分支根的）
  static String _describe(ValidationError error, {required List<String> prefix}) {
    return '${error.details ?? error.error.name} at path '
        '#root${_location([...prefix, ...error.path])}';
  }

  /// 把路径格式化为 ["seg"]["seg"] 形式
  static String _location(List<String> path) =>
      path.map((p) => '["$p"]').join();

  /// 沿路径在配置（或其子树）上取值，索引段走列表、其余走 map
  static Object? _valueAt(Object? current, List<String> path) {
    for (final seg in path) {
      if (current is List && RegExp(r'^\d+$').hasMatch(seg)) {
        current = current[int.parse(seg)];
      } else if (current is Map) {
        current = current[seg];
      } else {
        return null;
      }
    }
    return current;
  }

  /// 沿错误路径在 schema 原始 map 上导航（properties/items/$ref）取节点
  Map<String, dynamic>? _schemaNodeAt(List<String> path) =>
      _schemaNodeUnder(_deref(_schema.value), path);

  /// 同 [_schemaNodeAt]，但起点可以是任意 schema 节点（如某个 oneOf 分支），
  /// 供嵌套展开时在分支内部继续定位
  Map<String, dynamic>? _schemaNodeUnder(Object? start, List<String> path) {
    Object? node = _deref(start);
    for (final seg in path) {
      if (node is! Map) return null;
      final isIndex = RegExp(r'^\d+$').hasMatch(seg);
      if (isIndex && node['items'] != null) {
        node = node['items'];
      } else if ((node['properties'] as Map?)?.containsKey(seg) ?? false) {
        node = node['properties'][seg];
      } else {
        return null;
      }
      node = _deref(node);
    }
    return node is Map<String, dynamic> ? node : null;
  }

  /// 循环解析 $ref（仅处理 #/ 开头的内部 JSON 指针，外部 ref 原样返回）
  Object? _deref(Object? node, {int guard = 10}) {
    while (node is Map && node.containsKey(r'$ref') && guard-- > 0) {
      final ref = node[r'$ref'];
      if (ref is! String || !ref.startsWith('#/')) return node;
      Object? target = _schema.value;
      for (final part in ref.substring(2).split('/')) {
        if (target is Map) {
          target = target[part];
        } else if (target is List) {
          target = target[int.parse(part)];
        } else {
          return node;
        }
      }
      node = target;
    }
    return node;
  }
}
