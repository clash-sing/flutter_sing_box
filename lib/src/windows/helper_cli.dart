import 'dart:io' as io;
import 'package:flutter/foundation.dart';

/// helper.exe 一次调用的完整结果，便于单测断言与失败诊断。
class HelperCliResult {
  final bool ok; // 进程正常退出（exitCode == 0 且未超时）
  final int exitCode; // 非 elevated：helper.exe 退出码；elevated：powershell.exe 退出码
  final String stdout; // 已 trim
  final String stderr;
  final bool timedOut;

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

/// 封装 `clash_sing_helper.exe` 的 5 个子命令调用。
///
/// 仅 Windows 平台使用；定位 exe、拼参、提权、超时、解析全部收拢于此。
class HelperCli {
  HelperCli({required this.helperExePath, HelperRunner? runner})
      : _runner = runner ?? ((exe, args) => io.Process.run(exe, args));

  final String helperExePath;
  final HelperRunner _runner;

  /// 构造通过 PowerShell 以管理员权限(runas)启动 [helperExePath] 执行
  /// [subCommand] 的命令行参数。抽成独立方法便于单测参数形状。
  @visibleForTesting
  static List<String> buildRunasArgs(String helperExePath, String subCommand) {
    return <String>[
      '-NoProfile',
      '-NonInteractive',
      '-Command',
      "Start-Process -FilePath '$helperExePath' -ArgumentList '$subCommand' -Verb RunAs",
    ];
  }
}
