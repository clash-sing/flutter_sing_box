# AGENTS.md

This file provides guidance to AI coding agents (e.g. Claude Code) when working with code in this repository.

## Project Overview

Flutter plugin wrapping [sing-box](https://github.com/SagerNet/sing-box) for VPN proxy functionality. Android and Windows are production-ready; iOS is planned — `pubspec.yaml` already declares the `ios` platform (sharing the MethodChannel `dartPluginClass`), but the native side (`ios/Classes/FlutterSingBoxPlugin.swift`) is only the Flutter plugin scaffold stub (macOS/Linux not started).

- **Plugin package**: `com.clashsing.flutter_sing_box`
- **Dart SDK**: ^3.12.0, **Flutter**: >=3.44.0
- **License**: GPL-3.0
- Android/iOS use the native method-channel implementation; Windows is implemented **entirely in Dart** on top of bundled external binaries (see Windows Side below)

## Build & Development Commands

```bash
# 依赖安装
flutter pub get

# 代码生成（修改 @JsonSerializable 模型后必须运行）
# 注：新版 build_runner 默认删除冲突输出，旧参数 --delete-conflicting-outputs 已被移除，传入会警告并忽略
dart run build_runner build

# 持续监听并生成
dart run build_runner watch

# 静态分析
flutter analyze --fatal-infos

# 测试（全部）
flutter test

# 单个测试文件 / 单个用例
flutter test test/proxy_mode_test.dart
flutter test --plain-name "用例名称"
```

- `build.yaml` excludes `example/**` on purpose: desktop builds create `example/windows/flutter/ephemeral/.plugin_symlinks` symlinks that make build_runner pick up third-party plugin sources as this package's, breaking the build — don't remove that exclusion.
- Android native (Kotlin) unit tests run through the example app: `cd example/android && ./gradlew testDebugUnitTest` (see `android/AGENTS.md`, including the known-failing template test documented there).
- CI（`.github/workflows/ci.yml`，仅 `v*` tag 触发）四个 job 依次把关：`build`（`flutter analyze --fatal-infos` + `flutter test`）→ `subcheck`（订阅样本回归门，见下节）→ `publish`（pub.dev，走官方 dart-lang workflow）→ `release`（从 `CHANGELOG.md` 提取本版本 `## x.y.z` 段落创建 GitHub Release，缺段落则回退自动生成）。发版动作即：更新 `pubspec.yaml` 版本号 + `CHANGELOG.md` 新段落 → 本机跑 subcheck 对比 → 推 `v*` tag。

### 订阅样本回归门（`tool/subcheck/`）

- 一组**全构造**的订阅样本（Clash YAML / Base64 链接表 / 原生 sing-box JSON，覆盖 ss（含 2022/obfs/v2ray-plugin）/trojan/vmess/vless（含 REALITY）/hysteria1/hysteria2/tuic/anytls 与 tcp/ws/grpc/h2 传输），每个样本走 `SingBoxConfigProvider.provide()`——App 导入订阅的真实转换路径——产物用对应内核版本的 `sing-box check` 校验，并静态检查分组、`route.final`、路由规则与 DNS detour 有没有引用不存在的出站。
- 推 `v*` tag 前**本机先跑一遍** `tool/subcheck/ci-compare.sh`（默认对比上一个 `v*` tag 与 HEAD；脚本按各提交的 libbox 版本自动下载官方 sing-box 内核，无需 Go 工具链）。「变坏」一栏非空则 CI 中 `publish` / `release` 不运行；「有增有减」不挡发布但需人工看一眼。
- 某个「变坏」是有意的（如决定不再支持某种写法）：改 `tool/subcheck/verify/subs/samples.toml` 中该样本的期望，与代码改动同一提交。细节见 `tool/subcheck/README.md`。

## Architecture

### Plugin Layer Pattern
```
FlutterSingBox (lib/flutter_sing_box.dart)    ← public API facade
  → FlutterSingBoxPlatform (platform interface)
      → MethodChannelFlutterSingBox            ← Android/iOS: MethodChannel → Kotlin/Swift
      → FlutterSingBoxWindows                  ← Windows: pure-Dart implementation,
         (lib/flutter_sing_box_windows.dart)     registered via registerWith()
```

- `FlutterSingBox` delegates everything to the platform interface; on Windows it additionally exposes service management: `installService` / `uninstallService` / `queryServiceStatus` / `startService` / `stopService`.
- Streams (`connectedStatusStream`, `groupStream`, `clashModeStream`, `logStream`, `proxyStateStream`) provide real-time updates from the platform side.

### Source Layout (`lib/src/`)

| Directory | Purpose |
|-----------|---------|
| `constants/` | Enums: `ProfileType`, `OutboundType`, `ProxyMode` (tun/systemProxy), `WindowsServiceStatus`, etc.; non-enum constants: `ClashMode` (string-constants class) and `ProxyState` (sealed class, see Key Design Patterns); plus `FlutterSingBoxConstants` (default mixed port 8890 / Clash API port 9090, template asset path) |
| `core/provider/` | Config format converters: `SingBoxConfigProvider` (native JSON), `ClashProvider` (YAML→sing-box), `Base64Provider` (Base64 subscription→sing-box) |
| `core/services/` | `ProfileService` (profile CRUD), `NetworkService` (HTTP for remote profiles) |
| `storage/` | `KeyValueStorage` abstraction with two impls — `MmkvStorage` (production) and `MemoryStorage` (unit tests, no native dependency); `ProfileStorage` / `CsSettingsStorage` sit on top |
| `data/models/singbox/` | sing-box config models: `gen/` — schema-generated sealed models (see below) + `schema_validator.dart` (`SingBoxSchemaValidator`, offline validation against the official JSON schema) |
| `data/models/clash/` | Clash-compatible models (`Clash`, `ClashGroup`, `ClashProxy`) |
| `data/models/client/` | UI-facing models (`ClientStatus`, `ClientGroup`, `ClientClashMode`) — streamed to the app side |
| `data/models/database/` | Persistence models (`Profile`, `TypedProfile`, `UserInfo`) |
| `data/models/windows/` | `HelperConfig` — parameters handed to `clash_sing_helper.exe install` |
| `data/network/` | `DioClient` (HTTP), `ApiResult` (response wrapper) |
| `windows/` | Windows-only service layer: `HelperCli` (spawns `clash_sing_helper.exe` CLI subcommands), `HelperHttpClient` (service HTTP API), `ClashHttpClient` (Clash API), `SystemProxyService` (registry-based system proxy) |
| `utils/` | Extensions for YAML, profiles, and config merging (`UsingConfig`) |

**sing-box 生成模型**（`data/models/singbox/gen/`）：由 `tool/gen_models.dart` 从 `assets/schemas/singbox_schema.json` 生成——Outbound / Inbound / DnsServer 三个 sealed 判别族（按 `type` 判别，未知类型落到 `Unknown*` 透传变体）、`gen/shared/` 的 mixin 共享字段块（`DialerFields` / `ListenFields` 等）、`SingBox` 把未建模顶层段收进 `unknownSections` 原样保真（读入收存、输出合并）。生成物勿手改。schema 升级流程：替换 `assets/schemas/singbox_schema.json` → `dart run tool/gen_models.dart` → `dart run build_runner build` → 跑测试。`tool/` 其余工具：`src/`（gen_models 的 emitter / IR 支撑代码）、`diagnose_schema.dart`（schema 差异诊断）、`doc_coverage.dart`（doc 注释覆盖率统计）、`subcheck/`（CI 订阅样本回归门，见上）。

### Key Design Patterns

- **Index barrels**: Each subdirectory has an `index.dart` that re-exports public API
- **JSON serialization**: Models use `json_serializable` + `build_runner` (some UI-facing client models like `ClientGroup` also use freezed `@unfreezed`); `build.yaml` sets `include_if_null: false` (null fields are omitted from output)
- **`ProxyState` is a sealed class, not an enum** (breaking change in 2.0.0): four subclasses `ProxyStopped` / `ProxyStarting` / `ProxyStarted` / `ProxyStopping`, handled by exhaustive pattern matching; only `ProxyStopped` carries data — `errMessage` non-null means an abnormal stop (start failure, core crash). `ProxyState.stopped` / `.started` etc. remain as const shortcuts for legacy equality checks.
- **MMKV**: multi-process mode — on Android the Dart side writes the config path and the `:remote` VPN service process reads it (the only config hand-off between processes; details in `android/AGENTS.md`)
- **Config providers**: Strategy pattern for converting subscription formats (native/YAML/Base64) into sing-box JSON

### Bundled Assets

- `assets/configs/singbox_config_template.json` — 内置 sing-box 配置模板（全平台打包）。`SingBoxConfigProvider` 加载它作为基准，补全/修复用户原生 JSON 配置中缺失的字段（见 `_fixSingBoxConfig`），路径常量是 `FlutterSingBoxConstants.templateConfig`。
- `assets/windows/` — 双架构二进制目录：`amd64/` 与 `arm64/` 各含 `sing-box.exe` / `libcronet.dll` / `clash_sing_helper.exe`，父目录仅 `LICENSE`（见 Windows Side）；pubspec 中父目录与两个架构子目录均需显式声明（目录资产非递归）并通过 `platforms: [windows]` 过滤，仅 Windows 构建时打包。运行时由 `WindowsArch`（`src/windows/windows_arch.dart`，基于 GetNativeSystemInfo 取真机架构）选择其一释放——x64 App 在 ARM64 机器上模拟运行时也正确选出 arm64。

### Native Side (Android)

- Kotlin, min SDK 26, sing-box libbox **1.14.4** (jitpack `com.github.singbox-android:libbox`) — keep this version in sync when upgrading sing-box（1.14.4 起 `PlatformInterface` 移除了 `useProcFS()`，legacy Android 的连接属主查找改为 `findConnectionOwner` 内按 `SDK_INT >= Q` 分支、`< Q` 走 `Libbox.findConnectionOwner` procfs 搜索）
- **Read `android/AGENTS.md` before touching `android/`** — it documents the two-package layout (plugin layer + vendored sing-box-for-android service layer), the `:remote` process model, AIDL vs libbox CommandClient channels, and known gotchas.

### Windows Side

- The `windows/` native dir is only a CMake + C-API registration stub (`FlutterSingBoxPluginCApi`); all Windows logic lives in Dart.
- `init()` copies three bundled assets (`assets/windows/<amd64|arm64>/`: `sing-box.exe`, `libcronet.dll`, `clash_sing_helper.exe`, selected by native machine architecture — see `WindowsArch`) next to the app executable, then clears a stale system proxy left over from a previous crash.
- Runtime flow: `HelperCli` drives the `clash_sing_service` Windows system service (installed via a UAC-elevated helper), which runs sing-box as LocalSystem and exposes an HTTP API. Two proxy modes via `ProxyMode`: `tun` (default, system-wide) and `systemProxy` (registry-based, default mixed port 8890).
- Since 2.0.0, Windows `start()` / `restart()` **no longer throw on failure** — the failure reason is emitted on `proxyStateStream` as `ProxyStopped(errMessage: ...)` (also resetting the state machine from `starting`), making the state stream the single source of truth for startup failures; callers awaiting these futures cannot catch failures from the returned future. Aligned with the Android native alert path.
- Helper HTTP API 监听**随机端口**，每次服务重启都会变化并写回 `helper.json`——`HelperHttpClient` 因此不缓存端口，每次请求前重读配置，连接被拒/超时时重读（可能已更新的）端口并重试一次。
- `started` 状态下每 3 秒（`WindowsConstants.helperWatchInterval`）探测 helper `/status` 做崩溃检测：`stopped` 回复或 helper 不可达都以 `ProxyStopped(errMessage: ...)` 上报（区分「内核已停止」与「服务崩溃」）；每次代理状态切换（start/restart/stop/dispose）递增代数计数器并取消在途探测，避免把用户主动操作误报为崩溃。
- The bundled `sing-box.exe` / `libcronet.dll` are core version **1.14.1**, both `amd64` and `arm64` taken from the official release zips — keep them in sync with the Android libbox version when upgrading sing-box.
- `clash_sing_helper.exe` is built by the sibling Go repo `clash_sing_service` — after changing it, rebuild and overwrite `assets/windows/clash_sing_helper.exe` here, or apps keep using the old version (full cross-repo chain described in the workspace-level `../AGENTS.md`).

## Conventions

- Code comments in simplified Chinese
- Git commit messages in simplified Chinese
- `*.g.dart` files are auto-generated — never edit them directly; regenerate with `build_runner`
- When adding/modifying model classes with `@JsonSerializable`, always run build_runner afterward
- Default branch is `main`; daily development happens on `develop`.
- `doc/superpowers/` (plans / specs) is working documentation, not build input — don't treat it as code.
