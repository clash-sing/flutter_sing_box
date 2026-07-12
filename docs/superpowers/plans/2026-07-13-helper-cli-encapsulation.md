# clash_sing_helper.exe CLI 封装 实现计划

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 把 `clash_sing_helper.exe` 的 5 个子命令（status/install/uninstall/start/stop）封装为统一的 Dart API，新增 `HelperCli` 内部类收拢进程调用，并将 uninstall/start/stop 上升到平台无关抽象供 app 跨平台调用。

**Architecture:** 新增 Windows 内部类 `HelperCli`（`lib/src/windows/helper_cli.dart`）收拢"定位 exe / 拼参 / 提权 / 超时 / 解析"；`FlutterSingBoxWindows` 的 5 个服务方法只承载业务语义、委托 `HelperCli`。提权命令（install/uninstall/start）走 PowerShell `Start-Process -Verb RunAs` + 轮询 `status`；非提权命令（status/stop）直接 `Process.run`。`Process.run` 与时间通过构造/参数注入隔离，纯逻辑全部可单测。

**Tech Stack:** Dart ^3.11.0 / Flutter >=3.41.0、`dart:io`（`Process`/`ProcessResult`）、`flutter_test`（手写 fake，无 mocktail）、`package:path`、`dart:convert`（helper.json）。`HelperCliResult` 为普通类（不用 freezed，避免 build_runner）。

## Global Constraints

- **SDK**：Dart `^3.11.0`，Flutter `>=3.41.0`（pubspec 已声明）。
- **注释与 commit 消息**：简体中文。
- **不改 `FlutterSingBoxWindows.getSingBoxVersion()`**（返回 sing-box 内核版本 `'1.13.14'`，与 helper 无关）。
- **不改 Go 端** `windows_helper_service`；不封装 `info` / `version` 子命令。
- **生成文件不可手改**：本次不新增 freezed/json_serializable 注解，`HelperCliResult` 用普通类，**无需 build_runner**。
- **导入约定**：`helper_cli.dart` 位于 `lib/src/windows/`，对同 package 内类型用相对路径导入（`../constants/windows_service.dart`、`../data/models/windows/helper_config.dart`）；测试用 `package:flutter_sing_box/src/...` 绝对路径（沿用现有 `windows_service_test.dart` 风格）。
- **可测性约定**：`HelperCli` 构造注入 `runner`（默认 `io.Process.run`）；`@visibleForTesting` 暴露 `run`/`buildRunasArgs`/`_waitUntilStatus`/`ensureHelperJson`；业务方法 install/uninstall/start 转发可选 `queryStatus`/`delay`/`now` 给轮询。

## File Structure

| 文件 | 责任 | 本次 |
|------|------|------|
| `lib/src/windows/helper_cli.dart` | `HelperCli`（定位 exe、`run`、`_waitUntilStatus`、`buildRunasArgs`、5 命令方法、`ensureHelperJson`）+ `HelperCliResult` | 新增 |
| `test/helper_cli_test.dart` | HelperCli 纯逻辑单测 | 新增 |
| `lib/flutter_sing_box_windows.dart` | 5 方法委托 HelperCli；删除旧 `buildRunasArgs`/`waitForServiceReady`/`_ensureHelperJson` | 改 |
| `test/windows_service_test.dart` | 删除已迁移的 group，仅保留 `WindowsServiceStatus.fromHelperOutput` | 改 |
| `lib/flutter_sing_box_platform_interface.dart` | 补 `uninstallService`/`startService`/`stopService` 抽象 | 改 |
| `lib/flutter_sing_box.dart` | facade 补 3 委托方法 | 改 |
| `lib/flutter_sing_box_method_channel.dart` | 非 Windows stub 补 3 方法（→ `false`） | 改 |

任务依赖：Task 1→2→3→4→5→6（HelperCli 自底向上）→ Task 7（接入 + 迁移测试）→ Task 8（接口扩展）。Task 1–6 纯新增，不触碰现有代码，零回归；Task 7 才迁移现有 status/install；Task 8 才扩接口。

---

### Task 1: HelperCli 骨架 + HelperCliResult + buildRunasArgs（参数化）

**Files:**
- Create: `lib/src/windows/helper_cli.dart`
- Create: `test/helper_cli_test.dart`

**Interfaces:**
- Consumes: 无（首个任务）
- Produces: `HelperCliResult`（5 字段不可变）、`HelperRunner` typedef、`HelperCli` 构造 `{required String helperExePath, HelperRunner? runner}`、`HelperCli.buildRunasArgs(String helperExePath, String subCommand) → List<String>`

