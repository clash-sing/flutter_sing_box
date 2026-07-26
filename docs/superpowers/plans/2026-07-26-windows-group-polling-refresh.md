# Windows 端 client group 持续轮询刷新 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 把 `_refreshClientGroup` 从「重试 3 次放弃」改为「连接后每秒持续轮询 `/proxies`，断开/销毁时取消」。

**Architecture:** 串行 `while` 循环（拉取 → emit → 等 1 秒）替代固定重试；用 `_groupRefreshGeneration` 计数器做取消与重复 `started` 的并发防护。触发点 `emitProxyState` 增加 `stopped` 分支，`dispose` 增加取消调用。沿用现有 `StreamController.broadcast` + `emitClientGroups` 反向回调 + `groupStream` 缓存首值的对外契约，不改 stream/模型/`_refreshClashMode`。

**Tech Stack:** Dart, Flutter plugin（`StreamController.broadcast` 模式）, dio（`ClashHttpClient` 单例）。

## Global Constraints

- 代码注释与 Git commit 消息使用**简体中文**。
- 轮询间隔**固定 1 秒**；单次 `getGroups()` 失败**不中断循环、不设连续失败上限**，仅 `debugPrint`。
- **不改** `_refreshClashMode`、对外 stream 契约（`groupStream` / `emitClientGroups` / `ClientGroup` / `ProxyState`）、dio `connectTimeout`/`receiveTimeout`（保持 5s）。
- **不引入** websocket（沿用 2026-07-25 spec 决策）。
- 无 `@JsonSerializable` 模型改动，**无需 build_runner**。
- 改 symbol 前跑 GitNexus `impact({repo: "flutter_sing_box", target, direction: "upstream"})`；commit 前跑 `detect_changes({repo: "flutter_sing_box", scope: "unstaged"})`；回归对比 `base_ref: "master"`（flutter_sing_box 默认分支）。
- 测试策略：`_refreshClientGroup` 依赖单例 `ClashHttpClient`（`factory` 不可注入），循环逻辑**不写单测**，验收走 `flutter analyze --fatal-infos` + `detect_changes` + 手动验证（与 2026-07-25 spec 对 `_refreshClashMode` 一致）。
- `dart:async`（`unawaited` / `Future.delayed`）与 `flutter/foundation`（`debugPrint`）已 import，无需新增 import。
- `ProxyState.stopped` 枚举值已存在（[flutter_sing_box_windows.dart:179](../../lib/flutter_sing_box_windows.dart) 已在用）。

---

## File Structure

