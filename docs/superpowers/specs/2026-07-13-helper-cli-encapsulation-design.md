# clash_sing_helper.exe CLI 的 Dart 封装设计

- 日期：2026-07-13
- 状态：已按用户复核缩减为 5 个命令（移除 version），待 spec 复核
- 涉及工程：`flutter_sing_box`（主要）、关联 `windows_helper_service`（Go 端，仅作语义参考，本次不改）
- 关联文档：`2026-07-13-install-service-runas-design.md`（install 的 runas 提权先行实现，本设计将其泛化到 install/uninstall/start）

## 1. 背景与目标

桌面端 `clash_sing_helper.exe`（由 `windows_helper_service` Go 工程编译）以 CLI 子命令形式管理名为 `clash_sing_service` 的 Windows 系统服务。本次封装其中 **5 个核心子命令**：`install`、`uninstall`、`start`、`stop`、`status`。`info`（纯调试多行输出）与 `version`（helper 自身版本编码串）暂不封装——无业务消费方，遵循 YAGNI。

当前 `flutter_sing_box` 的 Windows 实现只封装了其中两个：

- `queryServiceStatus()` → `status`（直接 `Process.run`，5s 超时，返回 `WindowsServiceStatus` 枚举）
- `installService(HelperConfig)` → `install`（PowerShell `Start-Process -Verb RunAs` 提权，15s 超时 + 轮询，返回 `bool`）

两者风格不统一（提权方式、超时、返回类型各异），且 `uninstall`/`start`/`stop` 尚未封装。app 侧（`clash_sing_app`）的 `WindowsServiceVM` 目前只消费 `queryServiceStatus` 与 `installService`，其余命令暂无调用方，但卸载/起停服务等场景已在规划中。

> 注：`FlutterSingBoxWindows.getSingBoxVersion()` 返回的是 **sing-box 内核**版本（与 helper 无关），本次**不改**。

**目标**：把 5 个核心子命令封装为统一的 Dart API，作为 helper CLI 的 Dart 投射，供 app 跨平台调用。

**成功标准**：

1. 新增 Windows 内部类 `HelperCli`，收拢"调用 helper.exe"的全部关注点（定位 exe、拼参数、提权启动、超时、stdout 解析）；`FlutterSingBoxWindows` 的 5 个服务方法只承载业务语义，全部委托 `HelperCli`。
2. 5 个命令上升到平台无关抽象（`FlutterSingBoxPlatform` + `FlutterSingBox` facade），非 Windows 平台提供 stub，app 可跨平台调用。
3. 提权命令（install/uninstall/start）轮询 `status` 确认最终状态，而非仅凭 UAC 同意判定成功。
4. 纯逻辑（结果解析、runas 参数形状、轮询判定）可单测，`Process.run` 可注入隔离。

## 2. 现状分析

### 2.1 Go 端 5 个子命令的语义（`windows_helper_service/main.go`）

| 子命令 | 是否需 UAC 提权 | 是否依赖 helper.json | stdout 产出 | 行为要点 |
|--------|----------------|---------------------|-------------|----------|
| `status` | 否 | 是 | `running`/`stopped`/`notInstalled`/`unknown`/`error` | 先查 HTTP API 是否在跑，再查 SCM `srv.Status()` |
| `install` | **是** | 是 | 无 | 先 `Uninstall`→`Install`→`Start` |
| `uninstall` | **是** | 是 | 无 | 先 `Stop`→`Uninstall` |
| `start` | **是** | 是 | 无 | `srv.Start()` |
| `stop` | 否（内部走 HTTP API `ShutdownByAPI`） | 是 | 无 | 若 `running` 则 HTTP 关闭，否则打 "not running" |

注：`install`/`uninstall`/`start`/`stop` 在 Go 端失败时 `panic`（`mustReadConfig` 读不到 helper.json 也会 panic）；`status` 内部把异常归一成字符串 `"error"`。Go 端另有 `info`/`version` 子命令，本次不封装。

### 2.2 Flutter 端封装现状

- `FlutterSingBoxWindows`（`lib/flutter_sing_box_windows.dart`）：实现了 `queryServiceStatus`、`installService`，含辅助方法 `buildRunasArgs`（**子命令名写死 `'install'`**）、`waitForServiceReady`（轮询到 running/stopped）、`_ensureHelperJson`（仅当 helper.json 不存在时写入，保护运行时回写的 port 字段）、`getSingBoxVersion`（写死返回 sing-box 内核版本 `'1.13.14'`，本次不动）。
- `FlutterSingBoxPlatform`（抽象）：已声明 `queryServiceStatus`、`installService`。
- `FlutterSingBox`（facade，`lib/flutter_sing_box.dart`）：已暴露 `queryServiceStatus`、`installService`。
- `MethodChannelFlutterSingBox`（Android/iOS 等 stub）：`queryServiceStatus` 返回 `WindowsServiceStatus.unsupported`，`installService` 占位返回 `true`。
- app 侧 `WindowsServiceVM`（`clash_sing_app/lib/src/vm/windows_service_vm.dart`）：在 `build`/`refresh` 中以 `io.Platform.isWindows` 守卫，非 Windows 直接返回 `unsupported`，仅在 Windows 调用 `queryServiceStatus` / `installService`。

