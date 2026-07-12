# installService 改用 runas 提权 + 轮询判定 实现计划

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 把 Windows 端 `FlutterSingBoxWindows.installService` 由直接启动 `helper.exe` 改为 PowerShell `Start-Process -Verb RunAs` 提权启动,并以轮询服务状态判定安装结果,顺带修复"无视 exitCode、永远 return true"的 bug。

**Architecture:** 将原方法体拆为两个可单测的 `@visibleForTesting` 方法——`buildRunasArgs`(构造 PowerShell 参数)与 `waitForServiceReady`(注入 status getter/delay/now 的轮询判定)——再由 `installService` 串联:runas 启动 → 读 powershell 退出码(非 0 即用户拒绝 UAC,直接 false)→ 轮询 `queryServiceStatus` 直到 `running`/`stopped` 或超时。helper.exe(Go 侧)、插件接口签名、App 侧调用方均不动。

**Tech Stack:** Dart(Flutter 插件)、`dart:io` 的 `Process.run`、Windows PowerShell 5.1(`powershell.exe`)、`flutter_test`。

**GitNexus blast radius(改前已评估):**
- `installService` 调用链:`clash_sing_app` 的 `windows_service_vm.dart` → `FlutterSingBox.installService`(facade) → `FlutterSingBoxPlatform.installService`(接口) → `FlutterSingBoxWindows.installService`(实现,本计划唯一改动)。
- 签名 `Future<bool> installService(HelperConfig)` 与 bool 契约不变,且修正了原来"永远 true"的误报 → **risk LOW**。
- 索引落后(installService 未被图索引),故 impact 用 `grep` 替代;执行时若已更新索引,可改用 `impact({target:"installService", direction:"upstream", repo:"flutter_sing_box"})` 复查。

## Global Constraints

- **改动范围仅限 `flutter_sing_box` 仓库**(默认分支 `master`,当前工作分支 `develop`,提交在 develop 上)。
- 只动两个文件:`lib/flutter_sing_box_windows.dart`、`test/windows_service_test.dart`。**不改** `helper.exe`/Go 侧、`FlutterSingBoxPlatform` 接口、`FlutterSingBox` facade、`flutter_sing_box_method_channel.dart` 的 stub、App 侧 `windows_service_vm.dart`。
- 代码注释、Git commit 消息用**简体中文**;commit 用 conventional commits 前缀。
- 不手改任何 `*.g.dart`;本计划不涉及模型注解,无需 `build_runner`。
- Dart SDK `^3.9.0`、Flutter `>=3.3.0`;插件无 `win32` 依赖,本计划也不引入新依赖(纯 `dart:io` + PowerShell)。
- 提交前跑 `flutter analyze --fatal-infos` 与 `detect_changes({scope:"compare", base_ref:"master"})`(若索引未覆盖 installService,用 `grep -rn "installService" lib test` 与跨仓库 `grep` 确认调用点未受影响)。

## File Structure

| 文件 | 责任 | 本计划动作 |
|---|---|---|
| `lib/flutter_sing_box_windows.dart` | Windows 平台实现:asset 释放、服务状态查询、安装 | 新增 `buildRunasArgs`、`waitForServiceReady`;重写 `installService` 方法体 |
| `test/windows_service_test.dart` | Windows 服务相关单测 | 追加 `buildRunasArgs`、`waitForServiceReady` 两个测试 group |

---

## Task 1: 新增并测试 `buildRunasArgs`

把 PowerShell runas 的参数构造抽成纯方法,先 TDD 锁定其输出形状。

**Files:**
- Modify: `lib/flutter_sing_box_windows.dart`(在 `queryServiceStatus` 方法之后、`installService` 之前插入新方法)
- Test: `test/windows_service_test.dart`(末尾追加 group)

**Interfaces:**
- Consumes: 无
- Produces: `List<String> buildRunasArgs(String helperExePath)` —— 返回传给 `powershell.exe` 的参数列表;末位元素为 `-Command` 的 PowerShell 脚本字符串,含 `Start-Process -FilePath '<path>' -ArgumentList 'install' -Verb RunAs`。

- [ ] **Step 1: 写失败测试**

在 `test/windows_service_test.dart` 末尾(`main()` 闭合 `}` 之前)追加:

