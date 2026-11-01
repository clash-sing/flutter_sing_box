import 'dart:async';
import 'dart:convert';
import 'dart:io' as io;
import 'package:path/path.dart' as p;

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_sing_box/src/constants/windows_service.dart';
import 'package:flutter_sing_box/src/data/models/windows/helper_config.dart';
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
      final r = await cli.run('status', elevated: false, timeout: const Duration(seconds: 5));
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
      final r = await cli.run('stop', elevated: false, timeout: const Duration(seconds: 5));
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
      await cli.run('install', elevated: true, timeout: const Duration(seconds: 5));
      expect(seenExe, 'powershell.exe');
      expect(seenArgs!.last, contains("-ArgumentList 'install'"));
    });

    test('超时 → ok:false timedOut:true', () async {
      final cli = HelperCli(
        helperExePath: 'x',
        runner: (exe, args) => Completer<io.ProcessResult>().future, // 永不完成
      );
      final r = await cli.run('status', elevated: false, timeout: const Duration(milliseconds: 10));
      expect(r.ok, isFalse);
      expect(r.timedOut, isTrue);
    });

    test('runner 抛异常 → ok:false stderr 记录', () async {
      final cli = HelperCli(
        helperExePath: 'x',
        runner: (exe, args) async => throw const io.ProcessException('x', <String>[], 'boom'),
      );
      final r = await cli.run('status', elevated: false, timeout: const Duration(seconds: 5));
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

  HelperConfig makeConfig() => HelperConfig(
    helperServiceName: 'clash_sing_service',
    helperServiceDisplayName: 'Clash Sing Service',
    helperServiceDescription: 'desc',
    singBoxExecute: r'C:\a\sing-box.exe',
    singBoxConfig: r'C:\a\using_config.json',
  );

  group('HelperCli.ensureHelperJson', () {
    late io.Directory tmp;
    setUp(() async {
      tmp = await io.Directory.systemTemp.createTemp('helper_json_test_');
    });
    tearDown(() async {
      if (await tmp.exists()) await tmp.delete(recursive: true);
    });

    test('不存在则写入合法 json', () async {
      final cli = HelperCli(helperExePath: p.join(tmp.path, 'helper.exe'));
      await cli.ensureHelperJson(makeConfig());
      final file = io.File(p.join(tmp.path, 'helper.json'));
      expect(await file.exists(), isTrue);
      final Map<String, dynamic> json =
          jsonDecode(await file.readAsString()) as Map<String, dynamic>;
      expect(json['helperName'], 'clash_sing_service');
      expect(json['execute'], r'C:\a\sing-box.exe');
    });

    test('已存在则不覆盖', () async {
      final cli = HelperCli(helperExePath: p.join(tmp.path, 'helper.exe'));
      await cli.ensureHelperJson(makeConfig());
      final first = await io.File(p.join(tmp.path, 'helper.json')).readAsString();
      // 用不同 config 再调一次
      await cli.ensureHelperJson(
        HelperConfig(
          helperServiceName: 'other',
          helperServiceDisplayName: 'd',
          helperServiceDescription: 'd',
          singBoxExecute: 'x',
          singBoxConfig: 'y',
        ),
      );
      expect(await io.File(p.join(tmp.path, 'helper.json')).readAsString(), first);
    });
  });

  group('HelperCli.install', () {
    late io.Directory tmp;
    setUp(() async {
      tmp = await io.Directory.systemTemp.createTemp('helper_install_test_');
    });
    tearDown(() async {
      if (await tmp.exists()) await tmp.delete(recursive: true);
    });
    HelperCli cliWithRunner(Future<io.ProcessResult> Function(String, List<String>) runner) =>
        HelperCli(helperExePath: p.join(tmp.path, 'helper.exe'), runner: runner);

    test('runas 失败(退出码非 0)直接返回 false，不轮询', () async {
      var polled = false;
      final cli = cliWithRunner((exe, args) async => io.ProcessResult(0, 1, '', 'denied'));
      final ok = await cli.install(
        makeConfig(),
        queryStatus: () async {
          polled = true;
          return WindowsServiceStatus.running;
        },
      );
      expect(ok, isFalse);
      expect(polled, isFalse);
    });

    test('runas 成功 + 轮询命中 running 返回 true', () async {
      final cli = cliWithRunner((exe, args) async => io.ProcessResult(0, 0, '', ''));
      final ok = await cli.install(
        makeConfig(),
        queryStatus: () async => WindowsServiceStatus.running,
        delay: (_) async {},
        now: () => DateTime(2026, 7, 13),
      );
      expect(ok, isTrue);
    });

    test('runas 成功但轮询超时返回 false', () async {
      var calls = 0;
      DateTime clock() {
        calls += 1;
        if (calls <= 3) return DateTime(2026, 7, 13);
        return DateTime(2026, 7, 13).add(const Duration(seconds: 20));
      }

      final cli = cliWithRunner((exe, args) async => io.ProcessResult(0, 0, '', ''));
      final ok = await cli.install(
        makeConfig(),
        queryStatus: () async => WindowsServiceStatus.notInstalled,
        delay: (_) async {},
        now: clock,
      );
      expect(ok, isFalse);
    });

    test('install 调用前会写入 helper.json', () async {
      final cli = cliWithRunner((exe, args) async => io.ProcessResult(0, 0, '', ''));
      await cli.install(
        makeConfig(),
        queryStatus: () async => WindowsServiceStatus.running,
        delay: (_) async {},
        now: () => DateTime(2026, 7, 13),
      );
      expect(await io.File(p.join(tmp.path, 'helper.json')).exists(), isTrue);
    });
  });

  group('HelperCli.uninstall', () {
    test('runas 失败直接返回 false', () async {
      final cli = HelperCli(
        helperExePath: 'x',
        runner: (exe, args) async => io.ProcessResult(0, 1, '', 'denied'),
      );
      final ok = await cli.uninstall(queryStatus: () async => WindowsServiceStatus.notInstalled);
      expect(ok, isFalse);
    });
    test('runas 成功 + 轮询命中 notInstalled 返回 true', () async {
      final cli = HelperCli(
        helperExePath: 'x',
        runner: (exe, args) async => io.ProcessResult(0, 0, '', ''),
      );
      final ok = await cli.uninstall(
        queryStatus: () async => WindowsServiceStatus.notInstalled,
        delay: (_) async {},
        now: () => DateTime(2026, 7, 13),
      );
      expect(ok, isTrue);
    });
    test('runas 成功但轮询超时返回 false', () async {
      var calls = 0;
      DateTime clock() {
        calls += 1;
        if (calls <= 3) return DateTime(2026, 7, 13);
        return DateTime(2026, 7, 13).add(const Duration(seconds: 20));
      }

      final cli = HelperCli(
        helperExePath: 'x',
        runner: (exe, args) async => io.ProcessResult(0, 0, '', ''),
      );
      final ok = await cli.uninstall(
        queryStatus: () async => WindowsServiceStatus.running,
        delay: (_) async {},
        now: clock,
      );
      expect(ok, isFalse);
    });
    test('验证提权调用形状: runner 收到 powershell.exe + uninstall', () async {
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
      await cli.uninstall(
        queryStatus: () async => WindowsServiceStatus.notInstalled,
        delay: (_) async {},
        now: () => DateTime(2026, 7, 13),
      );
      expect(seenExe, 'powershell.exe');
      expect(seenArgs!.last, contains("-ArgumentList 'uninstall'"));
    });
  });

  group('HelperCli.start', () {
    test('runas 失败(退出码非 0)直接返回 false，不轮询', () async {
      var polled = false;
      final cli = HelperCli(
        helperExePath: 'x',
        runner: (exe, args) async => io.ProcessResult(0, 1, '', 'denied'),
      );
      final ok = await cli.start(
        queryStatus: () async {
          polled = true;
          return WindowsServiceStatus.running;
        },
      );
      expect(ok, isFalse);
      expect(polled, isFalse);
    });

    test('runas 成功 + 轮询命中 running 返回 true', () async {
      final cli = HelperCli(
        helperExePath: 'x',
        runner: (exe, args) async => io.ProcessResult(0, 0, '', ''),
      );
      final ok = await cli.start(
        queryStatus: () async => WindowsServiceStatus.running,
        delay: (_) async {},
        now: () => DateTime(2026, 7, 13),
      );
      expect(ok, isTrue);
    });
    test('轮询超时返回 false', () async {
      var calls = 0;
      DateTime clock() {
        calls += 1;
        if (calls <= 3) return DateTime(2026, 7, 13);
        return DateTime(2026, 7, 13).add(const Duration(seconds: 20));
      }

      final cli = HelperCli(
        helperExePath: 'x',
        runner: (exe, args) async => io.ProcessResult(0, 0, '', ''),
      );
      final ok = await cli.start(
        queryStatus: () async => WindowsServiceStatus.stopped,
        delay: (_) async {},
        now: clock,
      );
      expect(ok, isFalse);
    });
  });

  group('HelperCli.restart', () {
    /// 前进式假时钟：从基准时间起每次调用推进 500ms，模拟真实时钟持续
    /// 前进。注意不能用「若干次后冻结」的 fake——restart 串联两段轮询，
    /// 第二段 deadline 以冻结点重算后永远无法越过，会死循环
    /// （真实 DateTime.now() 不存在此问题）。
    DateTime Function() makeAdvancingClock() {
      var elapsedMs = 0;
      return () {
        final t = DateTime(2026, 11, 1).add(Duration(milliseconds: elapsedMs));
        elapsedMs += 500;
        return t;
      };
    }

    test('run 失败（UAC 拒绝）返回 false 且不进入轮询', () async {
      var statusCalls = 0;
      final cli = HelperCli(
        helperExePath: 'x',
        runner: (exe, args) async => io.ProcessResult(0, 1, '', 'UAC 拒绝'),
      );
      final ok = await cli.restart(
        queryStatus: () async {
          statusCalls += 1;
          return WindowsServiceStatus.running;
        },
        delay: (_) async {},
        now: makeAdvancingClock(),
      );
      expect(ok, isFalse);
      expect(statusCalls, 0);
    });

    test('观测到离开 running 并回到 running 返回 true', () async {
      final seq = <WindowsServiceStatus>[
        WindowsServiceStatus.running, // 一段第 1 次：仍在 running（不得视为完成）
        WindowsServiceStatus.stopped, // 一段第 2 次：离开 running
        WindowsServiceStatus.stopped, // 二段第 1 次：新服务未起
        WindowsServiceStatus.running, // 二段第 2 次：回到 running
      ];
      var i = 0;
      final cli = HelperCli(
        helperExePath: 'x',
        runner: (exe, args) async => io.ProcessResult(0, 0, '', ''),
      );
      final ok = await cli.restart(
        queryStatus: () async => seq[i++],
        oldFileExists: () async => true, // .old 恒在，纯走状态迁移路径
        delay: (_) async {},
        now: makeAdvancingClock(),
      );
      expect(ok, isTrue);
      expect(i, 4);
    });

    test('恒 running 但 .old 中途消失（快速重启窄于采样间隔）返回 true', () async {
      // 连接时刻 sing-box 未跑，stop→start 全程可压缩到一次采样间隔内，
      // 状态采样可能全程落在 running（kardianos 把 StartPending 也映射为
      // running）——此时 .old 的消失（新服务 Program.Start 必删）是唯一
      // 可靠的成功信号
      var polls = 0;
      final cli = HelperCli(
        helperExePath: 'x',
        runner: (exe, args) async => io.ProcessResult(0, 0, '', ''),
      );
      final ok = await cli.restart(
        queryStatus: () async => WindowsServiceStatus.running,
        oldFileExists: () async => polls++ >= 2, // 前两轮 .old 仍在，第三轮起消失
        delay: (_) async {},
        now: makeAdvancingClock(),
      );
      expect(ok, isTrue);
    });

    test('恒 running（restart 未推进）超时返回 false（假成功防护）', () async {
      final cli = HelperCli(
        helperExePath: 'x',
        runner: (exe, args) async => io.ProcessResult(0, 0, '', ''),
      );
      final ok = await cli.restart(
        queryStatus: () async => WindowsServiceStatus.running,
        oldFileExists: () async => true, // .old 恒在（restart 未推进）
        delay: (_) async {},
        now: makeAdvancingClock(),
      );
      expect(ok, isFalse);
    });

    test('离开 running 后恒 stopped（start 失败）超时返回 false', () async {
      final seq = <WindowsServiceStatus>[
        WindowsServiceStatus.running,
        WindowsServiceStatus.stopped,
      ];
      var i = 0;
      final cli = HelperCli(
        helperExePath: 'x',
        runner: (exe, args) async => io.ProcessResult(0, 0, '', ''),
      );
      final ok = await cli.restart(
        queryStatus: () async =>
            i < seq.length ? seq[i++] : WindowsServiceStatus.stopped,
        oldFileExists: () async => true, // .old 恒在（服务未能重启）
        delay: (_) async {},
        now: makeAdvancingClock(),
      );
      expect(ok, isFalse);
    });

    test('error 瞬态不算状态迁移，等真实 stopped 后继续完成', () async {
      // status CLI 在服务停止过程中可能瞬态失败（error）——不得据此判定
      // 「已离开 running」；继续轮询到真实 stopped 才算迁移
      final seq = <WindowsServiceStatus>[
        WindowsServiceStatus.running, // 一段第 1 次：未推进
        WindowsServiceStatus.error, // 瞬态失败：不算迁移
        WindowsServiceStatus.stopped, // 真实迁移
        WindowsServiceStatus.stopped, // 二段：未起
        WindowsServiceStatus.running, // 二段：回到 running
      ];
      var i = 0;
      final cli = HelperCli(
        helperExePath: 'x',
        runner: (exe, args) async => io.ProcessResult(0, 0, '', ''),
      );
      final ok = await cli.restart(
        queryStatus: () async => seq[i++],
        oldFileExists: () async => true,
        delay: (_) async {},
        now: makeAdvancingClock(),
      );
      expect(ok, isTrue);
      expect(i, 5); // error 那次未提前转段，全序列被消费
    });

    test('error 瞬态后回到 running（服务从未被停）不得假阳性成功', () async {
      // 假阳性场景：error 一次后服务其实一直在 running（restart 未推进）——
      // 若把 error 当「已离开 running」，第二段首轮命中 running 即误报成功
      final seq = <WindowsServiceStatus>[
        WindowsServiceStatus.running,
        WindowsServiceStatus.error,
      ];
      var i = 0;
      final cli = HelperCli(
        helperExePath: 'x',
        runner: (exe, args) async => io.ProcessResult(0, 0, '', ''),
      );
      final ok = await cli.restart(
        queryStatus: () async =>
            i < seq.length ? seq[i++] : WindowsServiceStatus.running,
        oldFileExists: () async => true, // .old 恒在：restart 确实未推进
        delay: (_) async {},
        now: makeAdvancingClock(),
      );
      expect(ok, isFalse);
    });

    test('恒 error 且 .old 恒在（status 持续失败）超时返回 false', () async {
      final cli = HelperCli(
        helperExePath: 'x',
        runner: (exe, args) async => io.ProcessResult(0, 0, '', ''),
      );
      final ok = await cli.restart(
        queryStatus: () async => WindowsServiceStatus.error,
        oldFileExists: () async => true,
        delay: (_) async {},
        now: makeAdvancingClock(),
      );
      expect(ok, isFalse);
    });
  });
}
