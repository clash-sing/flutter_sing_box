import 'dart:async';
import 'dart:io' as io;

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

  group('HelperCli.run', () {
    test('非提权: runner 收到 helperExe + [subCommand]；exitCode0→ok:true；stdout 已 trim', () async {
      String? seenExe;
      List<String>? seenArgs;
      final cli = HelperCli(
        helperExePath: r'C:\a\helper.exe',
        runner: (exe, args) async {
          seenExe = exe;
          seenArgs = args;
          return io.ProcessResult(0, 0, '  running\n', '');
        },
      );
      final r = await cli.run('status',
          elevated: false, timeout: const Duration(seconds: 5));
      expect(r.ok, isTrue);
      expect(r.exitCode, 0);
      expect(r.stdout, 'running');
      expect(r.timedOut, isFalse);
      expect(seenExe, r'C:\a\helper.exe');
      expect(seenArgs, ['status']);
    });

    test('非提权 exitCode 非 0 → ok:false', () async {
      final cli = HelperCli(
        helperExePath: 'x',
        runner: (exe, args) async => io.ProcessResult(0, 2, '', 'boom'),
      );
      final r = await cli.run('stop',
          elevated: false, timeout: const Duration(seconds: 5));
      expect(r.ok, isFalse);
      expect(r.exitCode, 2);
    });

    test('提权: runner 收到 powershell.exe + runasArgs(含子命令)', () async {
      String? seenExe;
      List<String>? seenArgs;
      final cli = HelperCli(
        helperExePath: r'C:\a\helper.exe',
        runner: (exe, args) async {
          seenExe = exe;
          seenArgs = args;
          return io.ProcessResult(0, 0, '', '');
        },
      );
      await cli.run('install',
          elevated: true, timeout: const Duration(seconds: 5));
      expect(seenExe, 'powershell.exe');
      expect(seenArgs!.last, contains("-ArgumentList 'install'"));
    });

    test('超时 → ok:false timedOut:true', () async {
      final cli = HelperCli(
        helperExePath: 'x',
        runner: (exe, args) => Completer<io.ProcessResult>().future, // 永不完成
      );
      final r = await cli.run('status',
          elevated: false, timeout: const Duration(milliseconds: 10));
      expect(r.ok, isFalse);
      expect(r.timedOut, isTrue);
    });

    test('runner 抛异常 → ok:false stderr 记录', () async {
      final cli = HelperCli(
        helperExePath: 'x',
        runner: (exe, args) async =>
            throw const io.ProcessException('x', <String>[], 'boom'),
      );
      final r = await cli.run('status',
          elevated: false, timeout: const Duration(seconds: 5));
      expect(r.ok, isFalse);
      expect(r.stderr, contains('boom'));
    });
  });

  group('HelperCli.status', () {
    final table = <String, WindowsServiceStatus>{
      'running': WindowsServiceStatus.running,
      'stopped': WindowsServiceStatus.stopped,
      'notInstalled': WindowsServiceStatus.notInstalled,
      'unknown': WindowsServiceStatus.unknown,
      'error': WindowsServiceStatus.error,
    };
    for (final entry in table.entries) {
      test('解析 stdout "${entry.key}"', () async {
        final cli = HelperCli(
          helperExePath: 'x',
          runner: (exe, args) async => io.ProcessResult(0, 0, entry.key, ''),
        );
        expect(await cli.status(), entry.value);
      });
    }
    test('进程失败(exitCode 非 0) → error', () async {
      final cli = HelperCli(
        helperExePath: 'x',
        runner: (exe, args) async => io.ProcessResult(0, 1, '', 'boom'),
      );
      expect(await cli.status(), WindowsServiceStatus.error);
    });
    test('未识别 stdout → unknown', () async {
      final cli = HelperCli(
        helperExePath: 'x',
        runner: (exe, args) async => io.ProcessResult(0, 0, 'whatever', ''),
      );
      expect(await cli.status(), WindowsServiceStatus.unknown);
    });
  });

  group('HelperCli.stop', () {
    test('exitCode 0 → true', () async {
      final cli = HelperCli(
        helperExePath: 'x',
        runner: (exe, args) async => io.ProcessResult(0, 0, '', ''),
      );
      expect(await cli.stop(), isTrue);
    });
    test('exitCode 非 0 → false', () async {
      final cli = HelperCli(
        helperExePath: 'x',
        runner: (exe, args) async => io.ProcessResult(0, 2, '', 'err'),
      );
      expect(await cli.stop(), isFalse);
    });
    test('验证非提权调用形状: runner 收到 [stop]', () async {
      List<String>? seen;
      final cli = HelperCli(
        helperExePath: r'C:\a\helper.exe',
        runner: (exe, args) async {
          seen = args;
          return io.ProcessResult(0, 0, '', '');
        },
      );
      await cli.stop();
      expect(seen, ['stop']);
    });
  });
}