```dart
  group('FlutterSingBoxWindows.buildRunasArgs', () {
    late FlutterSingBoxWindows inst;

    setUp(() {
      inst = FlutterSingBoxWindows();
    });

    test('包含 -NoProfile / -NonInteractive 开关', () {
      final args = inst.buildRunasArgs(r'C:\app\helper.exe');
      expect(args, containsAll(<String>['-NoProfile', '-NonInteractive']));
    });

    test('末位 -Command 含 Start-Process、-Verb RunAs、路径与 install 参数', () {
      final args = inst.buildRunasArgs(r'C:\app\helper.exe');
      expect(args, hasLength(4));
      final cmd = args.last;
      expect(cmd, contains('Start-Process'));
      expect(cmd, contains('-Verb RunAs'));
      expect(cmd, contains(r'C:\app\helper.exe'));
      expect(cmd, contains("-ArgumentList 'install'"));
    });

    test('路径含空格时仍被单引号包裹', () {
      final args = inst.buildRunasArgs(r'C:\Program Files\app\helper.exe');
      expect(args.last, contains(r"'C:\Program Files\app\helper.exe'"));
    });
  });
```

并在该文件顶部 import 区追加(若尚无):

```dart
import 'package:flutter_sing_box/flutter_sing_box_windows.dart';
```

- [ ] **Step 2: 跑测试确认失败**

Run: `flutter test test/windows_service_test.dart`
Expected: 编译失败 / 方法未定义 —— `The method 'buildRunasArgs' isn't defined for the class 'FlutterSingBoxWindows'`。

- [ ] **Step 3: 实现 `buildRunasArgs`**

在 `lib/flutter_sing_box_windows.dart` 的 `queryServiceStatus` 方法之后、`installService` 之前插入:

```dart
  /// 构造通过 PowerShell 以管理员权限(runas)启动 [helperExePath] 执行
  /// `install` 的命令行参数。抽成独立方法便于单测参数形状。
  @visibleForTesting
  List<String> buildRunasArgs(String helperExePath) {
    return <String>[
      '-NoProfile',
      '-NonInteractive',
      '-Command',
      "Start-Process -FilePath '$helperExePath' -ArgumentList 'install' -Verb RunAs",
    ];
  }
```

- [ ] **Step 4: 跑测试确认通过**

Run: `flutter test test/windows_service_test.dart`
Expected: PASS(含原有 `fromHelperOutput` 用例 + 新增 3 个 `buildRunasArgs` 用例)。

- [ ] **Step 5: 静态分析后提交**

Run: `flutter analyze --fatal-infos lib/flutter_sing_box_windows.dart test/windows_service_test.dart`
Expected: 无 issue。

```bash
git add lib/flutter_sing_box_windows.dart test/windows_service_test.dart
git commit -m "feat(windows): 抽出 buildRunasArgs 构造 PowerShell runas 启动参数"
```

---

## Task 2: 新增并测试 `waitForServiceReady`

把"轮询服务状态直到命中/超时"的逻辑抽成可注入依赖的方法,用 fake status 序列与可控时钟单测。

**Files:**
- Modify: `lib/flutter_sing_box_windows.dart`(在 Task 1 的 `buildRunasArgs` 之后插入)
- Test: `test/windows_service_test.dart`(末尾再追加一个 group)

**Interfaces:**
- Consumes: `WindowsServiceStatus` 枚举(已从 `package:flutter_sing_box/src/constants/windows_service.dart` 可见)
- Produces: `Future<bool> waitForServiceReady({required Future<WindowsServiceStatus> Function() queryStatus, required Future<void> Function(Duration) delay, required DateTime Function() now, Duration pollInterval, Duration deadline})` —— 命中 `running`/`stopped` 返回 `true`;超时仍非二者返回 `false`。`pollInterval` 默认 500ms,`deadline` 默认 15s。

- [ ] **Step 1: 写失败测试**

在 `test/windows_service_test.dart` 末尾(`main()` 闭合 `}` 之前、Task 1 的 group 之后)追加:

