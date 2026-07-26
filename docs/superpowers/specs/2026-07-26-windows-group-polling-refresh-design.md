# Windows 端 client group 持续轮询刷新

## 背景

`FlutterSingBoxWindows._refreshClientGroup()` 当前实现为「重试 3 次、间隔 800ms、失败放弃」：

```dart
Future<void> _refreshClientGroup() async {
  const int maxAttempts = 3;
  const Duration interval = Duration(milliseconds: 800);
  for (int i = 0; i < maxAttempts; i++) {
    try {
      final groups = await ClashHttpClient().getGroups();
      emitClientGroups(groups);
      return;
    } catch (e) { /* 重试 */ }
  }
  debugPrint('拉取 proxies 最终失败,放弃本轮刷新');
}
```

它由 `emitProxyState(ProxyState.started)` fire-and-forget 触发一次（见 [flutter_sing_box_windows.dart:191-198](../../lib/flutter_sing_box_windows.dart)）。

**问题**：用户无法预知 `/proxies` 数据何时就绪或发生变化——sing-box 进程刚拉起时数据未必完整，且节点切换、URLTest 测速结果回填都会让 group 内容在连接后持续变化。固定 3 次重试不足以覆盖「数据仍在变化」的窗口。又因 [2026-07-25 clash mode stream spec](./2026-07-25-windows-clash-mode-stream-design.md) 已明确**不引入 websocket 长连接**，轮询是 Windows 端感知 group 变化的唯一手段。

## 目标

- VPN 连接（`ProxyState.started`）后，每间隔 1 秒持续调用 `ClashHttpClient().getGroups()` 并回推 `groupStream`。
- 连接断开（`ProxyState.stopped`）或插件 `dispose()` 时停止轮询。

## 非目标

- **不改 `_refreshClashMode`**：clash mode 是单值（rule/global/direct），启动后基本不变，保持「重试 3 次拉一次」现状。仅 group 因节点切换/测速会持续变化，故本次只改 group。这构成 group 与 mode 的不对称，是刻意为之。
- 不引入 websocket（沿用 2026-07-25 spec 决策）。
- 不改动对外 stream 契约：`groupStream`、`emitClientGroups`、`ClientGroup` 模型、`ProxyState` 流均不变。
- 不为轮询路径单独配置更短的 dio timeout（沿用 5s `connectTimeout`/`receiveTimeout`）。

## 设计

### 取消与并发防护：generation 计数器

新增字段 `_groupRefreshGeneration`（int，初值 0）。每次启动新一轮轮询自增并记下「自己的代」；任何取消动作（stopped / dispose）也自增，使所有在飞的旧循环在下次循环顶部条件检查时自行退出。

```dart
int _groupRefreshGeneration = 0;

/// 启动一轮新的 group 轮询；自增 generation 使上一轮自动退出，天然处理 restart 重复 started。
void _startGroupRefresh() {
  final int gen = ++_groupRefreshGeneration;
  unawaited(_refreshClientGroup(gen));
}

/// 取消所有在飞的 group 轮询。
void _cancelGroupRefresh() {
  _groupRefreshGeneration++;
}
```

### 串行轮询循环（替代重试 3 次）

```dart
Future<void> _refreshClientGroup(int gen) async {
  while (gen == _groupRefreshGeneration) {
    try {
      final groups = await ClashHttpClient().getGroups();
      // 拉取期间若已被取消（generation 变了），丢弃这次结果，避免把过期数据推给 UI。
      if (gen == _groupRefreshGeneration) {
        emitClientGroups(groups);
      }
    } catch (e) {
      debugPrint('拉取 proxies 失败: $e');
    }
    await Future.delayed(const Duration(seconds: 1));
  }
}
```

**为何串行而非 `Timer.periodic`**：`Timer.periodic` 固定周期触发，若某次 `getGroups()` 超过 1 秒（dio timeout 上限 5s），会堆积并发请求。串行循环保证「上一次完成（成功或失败）后才发下一次」，绝不重叠。风格也与现有 `_refreshClashMode` 的重试循环一致。

**首次立即拉取**：循环体先拉取再 delay，故连接后立即发出第一次请求（尽快有 UI 数据），之后每 1 秒一次。

### 触发点改动

`emitProxyState`：

```dart
void emitProxyState(ProxyState state) {
  _lastProxyState = state;
  _controller.add(state);
  if (state == ProxyState.started) {
    unawaited(_refreshClashMode());
    _startGroupRefresh();          // 替换原 unawaited(_refreshClientGroup())
  } else if (state == ProxyState.stopped) {
    _cancelGroupRefresh();         // 新增
  }
}
```

