# Windows 端 clashModeStream 实现 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 让 Windows 端 VPN 连接成功后主动拉取 sing-box Clash API 的代理模式，并通过 `clashModeStream` 推送给 UI。

**Architecture:** 复刻 `FlutterSingBoxWindows` 现有的 `proxyStateStream` 模式（`StreamController.broadcast` + `emitXxx` 反向回调 + `async*` 缓存首值），由 `HelperHttpClient` 在 start/restart/status 三处「started」后 fire-and-forget 触发 `ClashHttpClient.getClashMode()` 拉取并回推。

**Tech Stack:** Dart 3.9 / Flutter ≥3.3、dio（HTTP）、`dart:async`（`StreamController`/`unawaited`/`Future.delayed`）、`flutter_test`（仅纯逻辑可单测）。

## Global Constraints

- **代码注释与 commit 消息**一律使用简体中文。
- **本次只实现读取流**；`setClashMode`（PATCH /configs）不实现，留作后续。
- **不改动** platform interface、`flutter_sing_box_method_channel.dart`、`FlutterSingBox` facade、App 侧（`clash_sing_app`）任何代码。
- **不手改** `*.g.dart`；本次无 `@JsonSerializable` 模型改动，**无需运行 build_runner**。
- 改动前已完成 impact 分析（结论见 spec §3.3）：`HelperHttpClient` MEDIUM（内部改动、对外签名不变），其余 LOW。
- 工作分支为 `develop`；最终回归用 `detect_changes({repo: "flutter_sing_box", scope: "compare", base_ref: "master"})`（flutter_sing_box 默认分支为 master）。
- 关键前置：当前 `lib/flutter_sing_box_windows.dart` 的 `clashModeStream` getter 无方法体，整个 lib 编译不过。Task 1 必须先修复，后续 task 的测试才能运行。

**关联 spec：** `docs/superpowers/specs/2026-07-25-windows-clash-mode-stream-design.md`

---

## File Structure

| 文件 | 职责 | 本次动作 |
|------|------|----------|
| `lib/src/windows/clash_http_client.dart` | Clash API 客户端；新增 `modeFromConfigs`（纯映射）+ `getClashMode`（拉取并映射） | Modify |
| `lib/flutter_sing_box_windows.dart` | Windows 平台实现；补全 `clashModeStream` 基础设施（controller/缓存/emit/getter/dispose） | Modify |
| `lib/src/windows/helper_http_client.dart` | helper HTTP 客户端；三处「started」后触发 `_refreshClashMode` | Modify |
| `test/clash_http_client_test.dart` | 映射纯逻辑单测 | Create |
| `test/flutter_sing_box_windows_test.dart` | stream 契约单测（不依赖 HTTP） | Create |

映射逻辑从 spec 中的「内联于 `getClashMode`」抽为 `ClashHttpClient.modeFromConfigs` 静态纯方法，使唯一的业务逻辑（字段映射）可单测；`getClashMode` 仅负责 HTTP + 调用映射。这是对 spec 的小幅可测性改进，不改变其意图。

---

## Task 1: FlutterSingBoxWindows 的 clashModeStream 基础设施

修复当前编译不过的占位 getter，并补齐与 `proxyStateStream` 一致的 stream 基础设施。这是后续所有任务测试能运行的前置。

**Files:**
- Modify: `lib/flutter_sing_box_windows.dart`（替换 L200-203 的占位字段与抽象 getter；改 `dispose`）
- Test: `test/flutter_sing_box_windows_test.dart`（Create）

**Interfaces:**
- Consumes: `ClientClashMode`（来自 barrel `package:flutter_sing_box/flutter_sing_box.dart`，已 import）
- Produces: `void emitClashMode(ClientClashMode mode)` —— 供 Task 3 的 `HelperHttpClient` 经 `_platform.emitClashMode(...)` 反向回调；`Stream<ClientClashMode> get clashModeStream` —— 供 App 侧 `clashModeStreamProvider` 消费。

- [ ] **Step 1: 写失败的 stream 契约测试**

创建 `test/flutter_sing_box_windows_test.dart`：

```dart
import 'package:flutter_sing_box/flutter_sing_box.dart';
import 'package:flutter_sing_box/flutter_sing_box_windows.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('FlutterSingBoxWindows.clashModeStream', () {
    test('emitClashMode 后 stream 推送该模式（缓存路径）', () async {
      final platform = FlutterSingBoxWindows();
      final mode = ClientClashMode(
        modes: ['rule', 'global', 'direct'],
        currentMode: 'global',
      );

      platform.emitClashMode(mode);

      final result = await platform.clashModeStream.first;
      expect(result.currentMode, 'global');
      expect(result.modes, ['rule', 'global', 'direct']);
    });
  });
}
```