```dart
  group('FlutterSingBoxWindows.waitForServiceReady', () {
    late FlutterSingBoxWindows inst;

    setUp(() {
      inst = FlutterSingBoxWindows();
    });

    test('命中 running 立即返回 true', () async {
      final ok = await inst.waitForServiceReady(
        queryStatus: () async => WindowsServiceStatus.running,
        delay: (_) async {},
        now: () => DateTime(2026, 7, 13),
      );
      expect(ok, isTrue);
    });

    test('命中 stopped 返回 true(已安装即视为成功)', () async {
      final ok = await inst.waitForServiceReady(
        queryStatus: () async => WindowsServiceStatus.stopped,
        delay: (_) async {},
        now: () => DateTime(2026, 7, 13),
      );
      expect(ok, isTrue);
    });

    test('超时仍为 notInstalled 返回 false', () async {
      var calls = 0;
      DateTime clock() {
        calls += 1;
        // 前几次调用返回 base(允许轮询),第 4 次起跳过 deadline(15s)触发退出。
        if (calls <= 3) return DateTime(2026, 7, 13);
        return DateTime(2026, 7, 13).add(const Duration(seconds: 20));
      }

      final ok = await inst.waitForServiceReady(
        queryStatus: () async => WindowsServiceStatus.notInstalled,
        delay: (_) async {},
        now: clock,
      );
      expect(ok, isFalse);
    });

    test('先 notInstalled/unknown 后 running 的序列能轮询命中', () async {
      final statuses = <WindowsServiceStatus>[
        WindowsServiceStatus.notInstalled,
        WindowsServiceStatus.unknown,
        WindowsServiceStatus.running,
      ];
      var i = 0;
      final ok = await inst.waitForServiceReady(
        queryStatus: () async => statuses[i++],
        delay: (_) async {},
        now: () => DateTime(2026, 7, 13), // 恒定时间,确保不超时
      );
      expect(ok, isTrue);
      expect(i, 3); // 确认轮询了 3 次才命中
    });
  });
```

- [ ] **Step 2: 跑测试确认失败**

Run: `flutter test test/windows_service_test.dart`
Expected: 编译失败 —— `The method 'waitForServiceReady' isn't defined`。

- [ ] **Step 3: 实现 `waitForServiceReady`**

在 `lib/flutter_sing_box_windows.dart` 的 `buildRunasArgs` 方法之后插入:

```dart
  /// 轮询服务状态,直到命中 [WindowsServiceStatus.running] 或
  /// [WindowsServiceStatus.stopped](视为"已安装"),或超过 [deadline]。
  ///
  /// 抽成独立方法便于单测:[queryStatus]、[delay]、[now] 均可注入。
  /// 返回 `true` 表示服务已安装(可能已运行);`false` 表示超时仍未安装。
  @visibleForTesting
  Future<bool> waitForServiceReady({
    required Future<WindowsServiceStatus> Function() queryStatus,
    required Future<void> Function(Duration) delay,
    required DateTime Function() now,
    Duration pollInterval = const Duration(milliseconds: 500),
    Duration deadline = const Duration(seconds: 15),
  }) async {
    final DateTime end = now().add(deadline);
    while (now().isBefore(end)) {
      final WindowsServiceStatus status = await queryStatus();
      if (status == WindowsServiceStatus.running ||
          status == WindowsServiceStatus.stopped) {
        return true;
      }
      await delay(pollInterval);
    }
    return false;
  }
```

- [ ] **Step 4: 跑测试确认通过**

Run: `flutter test test/windows_service_test.dart`
Expected: PASS(全部用例)。

- [ ] **Step 5: 静态分析后提交**

Run: `flutter analyze --fatal-infos lib/flutter_sing_box_windows.dart test/windows_service_test.dart`
Expected: 无 issue。

```bash
git add lib/flutter_sing_box_windows.dart test/windows_service_test.dart
git commit -m "feat(windows): 抽出 waitForServiceReady 轮询服务状态判定安装结果"
```

---

## Task 3: 重写 `installService` 串联 runas + 轮询,并修复 exitCode bug

用前两个方法替换 `installService` 方法体;接入 powershell 退出码判定与轮询;顺带消除"无视 exitCode、永远 return true"的 bug。

**Files:**
- Modify: `lib/flutter_sing_box_windows.dart:67-87`(整体替换 `installService` 方法体)

**Interfaces:**
- Consumes: 本任务 Task 1 的 `buildRunasArgs`、Task 2 的 `waitForServiceReady`,以及既有的 `_ensureHelperJson`、`queryServiceStatus`、`ProfileStorage().getStorageDirectory()`。
- Produces: 行为变更后的 `Future<bool> installService(HelperConfig config)` —— 签名不变;语义改为"UAC 授权 + 服务已安装(running/stopped)"才返回 `true`。

- [ ] **Step 1: 替换 `installService` 方法体**

`lib/flutter_sing_box_windows.dart` 当前的 `installService` 方法体如下(整体替换;若用 Edit 工具,以下整段即 `old_string`):

```dart
  @override
  Future<bool> installService(HelperConfig config) async {
    try {
      final io.Directory dir = await ProfileStorage().getStorageDirectory();
      await _ensureHelperJson(config: config, dir: dir.path);
      final io.File helperExe = io.File(p.join(dir.path, 'clash_sing_helper.exe'));
      if (!await helperExe.exists()) {
        return false;
      }

      final io.ProcessResult result = await io.Process.run(helperExe.path, [
        'install',
      ]).timeout(const Duration(seconds: 5));
      final stdout = (result.stdout ?? '').toString().trim();
      debugPrint('installService stdout = $stdout');
      return true;
    } catch (e) {
      debugPrint('flutter_sing_box 插件安装服务失败, $e');
      return false;
    }
  }
```

