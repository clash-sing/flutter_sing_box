// test/tool/gen_models_e2e_test.dart —— 入口串联端到端测试（Process.run 走真 CLI 子进程）
// 覆盖：成功写盘 / 白名单失配退出码 2 且不留半成品。
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// 解析 dart 可执行文件：flutter_tester 运行时不会像 cmd 那样按 PATHEXT
/// 解析 PATH 上的 dart.bat，需手动定位真实 dart.exe——
/// 优先 PATH 上的 dart.exe，否则取 flutter 布局 dart.bat 同目录下的
/// cache/dart-sdk/bin/dart.exe。
String _resolveDartExecutable() {
  if (!Platform.isWindows) return 'dart';
  String withSep(String dir) => dir.endsWith('\\') || dir.endsWith('/') ? dir : '$dir\\';
  final dirs = (Platform.environment['PATH'] ?? '')
      .split(';')
      .where((d) => d.isNotEmpty);
  for (final dir in dirs) {
    final exe = '${withSep(dir)}dart.exe';
    if (File(exe).existsSync()) return exe;
  }
  for (final dir in dirs) {
    if (File('${withSep(dir)}dart.bat').existsSync()) {
      final sdk = '${withSep(dir)}cache\\dart-sdk\\bin\\dart.exe';
      if (File(sdk).existsSync()) return sdk;
    }
  }
  return 'dart'; // 兜底：POSIX 或 dart.exe 已直接可解析的场景
}

void main() {
  late Directory tmpOut;
  late final String dartExe;

  setUpAll(() => dartExe = _resolveDartExecutable());
  setUp(() {
    tmpOut = Directory.systemTemp.createTempSync('gen_models_test');
  });
  tearDown(() => tmpOut.deleteSync(recursive: true));

  test('迷你 schema 端到端：写盘成功且文件齐全', () async {
    final result = await Process.run(
      dartExe,
      [
        'run',
        'tool/gen_models.dart',
        'test/tool/fixtures/mini_schema.json',
        tmpOut.path,
        // 迷你 fixture 只含部分类型，需覆盖内置白名单避免失配；
        // --whitelist-inbound 空值 = 空集（fixture 无 Inbound def）
        '--whitelist-outbound',
        'hysteria2,snell,urltest',
        '--whitelist-inbound',
      ],
      workingDirectory: Directory.current.path,
      // flutter_tester 下默认解码走 systemEncoding（中文 Windows 为 GBK），须显式 utf8
      stdoutEncoding: utf8,
      stderrEncoding: utf8,
    );
    expect(result.exitCode, 0, reason: result.stderr as String);
    final outboundFile = File('${tmpOut.path}/outbound/outbound.dart');
    expect(outboundFile.existsSync(), isTrue);
    expect(outboundFile.readAsStringSync(), contains('sealed class Outbound'));
    // 上轮审查遗留断言：锁住生成注解的关键参数 includeIfNull: false
    final h2File = File('${tmpOut.path}/outbound/hysteria2_outbound.dart');
    expect(h2File.existsSync(), isTrue);
    expect(h2File.readAsStringSync(), contains('includeIfNull: false'));
  });

  test('白名单失配：退出码 2 且不写任何文件', () async {
    // 空 $defs 配内置白名单（含 hysteria2 等）必然失配：schemaPath 指向缺类型的文件
    final broken = File('${tmpOut.path}/broken_schema.json')
      ..writeAsStringSync('{"properties": {}, "\$defs": {}}');
    final result = await Process.run(
      dartExe,
      ['run', 'tool/gen_models.dart', broken.path, tmpOut.path],
      workingDirectory: Directory.current.path,
      stdoutEncoding: utf8,
      stderrEncoding: utf8,
    );
    expect(result.exitCode, 2);
    expect(result.stderr as String, contains('不在 schema 中'));
    expect(File('${tmpOut.path}/outbound').existsSync(), isFalse, reason: '失败时不留半成品');
    expect(File('${tmpOut.path}/sing_box.dart').existsSync(), isFalse, reason: '失败时不写任何文件');
  });
}