`dispose()`：在关闭各 controller 前调用 `_cancelGroupRefresh()`。

### 错误处理

- 单次 `getGroups()` 失败（dio 超时 / 连接拒绝 / JSON 解析异常）：`debugPrint` 后**继续循环**，不 `break`。持续刷新语义下，瞬时抖动不应终止整轮。
- 不设「连续失败上限」：YAGNI，用户未要求；sing-box 长时间无响应时最坏每 ~6s（5s timeout + 1s delay）一轮，开销可接受。

## 数据流

```
HelperHttpClient(start/restart/status → "started")
  └─ emitProxyState(ProxyState.started)
       ├─ unawaited(_refreshClashMode())        [不变：重试 3 次拉一次]
       └─ _startGroupRefresh()
            └─ _refreshClientGroup(gen)
                 loop:
                   ├─ ClashHttpClient.getGroups()  [GET 127.0.0.1:9090/proxies, 5s timeout]
                   ├─ emitClientGroups(groups)     [_clientGroupController.add → groupStream]
                   └─ Future.delayed(1s)

HelperHttpClient("stopped") / dispose()
  └─ emitProxyState(ProxyState.stopped) / dispose()
       └─ _cancelGroupRefresh()  → generation++  → 循环顶部 while 条件失败，退出
```

## 边界与已知行为

| 场景 | 行为 |
|------|------|
| 重复 `started`（start/restart/status 多处触发） | `_startGroupRefresh` 自增 generation，旧循环下次顶部退出，新循环启动。无并发。 |
| `await getGroups()` 期间收到取消 | 返回后 `if (gen == _groupRefreshGeneration)` 为 false，不 emit；循环退出。不推过期数据。 |
| `Future.delayed(1s)` 期间收到取消 | delay 不可中断，最多多等 ≤1s 后循环顶部退出。dispose 后 ≤1s 内彻底停止——已知行为，对后台 fire-and-forget 任务可接受。 |
| `getGroups()` 持续失败 | 循环不中断，每轮 debugPrint，~6s/轮。 |

## 测试策略

`_refreshClientGroup` 依赖单例 `ClashHttpClient`（`factory` 返回静态实例，无法注入 mock），循环逻辑不易单测——与 2026-07-25 spec 对 `_refreshClashMode` 的处理一致。

- **静态检查**：`flutter analyze --fatal-infos` 无 error/warning（重点确认 `unawaited`、`debugPrint`、新私有方法均能解析）。
- **手动验证**（`flutter run -d windows`，配合 `clash_sing_app`）：
  1. 连接 VPN → 观察 group 列表在 ~1s 内出现，之后持续每秒刷新；
  2. 连接期间切换节点 / 触发 URLTest → group 列表随之更新；
  3. 断开 VPN → 轮询停止（日志不再出现「拉取 proxies 失败」/无后续请求）；
  4. 连接 → 断开 → 再连接 → 仅有一路轮询在跑，无并发请求堆积。

## 影响面与风险

**改动符号**（实现前用 GitNexus `impact({repo: "flutter_sing_box", target: ..., direction: "upstream"})` 核实）：
- `_refreshClientGroup`（签名变更：新增 `int gen` 参数）
- `emitProxyState`（新增 `stopped` 分支，`started` 分支调用改为 `_startGroupRefresh()`）
- `dispose`（新增 `_cancelGroupRefresh()` 调用）
- 新增：`_groupRefreshGeneration` 字段、`_startGroupRefresh` / `_cancelGroupRefresh` 私有方法

**对外契约**：`groupStream` / `emitClientGroups` / `ProxyState` 流不变；`emitProxyState` 仍是 `HelperHttpClient` 的唯一调用入口。

**初步风险评估**：LOW——内部实现重构，对外 stream 契约不变；`emitProxyState` 的调用方（`HelperHttpClient`）不受签名变化影响（仍是 `void emitProxyState(ProxyState)`）。

## 实现前必做（遵循 flutter_sing_box CLAUDE.md）

1. `impact({repo: "flutter_sing_box", target: "_refreshClientGroup", direction: "upstream"})` 等核实 blast radius。
2. 实现完成后 `detect_changes({repo: "flutter_sing_box", scope: "unstaged"})` 确认影响面。
3. 回归对比用 `base_ref: "master"`（flutter_sing_box 默认分支）。