将其整体替换为:

```dart
  @override
  Future<bool> installService(HelperConfig config) async {
    try {
      final io.Directory dir = await ProfileStorage().getStorageDirectory();
      await _ensureHelperJson(config: config, dir: dir.path);
      final io.File helperExe = io.File(p.join(dir.path, 'clash_sing_helper.exe'));
      if (!await helperExe.exists()) {
        return false;
      }

      // 通过 PowerShell Start-Process -Verb RunAs 触发 UAC 提权启动 helper.exe。
      // Start-Process 默认不 -Wait,powershell.exe 在提权进程启动后即退出;
      // 故此处等的是 powershell.exe 自身退出码:
      //   exit 0  → 用户同意 UAC,提权进程已开始执行 install;
      //   exit ≠0 → 用户拒绝 UAC 或路径无效,直接判定失败,不再轮询。
      final io.ProcessResult psResult = await io.Process.run(
        'powershell.exe',
        buildRunasArgs(helperExe.path),
      ).timeout(const Duration(seconds: 15));
      if (psResult.exitCode != 0) {
        debugPrint(
          'runas 启动 helper 失败, exitCode=${psResult.exitCode}, '
          'stderr=${psResult.stderr}',
        );
        return false;
      }

      // 提权进程已在执行 install,轮询服务状态判定最终结果。
      return waitForServiceReady(
        queryStatus: queryServiceStatus,
        delay: (Duration d) => Future<void>.delayed(d),
        now: () => DateTime.now(),
      );
    } catch (e) {
      debugPrint('flutter_sing_box 插件安装服务失败, $e');
      return false;
    }
  }
```

> 注意:被替换掉的旧逻辑里 `final stdout = ...; debugPrint('installService stdout = $stdout'); return true;` 一并删除——这正是"无视 exitCode、永远 true"的 bug。

- [ ] **Step 2: 跑全量测试确认无回归**

Run: `flutter test`
Expected: 全部 PASS(本任务不改测试,但确认既有用例未被破坏)。

- [ ] **Step 3: 静态分析**

Run: `flutter analyze --fatal-infos`
Expected: 无 issue。

- [ ] **Step 4: 提交前回归检查(GitNexus / grep)**

Run(在 `flutter_sing_box` 仓库根): `detect_changes({scope:"compare", base_ref:"master"})` —— 若索引已覆盖 installService 则直接看结果;若因索引落后未覆盖,改用:
```bash
git diff master...HEAD -- lib/flutter_sing_box_windows.dart
grep -rn "installService" lib test
```
Expected: 只改 `lib/flutter_sing_box_windows.dart`;`installService` 调用点(facade `flutter_sing_box.dart`、接口、method_channel stub)签名未变。

- [ ] **Step 5: 提交**

```bash
git add lib/flutter_sing_box_windows.dart
git commit -m "fix(windows): installService 改用 runas 提权启动并轮询状态判定结果"
```

---

## Task 4: Windows 端到端手动验证

单测已覆盖参数构造与轮询逻辑;本任务在真实 Windows + App 上验证 UAC 提权与安装链路。本任务不产生代码提交,除非发现需修复的问题。

**Files:** 无代码改动(验证清单)。

- [ ] **Step 1: 在 App 中触发安装**

在 Windows 上以普通用户身份运行 `clash_sing_app`(path 依赖已指向本地插件,改动即时生效),进入 Windows 服务安装入口点击安装。

Expected: 弹出 UAC 对话框请求授权。

- [ ] **Step 2: 同意 UAC,验证服务安装成功**

点"是"。等待数秒。

Expected: `installService` 返回 `true`;UI 服务状态变为 `running`;`sc query clash_sing_service`(或 App 状态查询)显示 `RUNNING`。

- [ ] **Step 3: 拒绝 UAC,验证失败语义**

先卸载已装服务(或换台干净环境),再次点击安装,在 UAC 对话框点"否"。

Expected: `installService` 返回 `false`;UI 显示未安装/失败;服务确实未注册。

- [ ] **Step 4: 记录结果**

在 PR / 提交说明里记录上述三步的实际观察。若任一步与预期不符,回到对应 Task 修正(常见点:PowerShell 参数转义、轮询 deadline 过短)。
