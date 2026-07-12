import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_sing_box/src/constants/windows_service.dart';
import 'package:flutter_sing_box/flutter_sing_box_windows.dart';

void main() {
  group('WindowsServiceStatus.fromHelperOutput', () {
    test('映射 helper 的已知返回值', () {
      expect(WindowsServiceStatus.fromHelperOutput('running'), WindowsServiceStatus.running);
      expect(WindowsServiceStatus.fromHelperOutput('stopped'), WindowsServiceStatus.stopped);
      expect(WindowsServiceStatus.fromHelperOutput('notInstalled'), WindowsServiceStatus.notInstalled);
      expect(WindowsServiceStatus.fromHelperOutput('unknown'), WindowsServiceStatus.unknown);
      expect(WindowsServiceStatus.fromHelperOutput('error'), WindowsServiceStatus.error);
    });

    test('未识别值（含空串）一律映射为 unknown', () {
      expect(WindowsServiceStatus.fromHelperOutput('whatever'), WindowsServiceStatus.unknown);
      expect(WindowsServiceStatus.fromHelperOutput(''), WindowsServiceStatus.unknown);
    });
  });

  group('FlutterSingBoxWindows.ensureHelperJson', () {
    late Directory tmp;

    setUp(() async {
      tmp = await Directory.systemTemp.createTemp('helper_json_test_');
    });

    tearDown(() async {
      if (await tmp.exists()) await tmp.delete(recursive: true);
    });
  });

  group('FlutterSingBoxWindows.buildRunasArgs', () {
    late FlutterSingBoxWindows inst;

    setUp(() {
      inst = FlutterSingBoxWindows();
    });

    test('包含 -NoProfile / -NonInteractive 开关', () {
      final args = inst.buildRunasArgs(r'C:\app\helper.exe');
      expect(args, containsAll(<String>['-NoProfile', '-NonInteractive']));
    });

    test('末位 -Command 含 Start-Process、-Verb RunAs、路径与 install 参数', () {
      final args = inst.buildRunasArgs(r'C:\app\helper.exe');
      expect(args, hasLength(4));
      final cmd = args.last;
      expect(cmd, contains('Start-Process'));
      expect(cmd, contains('-Verb RunAs'));
      expect(cmd, contains(r'C:\app\helper.exe'));
      expect(cmd, contains("-ArgumentList 'install'"));
    });

    test('路径含空格时仍被单引号包裹', () {
      final args = inst.buildRunasArgs(r'C:\Program Files\app\helper.exe');
      expect(args.last, contains(r"'C:\Program Files\app\helper.exe'"));
    });
  });

  group('FlutterSingBoxWindows.waitForServiceReady', () {
    late FlutterSingBoxWindows inst;

    setUp(() {
      inst = FlutterSingBoxWindows();
    });

    test('命中 running 立即返回 true', () async {
      final ok = await inst.waitForServiceReady(
        queryStatus: () async => WindowsServiceStatus.running,
        delay: (_) async {},
        now: () => DateTime(2026, 7, 13),
      );
      expect(ok, isTrue);
    });

    test('命中 stopped 返回 true(已安装即视为成功)', () async {
      final ok = await inst.waitForServiceReady(
        queryStatus: () async => WindowsServiceStatus.stopped,
        delay: (_) async {},
        now: () => DateTime(2026, 7, 13),
      );
      expect(ok, isTrue);
    });

    test('超时仍为 notInstalled 返回 false', () async {
      var calls = 0;
      DateTime clock() {
        calls += 1;
        // 前几次调用返回 base(允许轮询),第 4 次起跳过 deadline(15s)触发退出。
        if (calls <= 3) return DateTime(2026, 7, 13);
        return DateTime(2026, 7, 13).add(const Duration(seconds: 20));
      }

      final ok = await inst.waitForServiceReady(
        queryStatus: () async => WindowsServiceStatus.notInstalled,
        delay: (_) async {},
        now: clock,
      );
      expect(ok, isFalse);
    });

    test('先 notInstalled/unknown 后 running 的序列能轮询命中', () async {
      final statuses = <WindowsServiceStatus>[
        WindowsServiceStatus.notInstalled,
        WindowsServiceStatus.unknown,
        WindowsServiceStatus.running,
      ];
      var i = 0;
      final ok = await inst.waitForServiceReady(
        queryStatus: () async => statuses[i++],
        delay: (_) async {},
        now: () => DateTime(2026, 7, 13), // 恒定时间,确保不超时
      );
      expect(ok, isTrue);
      expect(i, 3); // 确认轮询了 3 次才命中
    });
  });
}
