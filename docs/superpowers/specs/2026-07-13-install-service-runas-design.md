# installService 改用 runas 提权 + 轮询判定 — 设计文档

- 日期: 2026-07-13
- 状态: 已批准,待实现
- 影响工程: `flutter_sing_box`(插件,Dart 侧单文件)
- 受影响文件: `lib/flutter_sing_box_windows.dart` 的 `FlutterSingBoxWindows.installService`

## 1. 背景与问题

当前 `installService` 通过 `io.Process.run(helperExe.path, ['install'])` 直接启动 `clash_sing_helper.exe` 安装 Windows 系统服务。存在两个问题:

1. **不会弹出 UAC、也无法提权**: `io.Process.run` 走 `CreateProcess`,不是 `ShellExecute`;且 `helper.exe`(见 `windows_helper_service/build.sh`)没有内嵌 `requireAdministrator` 清单。结果: `helper.exe` 以 App 的普通用户权限运行,调用 SCM 创建服务时被 `ERROR_ACCESS_DENIED` 拒绝,`install()` 返回错误并 `panic` 退出 —— **除非 App 本身已被"以管理员身份运行"**。

2. **静默失败 + 误报成功**: 当前实现无视 `result.exitCode`,只要进程能启动就 `return true`。调用方(位于 `clash_sing_app` 工程的 `lib/src/vm/windows_service_vm.dart`)据此认为安装成功,但服务实际并未装上。

## 2. 目标

- 安装服务时由系统弹出 UAC 对话框,用户授权后以管理员权限完成 `helper.exe install`。
- 用"轮询服务状态"判定安装是否真正成功(因 runas 启动后拿不到 `helper.exe` 的 stdout/exit code)。
- 顺手修复"无视 exitCode、永远 return true"的 bug。
- 不改 `helper.exe`(Go 侧)、不改插件接口签名、不改 App 侧调用方。

## 3. 改动范围与边界

| 项 | 是否改动 | 说明 |
|---|---|---|
| `FlutterSingBoxWindows.installService` | 改 | 唯一改动点,方法体整体替换 |
| `helper.exe`(Go 侧 `windows_helper_service`) | 不改 | 二进制不变,**无需重新 build / 覆盖 asset** |
| `FlutterSingBoxPlatform.installService` 签名 | 不改 | 仍为 `Future<bool> installService(HelperConfig config)` |
| App 侧 `windows_service_vm.dart`(位于 `clash_sing_app` 工程) | 不改 | path 依赖插件,改完即生效 |

## 4. 新流程

```
installService(config):
  1. _ensureHelperJson(config)            // 沿用:提权前把 helper.json 写到 exe 同目录(普通权限可写)
  2. 校验 helper.exe 存在                  // 沿用:不存在 return false
  3. PowerShell runas 触发提权启动          // 新:见第 5 节,等 powershell.exe 自身退出
     - powershell exitCode != 0 → 用户拒绝 UAC / 路径无效 → return false(不必轮询)
     - powershell exitCode == 0 → 提权进程已启动,进入轮询
  4. 轮询 queryServiceStatus               // 新:见第 6 节
     - 命中 running/stopped → return true
     - 超时仍是 notInstalled/unknown/error → return false
  5. 整体 try/catch,任何异常 → return false
```

## 5. PowerShell runas 启动

```dart
final io.ProcessResult psResult = await io.Process.run(
  'powershell.exe',
  <String>[
    '-NoProfile',
    '-NonInteractive',
    '-Command',
    "Start-Process -FilePath '${helperExe.path}' -ArgumentList 'install' -Verb RunAs",
  ],
).timeout(const Duration(seconds: 15));
```

要点:

- `-Verb RunAs` 是触发 UAC 的关键(`io.Process.run` 直接拉 `helper.exe` 不会弹 UAC)。
- **`Start-Process` 默认不 `-Wait`**: powershell.exe 在 UAC 决定且提权进程启动后即退出。因此我们等的是 **powershell.exe 的退出码**,不是提权后 `helper.exe` 的退出码(后者拿不到,故需轮询)。
- `-NoProfile -NonInteractive`: 跳过用户 PS 配置、避免交互卡死。
- 选用 `powershell.exe`(Windows 自带 5.1),不依赖可能未安装的 `pwsh.exe`(PS7)。
- **退出码语义**:
  - 用户在 UAC 点"否" → `Start-Process` 抛异常 → powershell exit ≠ 0,stderr 含 "canceled"。
  - 用户点"是" → exit 0。
- `timeout(15s)` 仅约束 powershell.exe 启动 + 用户响应 UAC 的耗时;提权后的 `helper.exe install` 由第 6 节的轮询覆盖。
- 路径转义: Windows 路径不含单引号,用单引号包裹 `FilePath` 与 `ArgumentList` 即安全。

## 6. 轮询策略与状态语义

```dart
const Duration pollInterval = Duration(milliseconds: 500);
const Duration deadline = Duration(seconds: 15);
// 循环: 每 pollInterval 调一次 queryServiceStatus(),命中目标状态或超过 deadline 即退出
// 注: deadline 仅约束轮询阶段,与第 5 节 powershell 的 15s timeout 串行、互不包含(最坏总耗时约 30s)
```

状态判定(复用现有 `WindowsServiceStatus` 枚举):

| 轮询命中的状态 | 返回值 | 含义 |
|---|---|---|
| `running` | `true` | Go 侧 `Install() + Start()` 均成功(理想路径) |
| `stopped` | `true` | 服务已注册但 Start 失败 —— "已安装"契约达成,UI 显示 stopped |
| `notInstalled`(超时) | `false` | 用户拒绝(已在启动层拦截)或 SCM 安装失败 |
| `unknown` / `error`(超时) | `false` | 不确定 / helper 异常 |

- `queryServiceStatus()` 内部已有 5s timeout,与 500ms 轮询间隔不冲突。
- 轮询期间服务可能处于"半注册"中间态(返回 `notInstalled`/`unknown`),这正是需要轮询而非单次查询的原因。

## 7. 错误处理

- **启动层**: `psResult.exitCode != 0` → `debugPrint` stderr,`return false`(覆盖"用户拒绝 UAC")。
- **安装层**: 轮询超时仍是 `notInstalled`/`unknown`/`error` → `return false`。
- **异常层**: 整个方法 `try/catch`(沿用现有结构),powershell 超时 / 进程启动失败等 → `return false`。

## 8. 测试策略

**可单测部分**(抽成纯函数 / 注入依赖):

- 轮询判定逻辑: 注入 `Future<WindowsServiceStatus> Function()` 的 fake status getter 与可控时钟,验证 `running/stopped → true`、超时 `notInstalled → false`。
- PowerShell 命令字符串构造: 验证路径与参数转义正确。

**端到端**(Windows 手动):

- 同意 UAC → 服务状态变 `running`,`installService` 返回 `true`。
- 拒绝 UAC → `installService` 返回 `false`,服务仍未安装。

## 9. 已知限制(接受,不在本次解决)

- UAC 对话框可能不在 App 窗口正上方(任务栏闪烁) —— `ShellExecute` 无 HWND parent 的固有行为。
- 无法区分"用户拒绝 UAC"与"SCM 真正安装失败":前者在启动层被 powershell exit ≠ 0 拦截;若 powershell exit 0 但轮询超时 `notInstalled`,按所选轮询方案统一报"安装失败",不再细分。
