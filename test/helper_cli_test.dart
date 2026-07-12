import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_sing_box/src/constants/windows_service.dart';
import 'package:flutter_sing_box/src/windows/helper_cli.dart';

void main() {
  group('HelperCli.buildRunasArgs', () {
    test('包含 -NoProfile / -NonInteractive 开关且共 4 段', () {
      final args = HelperCli.buildRunasArgs(r'C:\app\helper.exe', 'install');
      expect(args, hasLength(4));
      expect(args, containsAll(<String>['-NoProfile', '-NonInteractive']));
    });

    test('install 子命令正确拼入 -ArgumentList', () {
      final args = HelperCli.buildRunasArgs(r'C:\app\helper.exe', 'install');
      expect(args.last, contains('Start-Process'));
      expect(args.last, contains('-Verb RunAs'));
      expect(args.last, contains(r'C:\app\helper.exe'));
      expect(args.last, contains("-ArgumentList 'install'"));
    });

    test('uninstall / start 子命令同样拼入', () {
      expect(
        HelperCli.buildRunasArgs(r'C:\app\helper.exe', 'uninstall').last,
        contains("-ArgumentList 'uninstall'"),
      );
      expect(
        HelperCli.buildRunasArgs(r'C:\app\helper.exe', 'start').last,
        contains("-ArgumentList 'start'"),
      );
    });

    test('路径含空格时仍被单引号包裹', () {
      final args = HelperCli.buildRunasArgs(r'C:\Program Files\app\helper.exe', 'install');
      expect(args.last, contains(r"'C:\Program Files\app\helper.exe'"));
    });
  });

  group('HelperCli.waitUntilStatus', () {
    late HelperCli cli;
    setUp(() {
      cli = HelperCli(helperExePath: 'x');
    });

    test('命中 target 立即返回 true', () async {
      final ok = await cli.waitUntilStatus(
        queryStatus: () async => WindowsServiceStatus.running,
        target: (s) => s == WindowsServiceStatus.running,
        delay: (_) async {},
        now: () => DateTime(2026, 7, 13),
      );
      expect(ok, isTrue);
    });

    test('序列轮询后命中返回 true 且计次正确', () async {
      final seq = <WindowsServiceStatus>[
        WindowsServiceStatus.unknown,
        WindowsServiceStatus.notInstalled,
        WindowsServiceStatus.running,
      ];
      var i = 0;
      final ok = await cli.waitUntilStatus(
        queryStatus: () async => seq[i++],
        target: (s) => s == WindowsServiceStatus.running,
        delay: (_) async {},
        now: () => DateTime(2026, 7, 13), // 恒定时间，确保不超时
      );
      expect(ok, isTrue);
      expect(i, 3);
    });

    test('超时未命中返回 false', () async {
      var calls = 0;
      DateTime clock() {
        calls += 1;
        if (calls <= 3) return DateTime(2026, 7, 13);
        return DateTime(2026, 7, 13).add(const Duration(seconds: 20));
      }
      final ok = await cli.waitUntilStatus(
        queryStatus: () async => WindowsServiceStatus.notInstalled,
        target: (s) => s == WindowsServiceStatus.running,
        delay: (_) async {},
        now: clock,
      );
      expect(ok, isFalse);
    });
  });
}