- [ ] **Step 2: 跑测试确认失败（red）**

Run: `flutter test test/flutter_sing_box_windows_test.dart`
Expected: 编译失败——`FlutterSingBoxWindows` 是具体类却含无方法体的 `clashModeStream` 抽象 getter（且 `emitClashMode` 未定义）。这是预期的 red。

- [ ] **Step 3: 实现 stream 基础设施**

修改 `lib/flutter_sing_box_windows.dart`：

3a. 把现有的占位字段与抽象 getter（原 L200-203）：

```dart
  Stream<ClientClashMode>? _clashModeStream;

  @override
  Stream<ClientClashMode> get clashModeStream;
```

替换为完整的 controller / 缓存 / emit / getter（紧接 `proxyStateStream` 实现之后）：

```dart
  StreamController<ClientClashMode>? _clashModeStreamController;
  ClientClashMode? _lastClashMode;

  StreamController<ClientClashMode> get _clashModeController {
    _clashModeStreamController ??= StreamController<ClientClashMode>.broadcast();
    return _clashModeStreamController!;
  }

  /// 供 HelperHttpClient 在连接成功后回调,取代直接访问 controller。
  void emitClashMode(ClientClashMode mode) {
    _lastClashMode = mode;
    _clashModeController.add(mode);
  }

  /// TODO: async* 的理论竞态,可改为 Stream.multi。但竞态窗口极窄,与 proxyStateStream 一致。
  @override
  Stream<ClientClashMode> get clashModeStream async* {
    if (_lastClashMode != null) yield _lastClashMode!; // 新订阅者立即拿到当前模式
    yield* _clashModeController.stream;
  }
```

3b. 把 `dispose()` 从：

```dart
  void dispose() {
    _proxyStateStreamController?.close();
    _proxyStateStreamController = null;
  }
```

改为同时关闭 clashMode controller：

```dart
  void dispose() {
    _proxyStateStreamController?.close();
    _proxyStateStreamController = null;
    _clashModeStreamController?.close();
    _clashModeStreamController = null;
  }
```

- [ ] **Step 4: 跑测试确认通过（green）**

Run: `flutter test test/flutter_sing_box_windows_test.dart`
Expected: PASS（1 个测试）。同时确认整个 lib 恢复编译。

- [ ] **Step 5: 静态分析**

Run: `flutter analyze lib/flutter_sing_box_windows.dart test/flutter_sing_box_windows_test.dart`
Expected: 无 error/warning。

- [ ] **Step 6: 提交**

```bash
git add lib/flutter_sing_box_windows.dart test/flutter_sing_box_windows_test.dart
git commit -m "feat(windows): 实现 clashModeStream 基础设施(controller/缓存/emit)"
```

---

## Task 2: ClashHttpClient 映射 + getClashMode

把 `ClashConfigs` → `ClientClashMode` 的映射抽为静态纯方法并单测，再包一层 `getClashMode()` 做 HTTP 拉取。

**Files:**
- Modify: `lib/src/windows/clash_http_client.dart`
- Test: `test/clash_http_client_test.dart`（Create）

**Interfaces:**
- Consumes: `getConfigs()`（同文件已有）、`ClashConfigs`（已 import）、`ClientClashMode`（需新增 import）
- Produces: `static ClientClashMode modeFromConfigs(ClashConfigs configs)` —— 纯映射，Task 2 自测；`Future<ClientClashMode> getClashMode()` —— Task 3 的 `_refreshClashMode` 调用。

- [ ] **Step 1: 写失败的映射测试**

创建 `test/clash_http_client_test.dart`：

```dart
import 'package:flutter_sing_box/flutter_sing_box.dart';
import 'package:flutter_sing_box/src/data/models/clash/clash_configs.dart';
import 'package:flutter_sing_box/src/windows/clash_http_client.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ClashHttpClient.modeFromConfigs', () {
    test('mode/modeList 映射到 currentMode/modes', () {
      final configs = ClashConfigs(
        port: 7890,
        socksPort: 7891,
        redirPort: 0,
        tproxyPort: 0,
        mixedPort: 7892,
        allowLan: false,
        bindAddress: '*',
        mode: 'rule',
        modeList: ['rule', 'global', 'direct'],
        logLevel: 'info',
        ipv6: false,
      );

      final mode = ClashHttpClient.modeFromConfigs(configs);

      expect(mode.currentMode, 'rule');
      expect(mode.modes, ['rule', 'global', 'direct']);
    });
  });
}
```

