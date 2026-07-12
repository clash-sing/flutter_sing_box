# clash_sing_helper.exe CLI 的 Dart 封装设计

- 日期：2026-07-13
- 状态：已与用户确认设计方向，待 spec 复核
- 涉及工程：`flutter_sing_box`（主要）、关联 `windows_helper_service`（Go 端，仅作语义参考，本次不改）
- 关联文档：`2026-07-13-install-service-runas-design.md`（install 的 runas 提权先行实现，本设计将其泛化到全部子命令）

## 1. 背景与目标

桌面端 `clash_sing_helper.exe`（由 `windows_helper_service` Go 工程编译）以 CLI 子命令形式管理名为 `clash_sing_service` 的 Windows 系统服务，共 6 个核心子命令：`install`、`uninstall`、`start`、`stop`、`status`、`version`（另有一个 `info` 纯调试输出，本次不封装）。

当前 `flutter_sing_box` 的 Windows 实现只封装了其中两个：

- `queryServiceStatus()` → `status`（直接 `Process.run`，5s 超时，返回 `WindowsServiceStatus` 枚举）
- `installService(HelperConfig)` → `install`（PowerShell `Start-Process -Verb RunAs` 提权，15s 超时 + 轮询，返回 `bool`）

两者风格不统一（提权方式、超时、返回类型各异），且 `uninstall`/`start`/`stop`/`version` 尚未封装。app 侧（`clash_sing_app`）的 `WindowsServiceVM` 目前只消费 `queryServiceStatus` 与 `installService`，其余命令暂无调用方，但卸载/停服务/版本校验等场景已在规划中。

**目标**：把 6 个核心子命令封装为统一的 Dart API，作为 helper CLI 的完整 Dart 投射，供 app 跨平台调用。

**成功标准**：

1. 新增 Windows 内部类 `HelperCli`，收拢"调用 helper.exe"的全部关注点（定位 exe、拼参数、提权启动、超时、stdout 解析）；`FlutterSingBoxWindows` 的 6 个服务方法只承载业务语义，全部委托 `HelperCli`。
2. 6 个命令上升到平台无关抽象（`FlutterSingBoxPlatform` + `FlutterSingBox` facade），非 Windows 平台提供 stub，app 可跨平台调用。
3. 提权命令（install/uninstall/start）轮询 `status` 确认最终状态，而非仅凭 UAC 同意判定成功。
4. `version` 解码为语义版本串（如 `"1.13.14"`）对外暴露。
5. 纯逻辑（结果解析、version 解码、runas 参数形状、轮询判定）可单测，`Process.run` 可注入隔离。

## 2. 现状分析

### 2.1 Go 端 6 个子命令的语义（`windows_helper_service/main.go`）

| 子命令 | 是否需 UAC 提权 | 是否依赖 helper.json | stdout 产出 | 行为要点 |
|--------|----------------|---------------------|-------------|----------|
| `status` | 否 | 是 | `running`/`stopped`/`notInstalled`/`unknown`/`error` | 先查 HTTP API 是否在跑，再查 SCM `srv.Status()` |
| `install` | **是** | 是 | 无 | 先 `Uninstall`→`Install`→`Start` |
| `uninstall` | **是** | 是 | 无 | 先 `Stop`→`Uninstall` |
| `start` | **是** | 是 | 无 | `srv.Start()` |
| `stop` | 否（内部走 HTTP API `ShutdownByAPI`） | 是 | 无 | 若 `running` 则 HTTP 关闭，否则打 "not running" |
| `version` | 否 | **否** | 编码串（见 §4.4） | 不读 helper.json |

注：`install`/`uninstall`/`start`/`stop` 在 Go 端失败时 `panic`（`mustReadConfig` 读不到 helper.json 也会 panic）；`status` 内部把异常归一成字符串 `"error"`。

### 2.2 Flutter 端封装现状

- `FlutterSingBoxWindows`（`lib/flutter_sing_box_windows.dart`）：实现了 `queryServiceStatus`、`installService`，含辅助方法 `buildRunasArgs`（**子命令名写死 `'install'`**）、`waitForServiceReady`（轮询到 running/stopped）、`_ensureHelperJson`（仅当 helper.json 不存在时写入，保护运行时回写的 port 字段）。
- `FlutterSingBoxPlatform`（抽象）：已声明 `queryServiceStatus`、`installService`。
- `FlutterSingBox`（facade，`lib/flutter_sing_box.dart`）：已暴露 `queryServiceStatus`、`installService`。
- `MethodChannelFlutterSingBox`（Android/iOS 等 stub）：`queryServiceStatus` 返回 `WindowsServiceStatus.unsupported`，`installService` 占位返回 `true`。
- app 侧 `WindowsServiceVM`（`clash_sing_app/lib/src/vm/windows_service_vm.dart`）：在 `build`/`refresh` 中以 `io.Platform.isWindows` 守卫，非 Windows 直接返回 `unsupported`，仅在 Windows 调用 `queryServiceStatus` / `installService`。