- [ ] **Step 1: 写 buildRunasArgs 的失败测试**

Create `test/helper_cli_test.dart`:

```dart
import 'dart:async';
import 'dart:io' show ProcessResult;
import 'package:flutter_test/flutter_test.dart';
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
}
```

- [ ] **Step 2: 运行测试验证失败**

Run: `flutter test test/helper_cli_test.dart`
Expected: FAIL，报 `helper_cli.dart` 不存在 / `HelperCli` 未定义。

- [ ] **Step 3: 写最小实现**

Create `lib/src/windows/helper_cli.dart`:

```dart
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
```

- [ ] **Step 4: 运行测试验证通过**

Run: `flutter test test/helper_cli_test.dart`
Expected: PASS（4 个测试全绿）。

- [ ] **Step 5: 提交**

```bash
git add lib/src/windows/helper_cli.dart test/helper_cli_test.dart
git commit -m "feat(windows): 新增 HelperCli 骨架与参数化 buildRunasArgs"
```

---

### Task 2: _waitUntilStatus（泛化轮询）

**Files:**
- Modify: `lib/src/windows/helper_cli.dart`（在 `HelperCli` 类内追加方法）
- Modify: `test/helper_cli_test.dart`（追加 group）

**Interfaces:**
- Consumes: `WindowsServiceStatus`（from `../constants/windows_service.dart`）
- Produces: `HelperCli._waitUntilStatus({...}) → Future<bool>`（`@visibleForTesting`），语义"轮询 queryStatus 直到 target 命中或超 deadline"

- [ ] **Step 1: 写失败测试**

在 `test/helper_cli_test.dart` 顶部 import 区追加：

```dart
import 'package:flutter_sing_box/src/constants/windows_service.dart';
```

在 `main()` 内追加 group：

```dart
  group('HelperCli._waitUntilStatus', () {
    late HelperCli cli;
    setUp(() {
      cli = HelperCli(helperExePath: 'x');
    });

    test('命中 target 立即返回 true', () async {
      final ok = await cli._waitUntilStatus(
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
      final ok = await cli._waitUntilStatus(
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
      final ok = await cli._waitUntilStatus(
        queryStatus: () async => WindowsServiceStatus.notInstalled,
        target: (s) => s == WindowsServiceStatus.running,
        delay: (_) async {},
        now: clock,
      );
      expect(ok, isFalse);
    });
  });
```

- [ ] **Step 2: 运行验证失败**

Run: `flutter test test/helper_cli_test.dart`
Expected: FAIL，`_waitUntilStatus` 未定义。

- [ ] **Step 3: 实现 _waitUntilStatus**

在 `lib/src/windows/helper_cli.dart` 顶部 import 区追加：

```dart
import '../constants/windows_service.dart';
```

在 `HelperCli` 类内（`buildRunasArgs` 之后）追加：

```dart
  /// 轮询服务状态，直到 [target] 命中或超过 [deadline]。
  ///
  /// 泛化自原 `FlutterSingBoxWindows.waitForServiceReady`：调用方传入
  /// [target] 判定（install→running/stopped，uninstall→notInstalled，
  /// start→running）。[queryStatus]/[delay]/[now] 注入便于单测。
  /// 返回 `true` 表示命中目标，`false` 表示超时。
  @visibleForTesting
  Future<bool> _waitUntilStatus({
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
```

- [ ] **Step 4: 运行验证通过**

Run: `flutter test test/helper_cli_test.dart`
Expected: PASS（7 个测试全绿）。

- [ ] **Step 5: 提交**

```bash
git add lib/src/windows/helper_cli.dart test/helper_cli_test.dart
git commit -m "feat(windows): HelperCli 新增泛化轮询 _waitUntilStatus"
```

---

### Task 3: run（提权分流核心，@visibleForTesting）

**Files:**
- Modify: `lib/src/windows/helper_cli.dart`
- Modify: `test/helper_cli_test.dart`

**Interfaces:**
- Consumes: `HelperCliResult`、`buildRunasArgs`、`_runner`
- Produces: `HelperCli.run(String subCommand, {required bool elevated, required Duration timeout}) → Future<HelperCliResult>`

- [ ] **Step 1: 写失败测试**

在 `test/helper_cli_test.dart` 顶部 import 区追加：

```dart
import 'dart:io' show ProcessResult, ProcessException;
```

（`dart:io` 已有 `show ProcessResult`，改为 `show ProcessResult, ProcessException`。）在 `main()` 内追加 group：