## 3. 设计决策（均经用户确认）

### 3.1 抽出独立 `HelperCli` 类

把"调用 helper.exe"的全部关注点从 `FlutterSingBoxWindows` 剥离到 Windows 专属内部类 `HelperCli`。平台类的 5 个服务方法只承载业务语义（写 helper.json、把结果映射成业务类型、平台守卫），执行细节委托 `HelperCli`。

### 3.2 结果模型：内部统一 `HelperCliResult`，对外原生类型

`HelperCli` 内部用一个不可变结果对象承载每次调用的全貌，便于单测断言与失败诊断：

```dart
class HelperCliResult {
  final bool ok;        // 进程是否正常退出（exitCode == 0 且未超时）
  final int exitCode;   // 非 elevated：helper.exe 退出码；elevated：powershell.exe 退出码
  final String stdout;  // 已 trim
  final String stderr;
  final bool timedOut;
}
```

`HelperCli` 对外方法按命令语义把 `HelperCliResult` 映射成业务友好类型：

- `status` → `WindowsServiceStatus`（`WindowsServiceStatus.fromHelperOutput(result.stdout)`）
- `install` / `uninstall` / `start` / `stop` → `bool`

失败诊断信息通过 `debugPrint` 打印 `stderr` / `exitCode`（沿用现状风格），不向上抛。

### 3.3 提权分流：一个 `_run`，按 `elevated` 走两条路径

```dart
Future<HelperCliResult> _run(
  String subCommand, {
  required bool elevated,
  required Duration timeout,
});
```

- `elevated: false` → `Process.run(helperExe.path, [subCommand]).timeout(timeout)`，等 helper.exe 退出码。用于 `status` / `stop`。
- `elevated: true` → `Process.run('powershell.exe', buildRunasArgs(helperExe.path, subCommand)).timeout(timeout)`，等 powershell.exe 退出码（0 = 用户同意 UAC，非 0 = 拒绝/路径无效）。用于 `install` / `uninstall` / `start`。

`buildRunasArgs` 参数化子命令名（去掉写死的 `'install'`），复用于 install/uninstall/start：

```dart
@visibleForTesting
List<String> buildRunasArgs(String helperExePath, String subCommand) => [
  '-NoProfile', '-NonInteractive', '-Command',
  "Start-Process -FilePath '$helperExePath' -ArgumentList '$subCommand' -Verb RunAs",
];
```

> 关键约束（来自现有 `installService` 注释）：`Start-Process` 默认不 `-Wait`，powershell.exe 在提权进程启动后即退出。故 `elevated` 路径"等的是 powershell.exe 自身退出码"，而非提权后 helper 的执行结果——后者靠轮询 `status` 确认（见 §3.4）。

### 3.4 提权命令均轮询 `status` 确认最终状态

抽一个通用轮询方法，泛化现有 `waitForServiceReady`：

```dart
@visibleForTesting
Future<bool> _waitUntilStatus({
  required Future<WindowsServiceStatus> Function() queryStatus,
  required bool Function(WindowsServiceStatus) target,
  required Future<void> Function(Duration) delay,
  required DateTime Function() now,
  Duration pollInterval = const Duration(milliseconds: 500),
  Duration deadline = const Duration(seconds: 15),
});
```

各提权命令在 `runas` 退出码为 0 后，调用 `_waitUntilStatus` 确认：

| 命令 | 目标判定（target） |
|------|-------------------|
| install | `s == running \|\| s == stopped`（服务已安装，可能已起） |
| uninstall | `s == notInstalled` |
| start | `s == running` |

`stop`（非提权，Go 端同步走 HTTP API）不轮询，直接以 helper.exe `exitCode == 0` 判定。

`queryStatus` / `delay` / `now` 注入，沿用现有 `waitForServiceReady` 的可测风格。

### 3.5 helper.json 策略

仅 `install` 在调用前主动写 helper.json（沿用现有 `_ensureHelperJson`：仅当文件不存在时写入，保护服务运行时回写的 port 字段）。其余命令（status/stop/start/uninstall）假定 helper.json 已由先前 install 写入；若缺失，Go 端 `mustReadConfig` panic → 进程非零退出 → 被 `HelperCli` catch 转成 `HelperCliResult(ok:false)` → 业务层映射为失败值。

### 3.6 错误处理

任何异常（`TimeoutException`、`ProcessException`、文件缺失等）一律在 `HelperCli._run` 内 catch，转成 `HelperCliResult(ok:false, timedOut:..., stderr:...)`。平台层映射成业务失败值（`status`→`WindowsServiceStatus.error`、bool→`false`）。不向上抛——与现状一致。

## 4. 接口落点（4 层改动）