## 3. 设计决策（均经用户确认）

### 3.1 抽出独立 `HelperCli` 类

把"调用 helper.exe"的全部关注点从 `FlutterSingBoxWindows` 剥离到 Windows 专属内部类 `HelperCli`。平台类的 6 个服务方法只承载业务语义（写 helper.json、把结果映射成业务类型、平台守卫），执行细节委托 `HelperCli`。

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
- `version` → `String`（解码后语义串）
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

- `elevated: false` → `Process.run(helperExe.path, [subCommand]).timeout(timeout)`，等 helper.exe 退出码。用于 `status` / `stop` / `version`。
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

### 3.5 `version` 解码为语义版本

**Go 端编码规则**（`main.go` version 分支）：

```go
parts := strings.Split(interval.Version, ".")   // 如 ["1","13","14"]
result.WriteString("1")                          // 硬编码前缀 "1"
for _, p := range parts {
    num, _ := strconv.Atoi(p)
    result.WriteString(fmt.Sprintf("%02d", num)) // 每段两位零填充
}
```

故 Version=`"1.13.14"` → 输出 `"1011314"`（= `"1"` + `"01"` + `"13"` + `"14"`）；Version=`"0.0.0"`（默认/未注入）→ `"1000000"`。

**Dart 端解码规则**：去首字符（Go 硬编码的 `"1"`），剩余按每两位切分转 int，再用 `.` join。

```dart
@visibleForTesting
String decodeHelperVersion(String raw) {
  // raw 形如 "1011314" → 去首字符 "1" → "011314" → ["01","13","14"] → "1.13.14"
  if (raw.isEmpty || raw[0] != '1') return raw;
  final body = raw.substring(1);
  if (body.length % 2 != 0) return raw; // 长度异常，回退原值
  final parts = <String>[];
  for (var i = 0; i < body.length; i += 2) {
    parts.add(int.parse(body.substring(i, i + 2)).toString());
  }
  return parts.join('.');
}
```

层次划分：

- `HelperCli.version()` 返回 `HelperCliResult`（stdout 为原始编码串）；`decodeHelperVersion` 作为 `HelperCli` 的 `@visibleForTesting static` 方法，便于单测。
- facade / 平台层对外暴露两个方法：`getHelperVersion()` → 解码后语义串（如 `"1.13.14"`）；`getHelperRawVersion()` → 原始编码串（如 `"1011314"`），供调试。两者均调 `cli.version()`，区别仅在是否解码 stdout。

> 边界：Go 端 `%02d` 在某段 ≥ 100 时实际产出 ≥ 3 位，破坏定长两位编码，解码会错位。helper 版本号实践中每段 < 100（与 Go 编码能力一致）；解码遇异常长度时回退返回原值，不抛异常。实现时需用真实 helper.exe 输出验证。

### 3.6 helper.json 策略

仅 `install` 在调用前主动写 helper.json（沿用现有 `_ensureHelperJson`：仅当文件不存在时写入，保护服务运行时回写的 port 字段）。其余命令（status/stop/start/uninstall）假定 helper.json 已由先前 install 写入；若缺失，Go 端 `mustReadConfig` panic → 进程非零退出 → 被 `HelperCli` catch 转成 `HelperCliResult(ok:false)` → 业务层映射为失败值。`version` 不依赖 helper.json。

### 3.7 错误处理

任何异常（`TimeoutException`、`ProcessException`、文件缺失等）一律在 `HelperCli._run` 内 catch，转成 `HelperCliResult(ok:false, timedOut:..., stderr:...)`。平台层映射成业务失败值（`status`→`WindowsServiceStatus.error`、bool→`false`、version→空串 `''`）。不向上抛——与现状一致。

## 4. 接口落点（4 层改动）

| 层 | 文件 | 改动 |
|----|------|------|
| 抽象 | `lib/flutter_sing_box_platform_interface.dart` | 补 5 个抽象方法：`uninstallService()` / `startService()` / `stopService()` / `getHelperVersion()` / `getHelperRawVersion()`（默认 throw `UnimplementedError`） |
| facade | `lib/flutter_sing_box.dart` | 补对应委托方法，转调 `FlutterSingBoxPlatform.instance` |
| stub | `lib/flutter_sing_box_method_channel.dart` | 补 stub：bool 命令→`false`、version→`''`（app 端已自行 `Platform.isWindows` 守卫，stub 仅满足接口契约） |
| Windows 实现 | `lib/flutter_sing_box_windows.dart` | 6 方法委托 `HelperCli`；`buildRunasArgs` 参数化 |
| 新增 | `lib/src/windows/helper_cli.dart` | `HelperCli` + `HelperCliResult`，真正执行 |