```dart
  group('HelperCli.run', () {
    test('非提权: runner 收到 helperExe + [subCommand]；exitCode0→ok:true；stdout 已 trim', () async {
      String? seenExe;
      List<String>? seenArgs;
      final cli = HelperCli(
        helperExePath: r'C:\a\helper.exe',
        runner: (exe, args) async {
          seenExe = exe;
          seenArgs = args;
          return ProcessResult(0, 0, '  running\n', '');
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
        runner: (exe, args) async => ProcessResult(0, 2, '', 'boom'),
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
          return ProcessResult(0, 0, '', '');
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
        runner: (exe, args) => Completer<ProcessResult>().future, // 永不完成
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
            throw const ProcessException('x', <String>[], 'boom'),
      );
      final r = await cli.run('status',
          elevated: false, timeout: const Duration(seconds: 5));
      expect(r.ok, isFalse);
      expect(r.stderr, contains('boom'));
    });
  });
```

- [ ] **Step 2: 运行验证失败**

Run: `flutter test test/helper_cli_test.dart`
Expected: FAIL，`run` 未定义。

- [ ] **Step 3: 实现 run**

在 `lib/src/windows/helper_cli.dart` 顶部 import 区追加：

```dart
import 'dart:async'; // TimeoutException
```

在 `HelperCli` 类内（`_waitUntilStatus` 之后）追加：

```dart
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
```

- [ ] **Step 4: 运行验证通过**

Run: `flutter test test/helper_cli_test.dart`
Expected: PASS（12 个测试全绿）。

- [ ] **Step 5: 提交**

```bash
git add lib/src/windows/helper_cli.dart test/helper_cli_test.dart
git commit -m "feat(windows): HelperCli 新增提权分流 run 方法"
```

---

### Task 4: status() + stop()（非提权命令）

**Files:**
- Modify: `lib/src/windows/helper_cli.dart`
- Modify: `test/helper_cli_test.dart`

**Interfaces:**
- Consumes: `run`、`WindowsServiceStatus.fromHelperOutput`
- Produces: `HelperCli.status() → Future<WindowsServiceStatus>`、`HelperCli.stop() → Future<bool>`

- [ ] **Step 1: 写失败测试**

在 `test/helper_cli_test.dart` 的 `main()` 内追加：

```dart
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
          runner: (exe, args) async => ProcessResult(0, 0, entry.key, ''),
        );
        expect(await cli.status(), entry.value);
      });
    }
    test('进程失败(exitCode 非 0) → error', () async {
      final cli = HelperCli(
        helperExePath: 'x',
        runner: (exe, args) async => ProcessResult(0, 1, '', 'boom'),
      );
      expect(await cli.status(), WindowsServiceStatus.error);
    });
    test('未识别 stdout → unknown', () async {
      final cli = HelperCli(
        helperExePath: 'x',
        runner: (exe, args) async => ProcessResult(0, 0, 'whatever', ''),
      );
      expect(await cli.status(), WindowsServiceStatus.unknown);
    });
  });

  group('HelperCli.stop', () {
    test('exitCode 0 → true', () async {
      final cli = HelperCli(
        helperExePath: 'x',
        runner: (exe, args) async => ProcessResult(0, 0, '', ''),
      );
      expect(await cli.stop(), isTrue);
    });
    test('exitCode 非 0 → false', () async {
      final cli = HelperCli(
        helperExePath: 'x',
        runner: (exe, args) async => ProcessResult(0, 2, '', 'err'),
      );
      expect(await cli.stop(), isFalse);
    });
    test('验证非提权调用形状: runner 收到 [stop]', () async {
      List<String>? seen;
      final cli = HelperCli(
        helperExePath: r'C:\a\helper.exe',
        runner: (exe, args) async {
          seen = args;
          return ProcessResult(0, 0, '', '');
        },
      );
      await cli.stop();
      expect(seen, ['stop']);
    });
  });
```

- [ ] **Step 2: 运行验证失败**

Run: `flutter test test/helper_cli_test.dart`
Expected: FAIL，`status`/`stop` 未定义。

- [ ] **Step 3: 实现 status 与 stop**

在 `HelperCli` 类内（`run` 之后）追加：

```dart
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
```

- [ ] **Step 4: 运行验证通过**

Run: `flutter test test/helper_cli_test.dart`
Expected: PASS（18 个测试全绿）。

- [ ] **Step 5: 提交**

```bash
git add lib/src/windows/helper_cli.dart test/helper_cli_test.dart
git commit -m "feat(windows): HelperCli 实现 status 与 stop 命令"
```

---

### Task 5: ensureHelperJson + install()（提权 + helper.json + 轮询）

