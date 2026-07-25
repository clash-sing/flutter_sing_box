# Windows 端 clashModeStream 实现设计

- **日期**：2026-07-25
- **工程**：`flutter_sing_box`（插件）
- **状态**：已确认，待实现
- **关联**：补全 Windows 平台实现，对应 Android（method channel）已有的 `clashModeStream` 能力

## 1. 背景与动机

Windows 平台通过 `clash_sing_helper.exe` 托管的系统服务运行 sing-box，App 经 `HelperHttpClient`（HTTP API）控制连接。与 Android 不同，Windows 没有 Flutter EventChannel，所有内核状态都需主动 HTTP 拉取或由 helper 回调推送。

当前 `FlutterSingBoxWindows` 已用「`StreamController` + `emitXxx` 回调 + `async*` 缓存首值」的模式实现了 `proxyStateStream`（见 `flutter_sing_box_windows.dart`），但 `clashModeStream` 仅剩一处**无方法体的抽象 getter 占位**（编译期即非法），尚未实现。

App 侧 `clashModeStreamProvider`（`clash_sing_app`）会消费此 stream：

- `ClashModeSwitch`：根据 `modes` 渲染模式切换按钮、按 `currentMode` 高亮；
- `HomeProxiesVM`：仅当 `currentMode` 为 `rule` / `global` 时才展示代理 outbound 列表。

因此 Windows 端连接成功后必须推送一次 `ClientClashMode`，否则上述 UI 在 Windows 上始终拿不到数据。

## 2. 目标与非目标

### 目标

- 实现 `FlutterSingBoxWindows.clashModeStream`，行为与 `proxyStateStream` 一致（新订阅者立即拿到最近一次模式）。
- VPN 连接成功后（`start` / `restart` / `status` 三处检测到 started），主动拉取 sing-box Clash API 的代理模式并推送到 `clashModeStream`。
- 映射 `ClashConfigs` → `ClientClashMode`。

### 非目标（本次不做）

- **不实现** `setClashMode`（Windows 端切换模式，对应 `ClashHttpClient` PATCH `/configs`）。已知后果：`ClashModeSwitch` 点击切换在 Windows 端会抛 `UnimplementedError`，留作后续独立工作。
- 不改 platform interface、method channel 实现、`FlutterSingBox` facade、App 侧代码。
- 不引入 websocket 长连接（`ClashHttpClient` 注释里列出的 connections/memory/traffic ws 端点不在本次范围）。

## 3. 现状分析

### 3.1 已有的「started」时机点

`HelperHttpClient` 三处在连接成功后调用 `_platform.emitProxyState(ProxyState.started)`：

| 方法 | 位置 | 场景 |
|------|------|------|
| `start()` | `helper_http_client.dart:44` | 首次连接 |
| `restart()` | `helper_http_client.dart:76` | 重载配置 / 重连 |
| `status()` | `helper_http_client.dart:91` | `init()` 时检测到服务已在 running，恢复状态 |

三处均需刷新 clashMode，覆盖「首次连接 / 重连 / App 启动恢复」全部场景。

### 3.2 数据映射

`ClashConfigs`（`GET /configs` 响应）与 `ClientClashMode` 字段对应关系：

| `ClashConfigs` | `ClientClashMode` |
|----------------|-------------------|
| `String mode` | `String currentMode` |
| `List<String> modeList`（`mode-list`） | `List<String> modes` |

映射是 1:1 直译。

### 3.3 impact 分析结论（编辑前已跑）

- **`HelperHttpClient`（MEDIUM）**：直接调用方为 `FlutterSingBoxWindows` 的 `init` / `startVpn` / `stopVpn` / `serviceReload`。本次仅改其内部「started 后」副作用，对外方法签名 `Future<void>` 不变，调用方无破坏。
- **`emitProxyState`（LOW，0 upstream）**：新增平行方法 `emitClashMode` 同样安全（仅由 `HelperHttpClient` 经 `_platform` 动态分发调用）。
- **`clashModeStream`（4 候选均 LOW）**：含 `FlutterSingBox` facade、`FlutterSingBoxPlatform` 接口、`MethodChannelFlutterSingBox`、`MockFlutterSingBoxPlatform`（测试）。本次只实现 `FlutterSingBoxWindows` 的版本，其余不动，测试 mock 不受影响。

## 4. 详细设计

### 4.1 `clash_http_client.dart` — 新增 `getClashMode()`

在 `ClashHttpClient` 内集中映射逻辑，`HelperHttpClient` 只负责调用，不关心字段映射。

```dart
import 'package:flutter_sing_box/src/data/models/client/client_clash_mode.dart';
// 现有 import: clash_configs.dart

/// 拉取并映射 Clash 代理模式。
Future<ClientClashMode> getClashMode() async {
  final configs = await getConfigs();
  return ClientClashMode(
    modes: configs.modeList,
    currentMode: configs.mode,
  );
}
```

> 选用直接 `import` 模型文件路径（与现有 `clash_configs.dart` import 风格一致），不 import barrel `flutter_sing_box.dart`，避免潜在的循环依赖。

### 4.2 `flutter_sing_box_windows.dart` — 补全 stream 基础设施

完全复刻 `proxyStateStream` 的结构：

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

