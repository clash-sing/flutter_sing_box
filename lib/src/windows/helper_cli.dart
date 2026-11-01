import 'dart:async';
import 'dart:convert';
import 'dart:io' as io;
import 'package:flutter/foundation.dart';
import 'package:flutter_sing_box/src/constants/windows_constants.dart';
import 'package:path/path.dart' as p;

import '../constants/windows_service.dart';
import '../data/models/windows/helper_config.dart';

/// helper.exe 一次调用的完整结果，便于单测断言与失败诊断。
class HelperCliResult {
  /// 是否进程正常退出（exitCode == 0 且未超时）。
  final bool ok; // 进程正常退出（exitCode == 0 且未超时）
  /// 退出码；非提权为 helper.exe 的，提权时为 powershell.exe 的。
  final int exitCode; // 非 elevated：helper.exe 退出码；elevated：powershell.exe 退出码
  /// 标准输出（已 trim）。
  final String stdout; // 已 trim
  /// 标准错误输出。
  final String stderr;
  /// 是否超时。
  final bool timedOut;

  /// 构造调用结果。
  const HelperCliResult({
    required this.ok,
    required this.exitCode,
    required this.stdout,
    required this.stderr,
    required this.timedOut,
  });
}

/// 进程执行器签名，默认 `io.Process.run`，测试可注入 fake。
typedef HelperRunner = Future<io.ProcessResult> Function(
    String exe, List<String> args);

/// 封装 `clash_sing_helper.exe` 的 6 个子命令调用。
///
/// 仅 Windows 平台使用；定位 exe、拼参、提权、超时、解析全部收拢于此。
class HelperCli {
  /// 构造 CLI 封装；[helperExePath] 为 exe 完整路径，runner 可注入测试。
  HelperCli({required this.helperExePath, HelperRunner? runner})
      : _runner = runner ?? ((exe, args) => io.Process.run(exe, args));

  /// helper.exe 的完整路径。
  final String helperExePath;
  final HelperRunner _runner;

  /// 构造通过 PowerShell 以管理员权限(runas)启动 [helperExePath] 执行
  /// [subCommand] 的命令行参数。抽成独立方法便于单测参数形状。
  ///
  /// 安全前提：[helperExePath] 来自受控 asset 释放路径、假定不含单引号；
  /// [subCommand] 为封闭枚举（install/uninstall/start/restart/stop/status），
  /// 故直接单引号插值无需转义。
  @visibleForTesting
  static List<String> buildRunasArgs(String helperExePath, String subCommand) {
    return <String>[
      '-NoProfile',
      '-NonInteractive',
      '-Command',
      "Start-Process -FilePath '$helperExePath' -ArgumentList '$subCommand' -Verb RunAs",
    ];
  }

  /// 轮询服务状态，直到 [target] 命中或超过 [deadline]。
  ///
  /// 泛化自原 `FlutterSingBoxWindows.waitForServiceReady`：调用方传入
  /// [target] 判定（install→running/stopped，uninstall→notInstalled，
  /// start→running）。[queryStatus]/[delay]/[now] 注入便于单测。
  /// 返回 `true` 表示命中目标，`false` 表示超时。
  @visibleForTesting
  Future<bool> waitUntilStatus({
    required Future<WindowsServiceStatus> Function() queryStatus,
    required bool Function(WindowsServiceStatus) target,
    required Future<void> Function(Duration) delay,
    required DateTime Function() now,
    Duration pollInterval = const Duration(milliseconds: 500),
    Duration deadline = const Duration(seconds: 15),
  }) async {
    final DateTime end = now().add(deadline);
    while (now().isBefore(end)) {
      if (target(await queryStatus())) return true;
      await delay(pollInterval);
    }
    return false;
  }