- [ ] **Step 2: 跑测试确认失败（red）**

Run: `flutter test test/clash_http_client_test.dart`
Expected: 编译失败——`modeFromConfigs` 未定义。

- [ ] **Step 3: 实现 modeFromConfigs + getClashMode**

修改 `lib/src/windows/clash_http_client.dart`：

3a. 在文件顶部 import 区追加（紧跟现有 `clash_configs.dart` import 之后）：

```dart
import 'package:flutter_sing_box/src/data/models/client/client_clash_mode.dart';
```

3b. 在 `getConfigs()` 方法之后、类闭合 `}` 之前，追加：

```dart
  /// 将 [ClashConfigs] 映射为 UI 层使用的 [ClientClashMode]（纯函数,可单测）。
  static ClientClashMode modeFromConfigs(ClashConfigs configs) {
    return ClientClashMode(
      modes: configs.modeList,
      currentMode: configs.mode,
    );
  }

  /// 拉取 /configs 并映射为代理模式,供连接成功后刷新 clashModeStream。
  Future<ClientClashMode> getClashMode() async {
    final configs = await getConfigs();
    return modeFromConfigs(configs);
  }
```

- [ ] **Step 4: 跑测试确认通过（green）**

Run: `flutter test test/clash_http_client_test.dart`
Expected: PASS（1 个测试）。

- [ ] **Step 5: 静态分析**

Run: `flutter analyze lib/src/windows/clash_http_client.dart test/clash_http_client_test.dart`
Expected: 无 error/warning。

- [ ] **Step 6: 提交**

```bash
git add lib/src/windows/clash_http_client.dart test/clash_http_client_test.dart
git commit -m "feat(windows): ClashHttpClient 新增 getClashMode/modeFromConfigs 映射"
```

---

## Task 3: HelperHttpClient 三处触发刷新

在 start/restart/status 三处 `emitProxyState(started)` 之后，fire-and-forget 触发 `_refreshClashMode()`（含 3 次 ×800ms 重试）。

**Files:**
- Modify: `lib/src/windows/helper_http_client.dart`

**Interfaces:**
- Consumes: `ClashHttpClient().getClashMode()`（Task 2 产出）、`_platform.emitClashMode(ClientClashMode)`（Task 1 产出）、`_platform`（同文件已有 getter）
- Produces: 无新增对外符号（仅私有 `_refreshClashMode`，不改 start/stop/restart/status 签名）。

> **关于单测：** 本任务依赖真实 HTTP（`127.0.0.1:9090`）与 helper 反向回调 `_platform.emitClashMode`，无法在 `flutter_test` 环境隔离，故不写单元测试；正确性由 Step 2 的 `flutter analyze` + Task 4 的手动验证覆盖。`_refreshClashMode` 全程 `try/catch`，绝不会让原有 start/restart/status 抛出新异常。

- [ ] **Step 1: 实现 _refreshClashMode 与三处触发**

修改 `lib/src/windows/helper_http_client.dart`：

1a. 文件顶部 import 区追加（现有已有 `dart:convert` / `dart:io` / dio / flutter_sing_box / platform_interface / windows_constants / path）：

```dart
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_sing_box/src/windows/clash_http_client.dart';
```

> 注：`debugPrint` 来自 `package:flutter/foundation.dart`，确认未与现有 import 重复后再加；若已存在则跳过该行。

1b. 在 `status()` 方法之后、`_getHelperConfig()` 之前，新增私有方法：

```dart
  /// 连接成功后拉取代理模式并回推到 clashModeStream。
  ///
  /// fire-and-forget: 失败仅 debugPrint,不影响 proxyState 流、不阻塞 start/restart。
  /// 9090 在 sing-box 进程刚拉起时未必就绪,故重试 3 次、间隔 800ms。
  Future<void> _refreshClashMode() async {
    const int maxAttempts = 3;
    const Duration interval = Duration(milliseconds: 800);
    for (int i = 0; i < maxAttempts; i++) {
      try {
        final mode = await ClashHttpClient().getClashMode();
        _platform.emitClashMode(mode);
        return;
      } catch (e) {
        debugPrint('helper 拉取 clash mode 失败 (第 ${i + 1}/$maxAttempts 次): $e');
        if (i < maxAttempts - 1) {
          await Future.delayed(interval);
        }
      }
    }
    debugPrint('helper 拉取 clash mode 最终失败,放弃本轮刷新');
  }
```