- Modify: `lib/flutter_sing_box_windows.dart`（唯一改动文件，<60 行净变更）
  - 新增字段：`_groupRefreshGeneration`
  - 新增私有方法：`_startGroupRefresh()`、`_cancelGroupRefresh()`
  - 改签名+实现：`_refreshClientGroup(int gen)`
  - 改 `emitProxyState`：`started` 分支改调 `_startGroupRefresh()`，新增 `stopped` 分支
  - 改 `dispose()``：首行加 `_cancelGroupRefresh()`

---

## Task 1: impact 核实 + 实现 group 持续轮询

**Files:**
- Modify: `lib/flutter_sing_box_windows.dart`

**Interfaces:**
- Consumes: `ClashHttpClient().getGroups()` → `Future<List<ClientGroup>>`（已存在，[clash_http_client.dart:47](../../lib/src/windows/clash_http_client.dart)）；`emitClientGroups(List<ClientGroup>)`（同类已存在）；`ProxyState.started` / `ProxyState.stopped`（已存在）。
- Produces: 无新对外接口。`_refreshClientGroup` 变为私有 `Future<void> _refreshClientGroup(int gen)`（仅同类内 `_startGroupRefresh` 调用）；`emitProxyState(ProxyState)` 对外签名不变（`HelperHttpClient` 调用方不受影响）。

- [ ] **Step 1: 改动前跑 GitNexus impact 核实 blast radius**

对以下三个 symbol 调用 MCP 工具（`repo: "flutter_sing_box"`），向用户汇报直接调用方、受影响执行流、风险等级：

```
impact({repo: "flutter_sing_box", target: "_refreshClientGroup", direction: "upstream"})
impact({repo: "flutter_sing_box", target: "emitProxyState", direction: "upstream"})
impact({repo: "flutter_sing_box", target: "dispose", direction: "upstream"})
```

Expected: `_refreshClientGroup` 上游仅 `emitProxyState`；`emitProxyState` 上游为 `HelperHttpClient`（start/restart/status 三处 started 回调）；`dispose` 上游为插件销毁路径。风险 LOW。若 MCP 未连接 `flutter_sing_box` 索引（报错），用 grep 兜底——已确认：`_refreshClientGroup` 仅 [emitProxyState:196](../../lib/flutter_sing_box_windows.dart) 一处调用，`emitProxyState` 仅供 `HelperHttpClient` 调用。若出现 HIGH/CRITICAL，停下向用户报告。

- [ ] **Step 2: 替换 `_refreshClientGroup` —— 改签名 + 新增字段与两个辅助方法**

用 Edit 工具，`old_string` 为原 `_refreshClientGroup` 全文（[flutter_sing_box_windows.dart:222-238](../../lib/flutter_sing_box_windows.dart)，含前导空格 2 格缩进）：

```
  Future<void> _refreshClientGroup() async {
    const int maxAttempts = 3;
    const Duration interval = Duration(milliseconds: 800);
    for (int i = 0; i < maxAttempts; i++) {
      try {
        final groups = await ClashHttpClient().getGroups();
        emitClientGroups(groups);
        return;
      } catch (e) {
        debugPrint('拉取 proxies 失败 (第 ${i + 1}/$maxAttempts 次): $e');
        if (i < maxAttempts - 1) {
          await Future.delayed(interval);
        }
      }
    }
    debugPrint('拉取 proxies 最终失败,放弃本轮刷新');
  }
```

`new_string`（字段 + 两方法 + 新版 `_refreshClientGroup`）：

```dart
  /// group 轮询的「代」：每次启动新一轮自增，使上一轮自动退出；
  /// stopped / dispose 也自增以取消所有在飞轮询。
  int _groupRefreshGeneration = 0;

  /// 启动一轮新的 group 轮询；自增 generation 使上一轮自动退出，
  /// 天然处理 start/restart/status 多处重复触发 started 的并发防护。
  void _startGroupRefresh() {
    final int gen = ++_groupRefreshGeneration;
    unawaited(_refreshClientGroup(gen));
  }

  /// 取消所有在飞的 group 轮询（stopped / dispose 调用）。
  void _cancelGroupRefresh() {
    _groupRefreshGeneration++;
  }

  /// 连接成功后每秒持续拉取 proxies 回推 groupStream，直到 stopped / dispose 取消。
  ///
  /// fire-and-forget: 失败仅 debugPrint、不中断循环、不影响 proxyState 流。
  /// 串行循环（上一次完成才发下一次）避免请求重叠；用 [gen] 配合
  /// [_groupRefreshGeneration] 做取消与重复 started 的并发防护。
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

- [ ] **Step 3: 改 `emitProxyState` —— started 改调启动、新增 stopped 取消**

`old_string`（[flutter_sing_box_windows.dart:191-198](../../lib/flutter_sing_box_windows.dart)）：

```
  void emitProxyState(ProxyState state) {
    _lastProxyState = state;
    _controller.add(state);
    if (state == ProxyState.started) {
      unawaited(_refreshClashMode());
      unawaited(_refreshClientGroup());
    }
  }
```

`new_string`：

```dart
  void emitProxyState(ProxyState state) {
    _lastProxyState = state;
    _controller.add(state);
    if (state == ProxyState.started) {
      unawaited(_refreshClashMode());
      _startGroupRefresh();
    } else if (state == ProxyState.stopped) {
      _cancelGroupRefresh();
    }
  }
```

- [ ] **Step 4: 改 `dispose` —— 销毁前取消轮询**

`old_string`（[flutter_sing_box_windows.dart:288-289](../../lib/flutter_sing_box_windows.dart)）：