| 层 | 文件 | 改动 |
|----|------|------|
| 抽象 | `lib/flutter_sing_box_platform_interface.dart` | 补 3 个抽象方法：`uninstallService()` / `startService()` / `stopService()`（默认 throw `UnimplementedError`） |
| facade | `lib/flutter_sing_box.dart` | 补 3 个委托方法，转调 `FlutterSingBoxPlatform.instance` |
| stub | `lib/flutter_sing_box_method_channel.dart` | 补 3 个 stub：bool 命令→`false`（app 端已自行 `Platform.isWindows` 守卫，stub 仅满足接口契约） |
| Windows 实现 | `lib/flutter_sing_box_windows.dart` | 5 方法委托 `HelperCli`；`buildRunasArgs` 参数化。**不改 `getSingBoxVersion`** |
| 新增 | `lib/src/windows/helper_cli.dart` | `HelperCli` + `HelperCliResult`，真正执行 |

## 5. 各命令行为矩阵（最终）

| facade 方法 | 子命令 | 提权 | helper.json | 超时 | 成功判定 | 返回类型 |
|-------------|--------|------|-------------|------|----------|----------|
| `queryServiceStatus` | status | 否 | 依赖已有 | 5s | 解析 stdout | `WindowsServiceStatus` |
| `installService` | install | 是 | 调用前写 | 15s + 轮询 | runas 退出码 0 且轮询到 running/stopped | `bool` |
| `uninstallService` | uninstall | 是 | 依赖已有 | 15s + 轮询 | runas 退出码 0 且轮询到 notInstalled | `bool` |
| `startService` | start | 是 | 依赖已有 | 15s + 轮询 | runas 退出码 0 且轮询到 running | `bool` |
| `stopService` | stop | 否 | 依赖已有 | 5s | helper.exe exitCode 0 | `bool` |

## 6. 文件清单

- **新增** `lib/src/windows/helper_cli.dart`：`HelperCli`（定位 exe、`_run`、`_waitUntilStatus`、`buildRunasArgs`、5 个命令执行方法 status/install/uninstall/start/stop）+ `HelperCliResult`
- **改** `lib/flutter_sing_box_windows.dart`：持有 `HelperCli` 实例，5 方法委托；`buildRunasArgs`/`waitForServiceReady` 迁入 `HelperCli`（后者泛化为 `_waitUntilStatus`）。`getSingBoxVersion` 保持不变
- **改** `lib/flutter_sing_box_platform_interface.dart`：补 3 个抽象方法声明
- **改** `lib/flutter_sing_box.dart`：facade 补 3 个委托方法
- **改** `lib/flutter_sing_box_method_channel.dart`：补 3 个 stub
- **新增** `test/helper_cli_test.dart`：纯逻辑单测（见 §7）

## 7. 测试策略

`HelperCli` 的纯逻辑全部抽成 `@visibleForTesting` 方法单测；`Process.run` 与时间通过注入隔离（沿用现有 `waitForServiceReady` 的 `queryStatus`/`delay`/`now` 注入风格）：

- `buildRunasArgs`：参数形状正确（含 `-Verb RunAs`、子命令名正确拼入 `-ArgumentList`）；install/uninstall/start 三种入参各验一次
- `WindowsServiceStatus.fromHelperOutput`：5 种已知串 + 未知串→unknown（已有，回归保障）
- `_waitUntilStatus`：命中 target→true、超时→false（注入假时钟与可控 queryStatus）
- 提权命令组合：runas 退出码非 0→直接 false（不轮询）；退出码 0→进入轮询分支

`Process.run` 本身不纳入单测（真实进程调用留作集成验证，需 Windows 环境）。

## 8. 非目标（YAGNI）

- `info` 子命令不封装（纯调试多行输出，无业务消费方）。
- `version` 子命令不封装（helper 自身版本编码串，无业务消费方；如将来需要 helper 版本校验再补）。
- **不改 `FlutterSingBoxWindows.getSingBoxVersion()`**——它返回 sing-box 内核版本，与 helper 无关。
- 不改 Go 端 `windows_helper_service`（仅作语义参考）。
- 不引入 command-object/sealed-class 调度框架（5 个命令规模不足以支撑该抽象成本）。
- 非 Windows 平台 stub 不实现真实逻辑（Android 走 VPN Service，helper 概念不适用）。
- 不在本设计内新增 app 侧（`WindowsServiceVM`）对 uninstall/start/stop 的调用——封装到位即可，消费方按需增量接入。

## 9. 风险与备注

- **提权轮询的时间窗**：UAC 同意到服务状态变更存在秒级延迟，15s deadline 应足够；若机器卡顿可能误判超时失败，可在实现后按真实表现调参。
- **回归**：`installService` 现有行为（runas + 轮询）需保持不变，本次只是把实现迁入 `HelperCli` 并泛化；`buildRunasArgs` 签名变化（加 `subCommand` 参数）需同步更新现有调用点与（若有）单测。
- **stop 的非提权前提**：依赖 helper 服务已在运行并暴露本机 HTTP API。若服务未装/未起，`helper.exe stop` 走 "not running" 分支正常退出（exitCode 0），业务层判 true——语义为"已处于非运行态"，符合预期。