  /// 执行 helper 子命令。
  ///
  /// - [elevated] 为 `true` 时通过 PowerShell `Start-Process -Verb RunAs`
  ///   触发 UAC 提权（用于 install/uninstall/start），等的是 powershell.exe
  ///   自身退出码（0=同意 UAC，非 0=拒绝/路径无效）；最终状态需靠轮询确认。
  /// - [elevated] 为 `false` 时直接运行 helper.exe（用于 status/stop）。
  /// 任何异常（超时、ProcessException）一律 catch 成 `ok:false` 的结果。
  @visibleForTesting
  Future<HelperCliResult> run(
    String subCommand, {
    required bool elevated,
    required Duration timeout,
  }) async {
    try {
      final io.ProcessResult r;
      if (elevated) {
        r = await _runner('powershell.exe', buildRunasArgs(helperExePath, subCommand))
            .timeout(timeout);
      } else {
        r = await _runner(helperExePath, [subCommand]).timeout(timeout);
      }
      return HelperCliResult(
        ok: r.exitCode == 0,
        exitCode: r.exitCode,
        stdout: (r.stdout ?? '').toString().trim(),
        stderr: (r.stderr ?? '').toString(),
        timedOut: false,
      );
    } on TimeoutException {
      return const HelperCliResult(
          ok: false, exitCode: -1, stdout: '', stderr: '', timedOut: true);
    } catch (e) {
      return HelperCliResult(
          ok: false, exitCode: -1, stdout: '', stderr: e.toString(), timedOut: false);
    }
  }

  /// 查询服务状态：`helper.exe status` → 解析 stdout。
  /// 进程失败（含超时、异常）一律返回 [WindowsServiceStatus.error]。
  Future<WindowsServiceStatus> status() async {
    final HelperCliResult r = await run(
      'status',
      elevated: false,
      timeout: const Duration(seconds: 5),
    );
    if (!r.ok) return WindowsServiceStatus.error;
    return WindowsServiceStatus.fromHelperOutput(r.stdout);
  }

  /// 停止服务：`helper.exe stop`（Go 端内部走 HTTP API 同步关闭）。
  /// 成功判定：exitCode == 0。
  Future<bool> stop() async {
    final HelperCliResult r = await run(
      'stop',
      elevated: false,
      timeout: const Duration(seconds: 5),
    );
    return r.ok;
  }

  /// 确保 helper.exe 同目录下存在合法的 helper.json（install/status 等的强依赖）。
  ///
  /// - 已存在则**不覆盖**（保护服务运行时回写的 port 字段）。
  @visibleForTesting
  Future<void> ensureHelperJson(HelperConfig config) async {
    final io.File file =
        io.File(p.join(p.dirname(helperExePath), WindowsConstants.helperConfigFileName));
    if (await file.exists()) return;
    await file.parent.create(recursive: true);
    await file.writeAsString(jsonEncode(config.toJson()));
  }

  /// 安装并启动服务：先写 helper.json → `helper.exe install`（UAC 提权）
  /// → 轮询直到 running/stopped。
  ///
  /// [queryStatus]/[delay]/[now] 仅供测试注入；默认用自身 [status] 与真实时间。
  Future<bool> install(
    HelperConfig config, {
    Future<WindowsServiceStatus> Function()? queryStatus,
    Future<void> Function(Duration)? delay,
    DateTime Function()? now,
  }) async {
    await ensureHelperJson(config);
    final HelperCliResult r = await run(
      'install',
      elevated: true,
      timeout: const Duration(seconds: 15),
    );
    if (!r.ok) {
      debugPrint(
          'helper install runas 失败, exitCode=${r.exitCode}, stderr=${r.stderr}');
      return false;
    }
    return waitUntilStatus(
      queryStatus: queryStatus ?? status,
      target: (s) =>
          s == WindowsServiceStatus.running || s == WindowsServiceStatus.stopped,
      delay: delay ?? ((Duration d) => Future<void>.delayed(d)),
      now: now ?? DateTime.now,
    );
  }

  /// 卸载服务：`helper.exe uninstall`（UAC 提权）→ 轮询直到 notInstalled。
  ///
  /// [queryStatus]/[delay]/[now] 仅供测试注入；默认用自身 [status] 与真实时间。
  Future<bool> uninstall({
    Future<WindowsServiceStatus> Function()? queryStatus,
    Future<void> Function(Duration)? delay,
    DateTime Function()? now,
  }) async {
    final HelperCliResult r = await run(
      'uninstall',
      elevated: true,
      timeout: const Duration(seconds: 15),
    );
    if (!r.ok) {
      debugPrint(
          'helper uninstall runas 失败, exitCode=${r.exitCode}, stderr=${r.stderr}');
      return false;
    }
    return waitUntilStatus(
      queryStatus: queryStatus ?? status,
      target: (s) => s == WindowsServiceStatus.notInstalled,
      delay: delay ?? ((Duration d) => Future<void>.delayed(d)),
      now: now ?? DateTime.now,
    );
  }