**Files:**
- Modify: `lib/src/windows/helper_cli.dart`
- Modify: `test/helper_cli_test.dart`

**Interfaces:**
- Consumes: `run`、`_waitUntilStatus`、`HelperConfig`（from `../data/models/windows/helper_config.dart`）、`dart:convert`/`package:path`
- Produces: `HelperCli.ensureHelperJson(HelperConfig config) → Future<void>`（`@visibleForTesting`）、`HelperCli.install(HelperConfig config, {queryStatus, delay, now}) → Future<bool>`

- [ ] **Step 1: 写失败测试**

在 `test/helper_cli_test.dart` 顶部 import 区追加：

```dart
import 'dart:convert';
import 'dart:io' show Directory;
import 'package:path/path.dart' as p;
import 'package:flutter_sing_box/src/data/models/windows/helper_config.dart';
```

在 `main()` 内追加（`HelperConfig` 测试夹具用固定值）：

```dart
  HelperConfig makeConfig() => HelperConfig(
        helperServiceName: 'clash_sing_service',
        helperServiceDisplayName: 'Clash Sing Service',
        helperServiceDescription: 'desc',
        singBoxExecute: r'C:\a\sing-box.exe',
        singBoxConfig: r'C:\a\using_config.json',
        singBoxPort: 0,
      );

  group('HelperCli.ensureHelperJson', () {
    late Directory tmp;
    setUp(() async {
      tmp = await Directory.systemTemp.createTemp('helper_json_test_');
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
      await cli.ensureHelperJson(HelperConfig(
        helperServiceName: 'other',
        helperServiceDisplayName: 'd',
        helperServiceDescription: 'd',
        singBoxExecute: 'x',
        singBoxConfig: 'y',
        singBoxPort: 999,
      ));
      expect(await io.File(p.join(tmp.path, 'helper.json')).readAsString(), first);
    });
  });

  group('HelperCli.install', () {
    late Directory tmp;
    setUp(() async {
      tmp = await Directory.systemTemp.createTemp('helper_install_test_');
    });
    tearDown(() async {
      if (await tmp.exists()) await tmp.delete(recursive: true);
    });
    HelperCli cliWithRunner(Future<ProcessResult> Function(String, List<String>) runner) =>
        HelperCli(helperExePath: p.join(tmp.path, 'helper.exe'), runner: runner);

    test('runas 失败(退出码非 0)直接返回 false，不轮询', () async {
      var polled = false;
      final cli = cliWithRunner((exe, args) async => ProcessResult(0, 1, '', 'denied'));
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
      final cli = cliWithRunner((exe, args) async => ProcessResult(0, 0, '', ''));
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
      final cli = cliWithRunner((exe, args) async => ProcessResult(0, 0, '', ''));
      final ok = await cli.install(
        makeConfig(),
        queryStatus: () async => WindowsServiceStatus.notInstalled,
        delay: (_) async {},
        now: clock,
      );
      expect(ok, isFalse);
    });

    test('install 调用前会写入 helper.json', () async {
      final cli = cliWithRunner((exe, args) async => ProcessResult(0, 0, '', ''));
      await cli.install(makeConfig(),
          queryStatus: () async => WindowsServiceStatus.running,
          delay: (_) async {},
          now: () => DateTime(2026, 7, 13));
      expect(await io.File(p.join(tmp.path, 'helper.json')).exists(), isTrue);
    });
  });
```

> 注：上面用到了 `io.File`，需保证 `helper_cli_test.dart` 顶部 `import 'dart:io' show ProcessResult, ProcessException;` 已扩展为也含 `File`、`Directory`。Step 3 会统一调整为 `import 'dart:io' as io;` 并把测试中的 `ProcessResult`/`ProcessException`/`Directory`/`File` 改为带 `io.` 前缀——为减少改动，**本任务 Step 3 一并规范 import**（见下）。若偏好最小改动，也可保留 `show` 列表扩为 `show ProcessResult, ProcessException, File, Directory`，二选一，保持全文件一致即可。本计划采用 `as io` 方案。

- [ ] **Step 2: 运行验证失败**

Run: `flutter test test/helper_cli_test.dart`
Expected: FAIL，`ensureHelperJson`/`install` 未定义（且可能有 import 报错，Step 3 修正）。

- [ ] **Step 3: 规范 import + 实现 ensureHelperJson 与 install**

3a. 把 `test/helper_cli_test.dart` 顶部的 `import 'dart:io' show ProcessResult, ProcessException;` 改为：

```dart
import 'dart:io' as io;
```