1c. 在三处 `emitProxyState(ProxyState.started)` 之后各追加一行 `unawaited(_refreshClashMode());`：

- `start()`：`if (result.data == successValue)` 分支内，`_platform.emitProxyState(ProxyState.started);` 之后；
- `restart()`：同分支内 `emitProxyState(ProxyState.started);` 之后；
- `status()`：`if (result.data == 'running')` 分支内 `emitProxyState(ProxyState.started);` 之后。

每处形如：

```dart
        _platform.emitProxyState(ProxyState.started);
        unawaited(_refreshClashMode());
```

- [ ] **Step 2: 静态分析**

Run: `flutter analyze lib/src/windows/helper_http_client.dart`
Expected: 无 error/warning（重点确认 `unawaited`、`debugPrint`、`ClashHttpClient`、`emitClashMode` 均能解析）。

- [ ] **Step 3: 提交**

```bash
git add lib/src/windows/helper_http_client.dart
git commit -m "feat(windows): 连接成功后刷新 clashMode(start/restart/status 三处)"
```

---

## Task 4: 全局验证与回归核对

无新增代码产出，作为独立 reviewer gate：全量分析、回归核对、手动验证。

**Files:** 无（仅运行命令与核对）。

- [ ] **Step 1: 全量静态分析**

Run: `flutter analyze --fatal-infos`
Expected: 无 issue（CI 同口径）。

- [ ] **Step 2: 全量测试**

Run: `flutter test`
Expected: 全部 PASS（含 Task 1/2 新增的两个测试，以及既有 `flutter_sing_box_test.dart` 的默认实例测试）。

- [ ] **Step 3: 确认无需 build_runner**

Run: `git status --short`
Expected: `lib/` 下无 `*.g.dart` 被改动（本次无模型注解变更）；若意外出现生成文件变动，运行 `dart run build_runner build --delete-conflicting-outputs` 后重新核对。

- [ ] **Step 4: GitNexus 回归核对**

调用 MCP：
```
detect_changes({repo: "flutter_sing_box", scope: "compare", base_ref: "master"})
```
Expected: 受影响符号限定于 `HelperHttpClient.start/restart/status`、`FlutterSingBoxWindows.clashModeStream/emitClashMode/dispose`、`ClashHttpClient.getClashMode/modeFromConfigs`，及其所在的 `init` 执行流；无预期外符号/流程被波及。若有意外扩散，停下排查。

- [ ] **Step 5: 手动验证（需在 Windows 真机跑 clash_sing_app）**

逐项确认：
1. 连接 VPN 后，`ClashModeSwitch` 高亮当前模式、`HomeProxiesVM` 在 rule/global 下展示代理 outbound 列表；
2. 「重载配置」（走 restart）后，模式刷新；
3. 退出 App 再启动（服务仍在 running，走 status 恢复路径）后，模式刷新；
4. 断开重连后，模式刷新。

> 若 Step 5 由用户执行，需把结果反馈回来再视为本计划完成。

- [ ] **Step 6: 收尾**

若 Step 1-5 全部通过，本计划完成，无需额外 commit（代码已在 Task 1-3 提交）。若验证中发现缺陷，按缺陷所在回退到对应 Task 修复后新建 commit。

---

## Self-Review（plan 自查记录）

- **Spec 覆盖**：spec §4.1 映射 → Task 2；§4.2 stream 基础设施 → Task 1；§4.3 三处触发 → Task 3；§5 重试策略 → Task 3 的 `_refreshClashMode`；§7 影响面/§8 验证 → Task 4。spec §9 后续工作（setClashMode）明确不在范围，无对应 task，正确。
- **占位符**：无 TBD/TODO（代码注释里的 TODO 是保留给后续 Stream.multi 优化的有意标注，非计划占位）。所有 step 含确切代码或命令。
- **类型一致**：`emitClashMode(ClientClashMode)`、`modeFromConfigs(ClashConfigs)→ClientClashMode`、`getClashMode()→Future<ClientClashMode>` 在 Task 1/2/3 间命名与签名一致。
- **顺序依赖**：Task 1 先修复编译（前置）→ Task 2 映射（被 Task 3 依赖）→ Task 3 触发（消费 Task 1+2）→ Task 4 验证。
