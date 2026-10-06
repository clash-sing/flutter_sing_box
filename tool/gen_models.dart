// tool/gen_models.dart —— 生成器入口：读 schema -> 解析 -> 输出
// 用法：dart run tool/gen_models.dart
import 'dart:convert';
import 'dart:io';

Future<void> main(List<String> args) async {
  final schemaPath = args.isNotEmpty
      ? args[0]
      : 'assets/schemas/singbox_schema.json';
  final raw = await File(schemaPath).readAsString();
  final schema = jsonDecode(raw) as Map<String, dynamic>;
  stdout.writeln('已加载 schema: $schemaPath');
  // TODO(Task2): 解析为 IR；TODO(Task3): 输出生成物
  exitCode = 0;
}