并把测试体内所有裸 `ProcessResult` → `io.ProcessResult`、`ProcessException` → `io.ProcessException`、`Directory` → `io.Directory`、`File` → `io.File`（Task 1–4 的测试同步替换）。`Completer` 仍来自 `dart:async`。

3b. 在 `lib/src/windows/helper_cli.dart` 顶部 import 区追加：

```dart
import 'dart:convert'; // jsonEncode
import 'package:path/path.dart' as p;
import '../data/models/windows/helper_config.dart';
import 'package:flutter/foundation.dart' show debugPrint; // 已 import foundation，此处仅说明 debugPrint 可用
```

（`package:flutter/foundation.dart` 已在 Task 1 导入，同时提供 `@visibleForTesting` 与 `debugPrint`，无需重复 import。）

3c. 在 `HelperCli` 类内（`stop` 之后）追加：

```dart
  /// 确保 helper.exe 同目录下存在合法的 helper.json（install/status 等的强依赖）。
  ///
  /// - 已存在则**不覆盖**（保护服务运行时回写的 port 字段）。
  @visibleForTesting
  Future<void> ensureHelperJson(HelperConfig config) async {
    final io.File file = io.File(p.join(p.dirname(helperExePath), 'helper.json'));
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
      debugPrint('helper install runas 失败, exitCode=${r.exitCode}, stderr=${r.stderr}');
      return false;
    }
    return _waitUntilStatus(
      queryStatus: queryStatus ?? status,
      target: (s) =>
          s == WindowsServiceStatus.running || s == WindowsServiceStatus.stopped,
      delay: delay ?? ((d) => Future<void>.delayed(d)),
      now: now ?? DateTime.now,
    );
  }
```

- [ ] **Step 4: 运行验证通过**

Run: `flutter test test/helper_cli_test.dart`
Expected: PASS（24 个测试全绿）。

- [ ] **Step 5: 提交**

```bash
git add lib/src/windows/helper_cli.dart test/helper_cli_test.dart
git commit -m "feat(windows): HelperCli 实现 ensureHelperJson 与 install 命令"
```

---

### Task 6: uninstall() + start()（提权 + 轮询）

**Files:**
- Modify: `lib/src/windows/helper_cli.dart`
- Modify: `test/helper_cli_test.dart`

**Interfaces:**
- Consumes: `run`、`_waitUntilStatus`
- Produces: `HelperCli.uninstall({queryStatus, delay, now}) → Future<bool>`、`HelperCli.start({queryStatus, delay, now}) → Future<bool>`

- [ ] **Step 1: 写失败测试**

在 `test/helper_cli_test.dart` 的 `main()` 内追加：

```dart
  group('HelperCli.uninstall', () {
    test('runas 失败直接返回 false', () async {
      final cli = HelperCli(
        helperExePath: 'x',
        runner: (exe, args) async => io.ProcessResult(0, 1, '', 'denied'),
      );
      final ok = await cli.uninstall(
        queryStatus: () async => WindowsServiceStatus.notInstalled,
      );
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
```

- [ ] **Step 2: 运行验证失败**

Run: `flutter test test/helper_cli_test.dart`
Expected: FAIL，`uninstall`/`start` 未定义。

- [ ] **Step 3: 实现 uninstall 与 start**

在 `HelperCli` 类内（`install` 之后）追加：

```dart
  /// 卸载服务：`helper.exe uninstall`（UAC 提权）→ 轮询直到 notInstalled。
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
    return _waitUntilStatus(
      queryStatus: queryStatus ?? status,
      target: (s) => s == WindowsServiceStatus.notInstalled,
      delay: delay ?? ((d) => Future<void>.delayed(d)),
      now: now ?? DateTime.now,
    );
  }

  /// 启动已安装的服务：`helper.exe start`（UAC 提权）→ 轮询直到 running。
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
    return _waitUntilStatus(
      queryStatus: queryStatus ?? status,
      target: (s) => s == WindowsServiceStatus.running,
      delay: delay ?? ((d) => Future<void>.delayed(d)),
      now: now ?? DateTime.now,
    );
  }
```

- [ ] **Step 4: 运行验证通过**

Run: `flutter test test/helper_cli_test.dart`
Expected: PASS（31 个测试全绿）。

- [ ] **Step 5: 提交**

```bash
git add lib/src/windows/helper_cli.dart test/helper_cli_test.dart
git commit -m "feat(windows): HelperCli 实现 uninstall 与 start 命令"
```

---

### Task 7: FlutterSingBoxWindows 接入 HelperCli（迁移 + 删旧 + 迁移测试）