```
  void dispose() {
    _proxyStateStreamController?.close();
```

`new_string`：

```dart
  void dispose() {
    _cancelGroupRefresh();
    _proxyStateStreamController?.close();
```

- [ ] **Step 5: 静态分析**

Run（在 `d:\projs_dg\flutter_sing_box` 下）：
```
flutter analyze --fatal-infos
```
Expected: 无 error/warning。重点确认 `unawaited`、`debugPrint`、`ClashHttpClient`、`_startGroupRefresh` / `_cancelGroupRefresh` / `_groupRefreshGeneration` 均能解析，无未使用警告。

- [ ] **Step 6: detect_changes 核实影响面**

调用 MCP：
```
detect_changes({repo: "flutter_sing_box", scope: "unstaged"})
```
Expected: 受影响符号限定于 `FlutterSingBoxWindows._refreshClientGroup` / `emitProxyState` / `dispose`，及 `_startGroupRefresh` / `_cancelGroupRefresh` / `_groupRefreshGeneration`（新增），所在的 `init` / VPN 启停执行流；`groupStream` / `emitClientGroups` 对外契约不变。若有意外扩散（如 `HelperHttpClient`、`_refreshClashMode` 被波及），停下排查。

- [ ] **Step 7: 手动验证（`flutter run -d windows`，配合 `clash_sing_app` 作为宿主）**

按以下清单验证（这是主要验收手段，因无单测）：
1. 连接 VPN → group 列表在 ~1 秒内出现，之后持续每秒刷新（可观察 debug 日志 / 网络请求节奏）。
2. 连接期间切换节点 / 触发 URLTest 测速 → group 列表内容随之更新。
3. 断开 VPN → 轮询停止（不再出现「拉取 proxies 失败」日志、无后续 `/proxies` 请求）。
4. 连接 → 断开 → 再连接 → 仅有一路轮询在跑（generation 防护生效，无并发请求堆积）。
5. 连接期间退出应用 → 轮询随 dispose 停止，无泄漏报错。

- [ ] **Step 8: Commit**

Run（在 `d:\projs_dg\flutter_sing_box` 下，当前分支 `develop`）：
```
git add lib/flutter_sing_box_windows.dart
git commit -m "feat(windows): group 连接后改为每秒持续轮询刷新"
```

---

## Self-Review

**1. Spec coverage** — 逐条对照 [spec](../specs/2026-07-26-windows-group-polling-refresh-design.md)：
- 「每秒持续轮询」→ Step 2 新循环 `Future.delayed(1s)` ✓
- 「串行避免重叠」→ Step 2 `while` 串行 ✓
- 「generation 取消 + 并发防护」→ Step 2 字段+两方法、Step 3 started/stopped 分支、Step 4 dispose ✓
- 「首次立即拉取」→ Step 2 循环体先拉取后 delay ✓
- 「单次失败不中断、不设上限」→ Step 2 catch 不 break、Global Constraints 声明 ✓
- 「不改 `_refreshClashMode` / stream 契约 / timeout / 不引入 ws」→ Global Constraints 声明，改动范围未触及 ✓
- 「拉取期间取消丢弃结果」→ Step 2 `if (gen == _groupRefreshGeneration)` 二次检查 ✓
- 测试策略（analyze + detect_changes + 手动）→ Step 5/6/7 ✓
- 改前 impact、改后 detect_changes、base_ref master → Step 1/6 + Global Constraints ✓

**2. Placeholder scan** — 无 TBD/TODO；每个代码 step 均含完整 old/new 代码块；手动验证清单为具体可执行步骤，非「适当测试」。✓

**3. Type consistency** — `_refreshClientGroup(int gen)` 签名在 Step 2（定义）与 Step 3（_startGroupRefresh 调用 `unawaited(_refreshClientGroup(gen))`）一致；`_startGroupRefresh` / `_cancelGroupRefresh` / `_groupRefreshGeneration` 三处命名一致；`emitProxyState(ProxyState)` 对外签名不变。✓