  /// 启动已安装的服务：`helper.exe start`（UAC 提权）→ 轮询直到 running。
  ///
  /// [queryStatus]/[delay]/[now] 仅供测试注入；默认用自身 [status] 与真实时间。
  Future<bool> start({
    Future<WindowsServiceStatus> Function()? queryStatus,
    Future<void> Function(Duration)? delay,
    DateTime Function()? now,
  }) async {
    final HelperCliResult r = await run(
      'start',
      elevated: true,
      timeout: const Duration(seconds: 15),
    );
    if (!r.ok) {
      debugPrint(
          'helper start runas 失败, exitCode=${r.exitCode}, stderr=${r.stderr}');
      return false;
    }
    return waitUntilStatus(
      queryStatus: queryStatus ?? status,
      target: (s) => s == WindowsServiceStatus.running,
      delay: delay ?? ((Duration d) => Future<void>.delayed(d)),
      now: now ?? DateTime.now,
    );
  }

  /// 提权重启服务：`helper.exe restart`（UAC 提权，Go 侧 SCM 同步 stop→start）
  /// 后做**两段式状态迁移轮询**，完成判定必须观测到重启确实发生——服务本就
  /// running，若照抄 [start] 的单段「轮询到 running」会首轮即假成功（此时
  /// 服务尚未被停、App 会去连即将被停的旧服务）。
  ///
  /// 第一段（deadline 20s，含 UAC 已确认但 SCM 停止在途的稳定窗口余量）等
  /// 「离开 running」**或「.old 消失」」：连接时刻 sing-box 未运行，快速重启
  /// 的非 running 窗口可窄于 500ms 采样间隔、状态采样全程落在 running
  /// （kardianos 把 StartPending 也映射为 running），此时 [oldFileExists] 的
  /// 消失是唯一可靠信号——新服务的 Program.Start 在进入 running 前必删
  /// `<helper>.old`。第二段（deadline 15s）等「回到 running」。
  ///
  /// [run] 失败（UAC 拒绝、30s 超时——注意 runas 无 -Wait，该超时只覆盖
  /// 「UAC 等待用户点击 + 提权进程启动」）直接返回 false；任一段超时同样返回
  /// false——调用方降级用旧版服务继续业务，不打断用户。
  ///
  /// [queryStatus]/[oldFileExists]/[delay]/[now] 仅供测试注入；默认用自身
  /// [status]、helper 同目录 `.old` 文件与真实时间。
  Future<bool> restart({
    Future<WindowsServiceStatus> Function()? queryStatus,
    Future<bool> Function()? oldFileExists,
    Future<void> Function(Duration)? delay,
    DateTime Function()? now,
  }) async {
    final HelperCliResult r = await run(
      'restart',
      elevated: true,
      timeout: const Duration(seconds: 30),
    );
    if (!r.ok) {
      debugPrint(
          'helper restart runas 失败, exitCode=${r.exitCode}, stderr=${r.stderr}');
      return false;
    }
    final Future<WindowsServiceStatus> Function() query =
        queryStatus ?? status;
    final Future<bool> Function() oldExists = oldFileExists ??
        () => io.File('$helperExePath${WindowsConstants.helperOldSuffix}')
            .exists();
    final Future<void> Function(Duration) wait =
        delay ?? ((Duration d) => Future<void>.delayed(d));
    final DateTime Function() clock = now ?? DateTime.now;

    // 第一段：等「真实离开 running」（stopped / notInstalled）或「.old 消失」，
    // 证明 restart 确实在推进。error/unknown（status CLI 瞬态失败）不算迁移——
    // 否则服务从未被停时第二段首轮命中 running 即误报成功。
    // .old 检查是 async 文件 IO，装不进 waitUntilStatus 的同步 target，手写循环。
    final DateTime firstEnd = clock().add(const Duration(seconds: 20));
    bool transitioned = false;
    while (clock().isBefore(firstEnd)) {
      final WindowsServiceStatus s = await query();
      final bool leftRunning = s == WindowsServiceStatus.stopped ||
          s == WindowsServiceStatus.notInstalled;
      if (leftRunning || !await oldExists()) {
        transitioned = true;
        break;
      }
      await wait(const Duration(milliseconds: 500));
    }
    if (!transitioned) {
      debugPrint('helper restart 第一段超时：服务未离开 running 且 .old 未清理，按失败降级');
      return false;
    }
    // 第二段：等回到 running（新服务进程已被 SCM 拉起）
    return waitUntilStatus(
      queryStatus: query,
      target: (s) => s == WindowsServiceStatus.running,
      delay: wait,
      now: clock,
      deadline: const Duration(seconds: 15),
    );
  }
}