**Files:**
- Modify: `lib/flutter_sing_box_windows.dart`
- Modify: `test/windows_service_test.dart`

**Interfaces:**
- Consumes: `HelperCli`（Task 1–6 产出：`status()`/`stop()`/`install(config, {...})`/`uninstall({...})`/`start({...})`）
- Produces: 重写后的 `FlutterSingBoxWindows.queryServiceStatus` / `installService`（行为不变，委托 HelperCli）；删除 `buildRunasArgs` / `waitForServiceReady` / `_ensureHelperJson`

**回归目标：** `queryServiceStatus` 与 `installService` 的对外行为与现状完全一致（status 同样 5s 超时、exe 缺失返回 error；install 同样 runas+轮询、返回 bool）；`getSingBoxVersion` 不动。

- [ ] **Step 1: 先确认现有测试现状（基线）**

Run: `flutter test`
Expected: 全绿（含 `windows_service_test.dart` 的 fromHelperOutput / buildRunasArgs / waitForServiceReady group）。记下这一基线，迁移后 fromHelperOutput 须仍绿。

- [ ] **Step 2: 改写 FlutterSingBoxWindows**

把 `lib/flutter_sing_box_windows.dart` 整体替换为：

```dart
import 'dart:io' as io;
import 'package:path/path.dart' as p;
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_sing_box/flutter_sing_box.dart';
import 'package:flutter_sing_box/flutter_sing_box_platform_interface.dart';
import 'package:flutter_sing_box/src/windows/helper_cli.dart';

class FlutterSingBoxWindows extends FlutterSingBoxPlatform {
  @visibleForTesting
  final methodChannel = const MethodChannel('flutter_sing_box');

  /// Registers this class as the default instance of [FlutterSingBoxPlatform].
  static void registerWith() {
    FlutterSingBoxPlatform.instance = FlutterSingBoxWindows();
  }

  @override
  Future<void> init() async {
    debugPrint('flutter_sing_box 插件初始化 Windows 平台 startTime = ${DateTime.now()}');
    final io.Directory dir = await ProfileStorage().getStorageDirectory();
    const String assetBasePath = 'packages/flutter_sing_box/assets';

    const String assetPathSingBox = '$assetBasePath/windows/sing-box.exe';
    final singBoxResult = await AssetUtil.copyAssetToDirectory(assetPathSingBox, dir.path);
    if (!singBoxResult) {
      throw Exception('复制 sing_box.exe 资源失败');
    }
    const String assetPathLibcronet = '$assetBasePath/windows/libcronet.dll';
    final libcronetResult = await AssetUtil.copyAssetToDirectory(assetPathLibcronet, dir.path);
    if (!libcronetResult) {
      throw Exception('复制 libcronet.dll 资源失败');
    }

    // 释放独立服务程序 clash_sing_helper.exe，供 HelperCli 调用。
    const String assetPathHelper = '$assetBasePath/windows/clash_sing_helper.exe';
    final helperResult = await AssetUtil.copyAssetToDirectory(assetPathHelper, dir.path);
    if (!helperResult) {
      throw Exception('复制 clash_sing_helper.exe 资源失败');
    }
    debugPrint('flutter_sing_box 插件初始化 Windows 平台 endTime = ${DateTime.now()}');
  }

  /// 基于 exe 同目录构造 HelperCli（每次调用重建，无状态，轻量）。
  Future<HelperCli> _buildCli(io.Directory dir) async {
    return HelperCli(helperExePath: p.join(dir.path, 'clash_sing_helper.exe'));
  }

  /// 查询 Windows 端 `clash_sing_service` 的安装/运行状态。
  ///
  /// 流程：定位 helper.exe → 不存在直接返回 error → 委托 HelperCli.status。
  /// 任何异常（超时、进程失败）由 HelperCli 归一为 [WindowsServiceStatus.error]。
  @override
  Future<WindowsServiceStatus> queryServiceStatus() async {
    try {
      final io.Directory dir = await ProfileStorage().getStorageDirectory();
      final io.File helperExe = io.File(p.join(dir.path, 'clash_sing_helper.exe'));
      if (!await helperExe.exists()) {
        return WindowsServiceStatus.error;
      }
      final cli = await _buildCli(dir);
      return cli.status();
    } catch (_) {
      return WindowsServiceStatus.error;
    }
  }

  @override
  Future<bool> installService(HelperConfig config) async {
    try {
      final io.Directory dir = await ProfileStorage().getStorageDirectory();
      final io.File helperExe = io.File(p.join(dir.path, 'clash_sing_helper.exe'));
      if (!await helperExe.exists()) {
        return false;
      }
      final cli = await _buildCli(dir);
      return cli.install(config);
    } catch (e) {
      debugPrint('flutter_sing_box 插件安装服务失败, $e');
      return false;
    }
  }

  @override
  Future<String> getSingBoxVersion() async {
    return '1.13.14';
  }
}
```