@override
Stream<ClientClashMode> get clashModeStream async* {
  if (_lastClashMode != null) yield _lastClashMode!; // 新订阅者立即拿到当前模式
  yield* _clashModeController.stream;
}
```

`dispose()` 增加关闭新 controller：

```dart
void dispose() {
  _proxyStateStreamController?.close();
  _proxyStateStreamController = null;
  _clashModeStreamController?.close();
  _clashModeStreamController = null;
}
```

> 替换掉当前文件中非法的抽象占位 `Stream<ClientClashMode> get clashModeStream;` 与未使用的 `Stream<ClientClashMode>? _clashModeStream;` 字段。

### 4.3 `helper_http_client.dart` — 三处触发刷新

新增私有方法（含重试，见 §5），并在三处 `emitProxyState(started)` 之后以 fire-and-forget 方式调用：

```dart
import 'dart:async'; // unawaited
import 'package:flutter_sing_box/src/windows/clash_http_client.dart';

/// 连接成功后拉取代理模式并推送。fire-and-forget,失败不影响 proxyState 流。
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

三处调用点（每处在 `emitProxyState(ProxyState.started)` 之后追加一行）：

- `start()`：`_platform.emitProxyState(ProxyState.started);` 之后 → `unawaited(_refreshClashMode());`
- `restart()`：同上
- `status()`：`result.data == 'running'` 分支内 `emitProxyState(started)` 之后 → `unawaited(_refreshClashMode());`

> 用 `unawaited` 明示 fire-and-forget：`startVpn` 不必等模式拉取完成即可返回，UI 先收到 `started`（连接成功），模式在重试窗口内跟上（见 §5 时序说明）。

## 5. 错误处理与竞态

**问题**：helper `/start` 返回 `success` 仅代表 sing-box 进程已被拉起，Clash API（`127.0.0.1:9090`）未必立即就绪，立即请求大概率 `connection refused`。

**策略**：`_refreshClashMode()` 内固定间隔重试 3 次（800ms × 2 次等待 = 1.6s 间隔），任一成功即 emit 并提前返回；全部失败仅 `debugPrint`，**不抛出、不阻断 `proxyState` 流、不影响 `startVpn` 返回**。

**时序**：9090 未就绪时通常表现为即时 `connection refused`，故正常路径下整个重试窗口约 1.6s + 3 次快速失败耗时，模式可在连接成功后约 1～2s 内推送到 UI。

**已知最坏情况**：`ClashHttpClient` 的 dio `connectTimeout` / `receiveTimeout` 均为 5s。若 9090 端口已被监听但 sing-box 尚未准备好处理请求，单次请求最长 hang 5s，3 次最坏约 15s+。该情况不影响 `startVpn` 返回（fire-and-forget），仅推迟 mode 到达。本次不引入更激进的短 timeout，记录为已知行为；若实测频繁出现，再为拉取路径单独配置更短的 dio timeout。

**为何 fire-and-forget**：`proxyState` 已先 emit `started`，UI 能立即反映连接成功；模式晚 ~1s 跟上体验更连贯，且避免 `startVpn` 被重试阻塞导致连接按钮长时间转圈。

**为何不用 `Stream.multi` / 监听 `proxyStateStream`**：当前 `proxyStateStream` 用 `async*` 已有极窄竞态（代码现有注释），且在平台层自监听需管理订阅生命周期，复杂度更高。直接在 helper 三处触发最贴合现有 `emitProxyState` 反向回调架构，改动集中。

## 6. 数据流

```
helper /start (或 /restart, /status=running)
  ├─ emitProxyState(started)            → proxyStateStream → UI 显示「已连接」
  └─ unawaited(_refreshClashMode())
        └─ ClashHttpClient.getClashMode()   [GET 127.0.0.1:9090/configs, 含重试]
              └─ emitClashMode(ClientClashMode)
                    └─ clashModeStream controller
                          └─ App clashModeStreamProvider
                                ├─ ClashModeSwitch（模式按钮高亮）
                                └─ HomeProxiesVM（按 mode 决定是否展示代理列表）
```

## 7. 影响面与风险

| 改动 | 风险 | 说明 |
|------|------|------|
| `HelperHttpClient.start/restart/status` 内部追加 `unawaited(_refreshClashMode())` | MEDIUM（核心 VPN 流程） | 对外签名不变；`_refreshClashMode` 全程 catch，不会让原有 start/restart/status 抛出新异常 |
| `FlutterSingBoxWindows` 新增 `emitClashMode` / 实现 `clashModeStream` / 改 `dispose` | LOW | 纯补全；`clashModeStream` 原本就无法编译，实现后反而修复 |
| `ClashHttpClient.getClashMode()` 新增 | LOW | 纯新增方法 |

提交前按工程约定跑 `detect_changes({repo: "flutter_sing_box", scope: "compare", base_ref: "master"})` 核对受影响符号与执行流，确认无意外扩散。

## 8. 验证方式

无单元测试可覆盖（依赖真实 HTTP + sing-box 进程就绪时序），采用：

1. `flutter analyze --fatal-infos`（flutter_sing_box 工程）无报错；
2. 无 `@JsonSerializable` 模型改动，`build_runner` 非必需（实现时确认）；
3. 手动（clash_sing_app on Windows）：
   - 连接 VPN 后 `ClashModeSwitch` 显示当前模式、`HomeProxiesVM` 按 `rule`/`global` 正确展示代理列表；
   - 「重载配置」（restart）后模式刷新；
   - App 启动时服务已在 running（status 恢复路径）后模式刷新；
   - 断开重连后模式刷新。

## 9. 后续工作（不在本次范围）

- Windows 端 `setClashMode`：`ClashHttpClient` PATCH `/configs` 传 `{"mode": "..."}`，成功后重新拉取刷新流，使 `ClashModeSwitch` 切换可用。
- 若后续需要模式实时变化感知，可评估 websocket（`ClashHttpClient` 注释中的 ws 端点）。