## 5. 各命令行为矩阵（最终）

| facade 方法 | 子命令 | 提权 | helper.json | 超时 | 成功判定 | 返回类型 |
|-------------|--------|------|-------------|------|----------|----------|
| `queryServiceStatus` | status | 否 | 依赖已有 | 5s | 解析 stdout | `WindowsServiceStatus` |
| `installService` | install | 是 | 调用前写 | 15s + 轮询 | runas 退出码 0 且轮询到 running/stopped | `bool` |
| `uninstallService` | uninstall | 是 | 依赖已有 | 15s + 轮询 | runas 退出码 0 且轮询到 notInstalled | `bool` |
| `startService` | start | 是 | 依赖已有 | 15s + 轮询 | runas 退出码 0 且轮询到 running | `bool` |
| `stopService` | stop | 否 | 依赖已有 | 5s | helper.exe exitCode 0 | `bool` |
| `getHelperVersion` | version | 否 | 无依赖 | 5s | 解码 stdout | `String` |
| `getHelperRawVersion` | version | 否 | 无依赖 | 5s | 原样 stdout | `String` |

## 6. 文件清单

- **新增** `lib/src/windows/helper_cli.dart`：`HelperCli`（定位 exe、`_run`、`_waitUntilStatus`、`buildRunasArgs`、`decodeHelperVersion`、6 个命令执行方法 status/install/uninstall/start/stop/version）+ `HelperCliResult`。`version()` 返回原始 stdout，解码由平台层 `getHelperVersion` 调 `decodeHelperVersion` 完成。
- **改** `lib/flutter_sing_box_windows.dart`：持有 `HelperCli` 实例，6 方法委托；`buildRunasArgs`/`waitForServiceReady` 迁入 `HelperCli`（后者泛化为 `_waitUntilStatus`）
- **改** `lib/flutter_sing_box_platform_interface.dart`：补 5 个抽象方法声明
- **改** `lib/flutter_sing_box.dart`：facade 补 5 个委托方法
- **改** `lib/flutter_sing_box_method_channel.dart`：补 5 个 stub
- **新增** `test/helper_cli_test.dart`：纯逻辑单测（见 §7）

## 7. 测试策略

`HelperCli` 的纯逻辑全部抽成 `@visibleForTesting` 方法单测；`Process.run` 与时间通过注入隔离（沿用现有 `waitForServiceReady` 的 `queryStatus`/`delay`/`now` 注入风格）：

- `decodeHelperVersion`：`"1011314"`→`"1.13.14"`、`"1000000"`→`"0.0.0"`、空串/异常长度→原值
- `buildRunasArgs`：参数形状正确（含 `-Verb RunAs`、子命令名正确拼入 `-ArgumentList`）
- `WindowsServiceStatus.fromHelperOutput`：5 种已知串 + 未知串→unknown（已有，回归保障）
- `_waitUntilStatus`：命中 target→true、超时→false（注入假时钟与可控 queryStatus）
- 提权命令组合：runas 退出码非 0→直接 false（不轮询）；退出码 0→进入轮询分支

`Process.run` 本身不纳入单测（真实进程调用留作集成验证，需 Windows 环境）。

## 8. 非目标（YAGNI）

- `info` 子命令不封装（纯调试多行输出，无业务消费方）。
- 不改 Go 端 `windows_helper_service`（仅作语义参考）。
- 不引入 command-object/sealed-class 调度框架（6 个命令规模不足以支撑该抽象成本）。
- 非 Windows 平台 stub 不实现真实逻辑（Android 走 VPN Service，helper 概念不适用）。
- 不在本设计内新增 app 侧（`WindowsServiceVM`）对 uninstall/start/stop/version 的调用——封装到位即可，消费方按需增量接入。

## 9. 风险与备注

- **version 编码假设**：解码依赖"每段两位、段数任意但每段 < 100"。实现时须用真实 helper.exe（注入 Version 后）输出验证；不符则回退原值。
- **提权轮询的时间窗**：UAC 同意到服务状态变更存在秒级延迟，15s deadline 应足够；若机器卡顿可能误判超时失败，可在实现后按真实表现调参。
- **回归**：`installService` 现有行为（runas + 轮询）需保持不变，本次只是把实现迁入 `HelperCli` 并泛化；`buildRunasArgs` 签名变化（加 `subCommand` 参数）需同步更新现有调用点与（若有）单测。