> 说明：删除了 `buildRunasArgs` / `waitForServiceReady` / `_ensureHelperJson`（已迁入 HelperCli）；`installService` 不再自带轮询与 runas 逻辑，全部委托 `cli.install`（后者内部完成 ensureHelperJson + runas + 轮询）。

- [ ] **Step 3: 迁移 windows_service_test.dart（删除已迁走的 group）**

把 `test/windows_service_test.dart` 整体替换为（仅保留 enum 测试）：

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_sing_box/src/constants/windows_service.dart';

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
}
```

- [ ] **Step 4: 运行全部测试 + 静态分析**

Run: `flutter test`
Expected: 全绿（`helper_cli_test.dart` 31 个 + `windows_service_test.dart` 2 个 + 其他既有测试）。

Run: `flutter analyze lib/flutter_sing_box_windows.dart lib/src/windows/helper_cli.dart`
Expected: 无 error（可有 info 级 hint）。

- [ ] **Step 5: 提交**

```bash
git add lib/flutter_sing_box_windows.dart test/windows_service_test.dart
git commit -m "refactor(windows): FlutterSingBoxWindows 委托 HelperCli，删除已迁移辅助方法"
```

---

### Task 8: 平台抽象 / facade / stub 补 uninstall/start/stop

**Files:**
- Modify: `lib/flutter_sing_box_platform_interface.dart`
- Modify: `lib/flutter_sing_box.dart`
- Modify: `lib/flutter_sing_box_method_channel.dart`
- Modify: `lib/flutter_sing_box_windows.dart`

**Interfaces:**
- Consumes: `HelperCli.uninstall/start/stop`（Task 6/4）
- Produces: 抽象层 3 方法 `uninstallService()` / `startService()` / `stopService()`（默认 `throw UnimplementedError`）；facade 3 委托；非 Windows stub 3 方法（→ `false`）；Windows 实现 3 方法（委托 HelperCli）

**验证目标：** 接口扩展后全工程编译通过、`flutter analyze` 无 error、既有测试不回归；新方法的行为已在 Task 4/6 经 HelperCli 单测覆盖，本任务不新增单测。

- [ ] **Step 1: 抽象层补 3 方法声明**

在 `lib/flutter_sing_box_platform_interface.dart` 的 `installService` 声明之后追加：

```dart
  /// 卸载 Windows 系统服务。
  ///
  /// 仅 Windows 平台实现真正执行（UAC 提权调用 clash_sing_helper.exe uninstall
  /// 并轮询确认）；其他平台返回 `false`。
  Future<bool> uninstallService() async {
    throw UnimplementedError('uninstallService() has not been implemented.');
  }

  /// 启动已安装的 Windows 系统服务。
  Future<bool> startService() async {
    throw UnimplementedError('startService() has not been implemented.');
  }

  /// 停止 Windows 系统服务（helper 内部走 HTTP API 同步关闭）。
  Future<bool> stopService() async {
    throw UnimplementedError('stopService() has not been implemented.');
  }
```

- [ ] **Step 2: facade 补 3 委托**

在 `lib/flutter_sing_box.dart` 的 `installService` 之后追加：

```dart
  /// 卸载 Windows 系统服务。
  Future<bool> uninstallService() {
    return FlutterSingBoxPlatform.instance.uninstallService();
  }

  /// 启动已安装的 Windows 系统服务。
  Future<bool> startService() {
    return FlutterSingBoxPlatform.instance.startService();
  }

  /// 停止 Windows 系统服务。
  Future<bool> stopService() {
    return FlutterSingBoxPlatform.instance.stopService();
  }
```

- [ ] **Step 3: 非 Windows stub 补 3 方法**

在 `lib/flutter_sing_box_method_channel.dart` 的 `installService` 之后追加：

```dart
  @override
  Future<bool> uninstallService() async => false;

  @override
  Future<bool> startService() async => false;

  @override
  Future<bool> stopService() async => false;
