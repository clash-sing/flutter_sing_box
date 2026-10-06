// tool/gen_models.dart —— 生成器入口：读 schema -> 解析为 IR -> 输出 Dart 源码并写盘
// 用法：dart run tool/gen_models.dart [schemaPath] [outputRoot]
//                 [--whitelist-outbound a,b,c] [--whitelist-inbound x,y]
// 成功写盘退出 0；白名单失配等 schema 冲突退出 2 且不写任何文件。
import 'dart:convert';
import 'dart:io';

import 'src/dart_emitter.dart';
import 'src/names.dart';
import 'src/schema_ir.dart';

const String _usage =
    '用法：dart run tool/gen_models.dart [schemaPath] [outputRoot] '
    '[--whitelist-outbound a,b,c] [--whitelist-inbound x,y]';

Future<void> main(List<String> args) async {
  final config = _parseArgs(args);
  if (config == null) {
    stderr.writeln(_usage);
    exitCode = 1; // 参数非法：退出码 1（区别于 schema 冲突的 2）
    return;
  }
  try {
    final raw = await File(config.schemaPath).readAsString();
    final schema = jsonDecode(raw) as Map<String, dynamic>;
    stdout.writeln('已加载 schema: ${config.schemaPath}');
    final ir = buildIr(
      schema,
      outboundWhitelist: config.outboundWhitelist,
      inboundWhitelist: config.inboundWhitelist,
    );
    final files = emitDart(ir);
    // buildIr/emitDart 全部成功后才进入写盘循环：冲突异常在写盘前抛出即
    // 天然满足「失败不写任何文件」（emitDart 仅字符串组装，自身不落盘）。
    for (final entry in files.entries) {
      // emitDart 的相对路径一律用 / 分隔，此处按平台转换分隔符
      final relative = entry.key.split('/').join(Platform.pathSeparator);
      final file = File(
        '${config.outputRoot}${Platform.pathSeparator}$relative',
      );
      file.createSync(recursive: true);
      file.writeAsStringSync(entry.value);
    }
    stdout.writeln('已生成 ${files.length} 个文件到 ${config.outputRoot}');
  } on SchemaConflictException catch (e) {
    stderr.writeln(e);
    exitCode = 2;
  } on FileSystemException catch (e) {
    stderr.writeln('读取 schema 失败：$e');
    exitCode = 1;
  } on FormatException catch (e) {
    stderr.writeln('schema 不是合法 JSON：$e');
    exitCode = 1;
  }
}

/// 命令行配置：位置参数 + 白名单覆盖
class _Config {
  const _Config(
    this.schemaPath,
    this.outputRoot,
    this.outboundWhitelist,
    this.inboundWhitelist,
  );

  final String schemaPath;
  final String outputRoot;
  final Set<String> outboundWhitelist;
  final Set<String> inboundWhitelist;
}

/// 解析参数：位置参数依次为 schemaPath / outputRoot（均有缺省值）；
/// 可选 flag --whitelist-outbound / --whitelist-inbound，逗号分隔类型列表，
/// 缺省用内置白名单（names.dart，与 OutboundType/InboundType 常量表对齐）；
/// flag 不带值（后随另一 flag 或结尾）= 空集。非法参数返回 null。
_Config? _parseArgs(List<String> args) {
  String? schemaPath;
  String? outputRoot;
  Set<String>? outbound;
  Set<String>? inbound;
  for (var i = 0; i < args.length; i++) {
    final arg = args[i];
    if (arg == '--whitelist-outbound' || arg == '--whitelist-inbound') {
      // 类型名不会以 - 开头：后随值缺失或形如另一 flag 时按空值处理
      final hasValue = i + 1 < args.length && !args[i + 1].startsWith('-');
      final value = hasValue ? args[++i] : '';
      final types = value
          .split(',')
          .map((s) => s.trim())
          .where((s) => s.isNotEmpty)
          .toSet();
      if (arg == '--whitelist-outbound') {
        outbound = types;
      } else {
        inbound = types;
      }
    } else if (arg.startsWith('-')) {
      stderr.writeln('未知参数：$arg');
      return null;
    } else if (schemaPath == null) {
      schemaPath = arg;
    } else if (outputRoot == null) {
      outputRoot = arg;
    } else {
      stderr.writeln('多余的位置参数：$arg');
      return null;
    }
  }
  return _Config(
    schemaPath ?? 'assets/schemas/singbox_schema.json',
    outputRoot ?? 'lib/src/data/models/singbox/gen',
    outbound ?? outboundWhitelist,
    inbound ?? inboundWhitelist,
  );
}