```

- [ ] **Step 4: Windows 实现补 3 方法**

在 `lib/flutter_sing_box_windows.dart` 的 `installService` 之后、`getSingBoxVersion` 之前追加：

```dart
  @override
  Future<bool> uninstallService() async {
    try {
      final io.Directory dir = await ProfileStorage().getStorageDirectory();
      final io.File helperExe = io.File(p.join(dir.path, 'clash_sing_helper.exe'));
      if (!await helperExe.exists()) return false;
      final cli = await _buildCli(dir);
      return cli.uninstall();
    } catch (e) {
      debugPrint('flutter_sing_box 插件卸载服务失败, $e');
      return false;
    }
  }

  @override
  Future<bool> startService() async {
    try {
      final io.Directory dir = await ProfileStorage().getStorageDirectory();
      final io.File helperExe = io.File(p.join(dir.path, 'clash_sing_helper.exe'));
      if (!await helperExe.exists()) return false;
      final cli = await _buildCli(dir);
      return cli.start();
    } catch (e) {
      debugPrint('flutter_sing_box 插件启动服务失败, $e');
      return false;
    }
  }

  @override
  Future<bool> stopService() async {
    try {
      final io.Directory dir = await ProfileStorage().getStorageDirectory();
      final io.File helperExe = io.File(p.join(dir.path, 'clash_sing_helper.exe'));
      if (!await helperExe.exists()) return false;
      final cli = await _buildCli(dir);
      return cli.stop();
    } catch (e) {
      debugPrint('flutter_sing_box 插件停止服务失败, $e');
      return false;
    }
  }
```

- [ ] **Step 5: 全量验证**

Run: `flutter analyze`
Expected: 无 error。

Run: `flutter test`
Expected: 全绿（与 Task 7 Step 4 相同基线）。

- [ ] **Step 6: 提交**

```bash
git add lib/flutter_sing_box_platform_interface.dart lib/flutter_sing_box.dart \
        lib/flutter_sing_box_method_channel.dart lib/flutter_sing_box_windows.dart
git commit -m "feat(windows): uninstall/start/stop 上升到平台抽象与 facade"
```

---

## Self-Review

**1. Spec 覆盖**

| spec 要求 | 对应任务 |
|----------|----------|
| §3.1 HelperCli 类 | Task 1（骨架）+ 2/3/4/5/6（方法） |
| §3.2 HelperCliResult | Task 1 |
| §3.3 提权分流 run + buildRunasArgs 参数化 | Task 1（buildRunasArgs）+ Task 3（run） |
| §3.4 _waitUntilStatus + install/uninstall/start 轮询目标 | Task 2（轮询）+ Task 5（install→running/stopped）+ Task 6（uninstall→notInstalled、start→running） |
| §3.5 helper.json 仅 install 写 | Task 5 ensureHelperJson |
| §3.6 错误处理（catch→ok:false→业务失败值） | Task 3 run 的 catch + Task 4/5/6 映射 |
| §4 接口落点 4 层 | Task 7（Windows 接入）+ Task 8（抽象/facade/stub/Windows 三新方法） |
| §5 行为矩阵 5 命令 | status（T4）/ install（T5）/ uninstall（T6）/ start（T6）/ stop（T4） |
| §7 测试策略 | Task 1–6 单测（buildRunasArgs/fromHelperOutput 回归/_waitUntilStatus/run/status/stop/install/uninstall/start/ensureHelperJson） |
| §8 非目标（不改 getSingBoxVersion、不封 info/version、不改 Go 端） | Task 7 保留 getSingBoxVersion 原样；全程未触 Go 端、未加 info/version |

无遗漏。

**2. Placeholder 扫描**：无 TBD/TODO/"类似 Task N"/"适当错误处理"等；每个代码步骤含完整可编译代码。✓

**3. 类型一致性**：`HelperCliResult` 字段（ok/exitCode/stdout/stderr/timedOut）跨 Task 1/3 一致；`run(subCommand, {required elevated, required timeout})` 签名 Task 3 定义、Task 4/5/6 消费一致；`install/uninstall/start` 三方法签名除 config 外形参（queryStatus/delay/now）一致；`buildRunasArgs(path, subCommand)` Task 1 定义、Task 3 run 内调用一致；`_waitUntilStatus` Task 2 定义、Task 5/6 调用（target 各异）一致。✓

**4. 已知执行注意**：
- Task 5 Step 3a 的 import 规范（`dart:io as io`）会触及 Task 1–4 测试体内的类型前缀，执行时用 IDE 批量替换或一次性改全。
- 提权命令（install/uninstall/start）的真实进程行为（UAC 弹窗、服务起停）不在单测范围，需 Windows 环境手工回归（建议：装/卸各一轮，观察状态轮询）。
- `flutter analyze` 与 `flutter test` 在每个 Task 末尾运行，确保零回归。
