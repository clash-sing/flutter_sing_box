# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Flutter plugin wrapping [sing-box](https://github.com/SagerNet/sing-box) for VPN proxy functionality. Android and Windows are production-ready; iOS is planned (macOS/Linux not started).

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
- Android native (Kotlin) unit tests run through the example app: `cd example/android && ./gradlew testDebugUnitTest` (see `android/CLAUDE.md`, including the known-failing template test documented there).
- CI runs `flutter analyze --fatal-infos` + `flutter test`, then publishes to pub.dev on `v*` tags.

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
| `constants/` | Enums: `ClashMode`, `ProfileType`, `OutboundType`, `ProxyState`, `LogLevel`, `ProxyMode` (tun/systemProxy), `WindowsServiceStatus`, etc.; plus `FlutterSingBoxConstants` (default mixed port 8890 / Clash API port 9090, template asset path) |
| `core/provider/` | Config format converters: `SingBoxConfigProvider` (native JSON), `ClashProvider` (YAML→sing-box), `Base64Provider` (Base64 subscription→sing-box) |
| `core/services/` | `ProfileService` (profile CRUD), `NetworkService` (HTTP for remote profiles) |
| `storage/` | `KeyValueStorage` abstraction with two impls — `MmkvStorage` (production) and `MemoryStorage` (unit tests, no native dependency); `ProfileStorage` / `CsSettingsStorage` sit on top |
| `data/models/singbox/` | sing-box config models (`SingBox`, `Outbound`, `Route`, `DNS`, `Inbound`, `Log`, `Experimental`) |
| `data/models/clash/` | Clash-compatible models (`Clash`, `ClashGroup`, `ClashProxy`) |
| `data/models/client/` | UI-facing models (`ClientStatus`, `ClientGroup`, `ClientClashMode`) — streamed to the app side |
| `data/models/database/` | Persistence models (`Profile`, `TypedProfile`, `UserInfo`) |
| `data/models/windows/` | `HelperConfig` — parameters handed to `clash_sing_helper.exe install` |
| `data/network/` | `DioClient` (HTTP), `ApiResult` (response wrapper) |
| `windows/` | Windows-only service layer: `HelperCli` (spawns `clash_sing_helper.exe` CLI subcommands), `HelperHttpClient` (service HTTP API), `ClashHttpClient` (Clash API), `SystemProxyService` (registry-based system proxy) |
| `utils/` | Extensions for YAML, profiles, and config merging (`UsingConfig`) |

### Key Design Patterns

- **Index barrels**: Each subdirectory has an `index.dart` that re-exports public API
- **JSON serialization**: All models use `json_serializable` + `build_runner`; `build.yaml` sets `include_if_null: false` (null fields are omitted from output)
- **MMKV**: multi-process mode — on Android the Dart side writes the config path and the `:remote` VPN service process reads it (the only config hand-off between processes; details in `android/CLAUDE.md`)
- **Config providers**: Strategy pattern for converting subscription formats (native/YAML/Base64) into sing-box JSON

### Bundled Assets

- `assets/configs/singbox_config_template.json` — 内置 sing-box 配置模板（全平台打包）。`SingBoxConfigProvider` 加载它作为基准，补全/修复用户原生 JSON 配置中缺失的字段（见 `_fixSingBoxConfig`），路径常量是 `FlutterSingBoxConstants.templateConfig`。
- `assets/windows/` — `sing-box.exe` / `libcronet.dll` / `clash_sing_helper.exe`（见 Windows Side）；pubspec 中通过 `platforms: [windows]` 过滤，仅 Windows 构建时打包。

### Native Side (Android)

- Kotlin, min SDK 26, sing-box libbox **1.13.21** (jitpack `com.github.singbox-android:libbox`) — keep this version in sync when upgrading sing-box
- **Read `android/CLAUDE.md` before touching `android/`** — it documents the two-package layout (plugin layer + vendored sing-box-for-android service layer), the `:remote` process model, AIDL vs libbox CommandClient channels, and known gotchas.

### Windows Side

- The `windows/` native dir is only a CMake + C-API registration stub (`FlutterSingBoxPluginCApi`); all Windows logic lives in Dart.
- `init()` copies three bundled assets (`assets/windows/`: `sing-box.exe`, `libcronet.dll`, `clash_sing_helper.exe`) next to the app executable, then clears a stale system proxy left over from a previous crash.
- Runtime flow: `HelperCli` drives the `clash_sing_service` Windows system service (installed via a UAC-elevated helper), which runs sing-box as LocalSystem and exposes an HTTP API. Two proxy modes via `ProxyMode`: `tun` (default, system-wide) and `systemProxy` (registry-based, default mixed port 8890).
- `clash_sing_helper.exe` is built by the sibling Go repo `clash_sing_service` — after changing it, rebuild and overwrite `assets/windows/clash_sing_helper.exe` here, or apps keep using the old version (full cross-repo chain described in the workspace-level `../CLAUDE.md`).

## Conventions

- Code comments in simplified Chinese
- Git commit messages in simplified Chinese
- `*.g.dart` files are auto-generated — never edit them directly; regenerate with `build_runner`
- When adding/modifying model classes with `@JsonSerializable`, always run build_runner afterward
- Default branch is `main`; daily development happens on `develop`. GitNexus regression comparisons use `base_ref: "main"`.

<!-- gitnexus:start -->
# GitNexus — Code Intelligence

This project is indexed by GitNexus as **flutter_sing_box** (2459 symbols, 4680 relationships, 131 execution flows). Use the GitNexus MCP tools to understand code, assess impact, and navigate safely.

> Index stale? Run `node .gitnexus/run.cjs analyze` from the project root — it auto-selects an available runner. No `.gitnexus/run.cjs` yet? `npx gitnexus analyze` (npm 11 crash → `npm i -g gitnexus`; #1939).

## Always Do

- **MUST run impact analysis before editing any symbol.** Before modifying a function, class, or method, run `impact({target: "symbolName", direction: "upstream"})` and report the blast radius (direct callers, affected processes, risk level) to the user.
- **MUST run `detect_changes()` before committing** to verify your changes only affect expected symbols and execution flows. For regression review, compare against the default branch: `detect_changes({scope: "compare", base_ref: "main"})`.
- **MUST warn the user** if impact analysis returns HIGH or CRITICAL risk before proceeding with edits.
- When exploring unfamiliar code, use `query({search_query: "concept"})` to find execution flows instead of grepping. It returns process-grouped results ranked by relevance.
- When you need full context on a specific symbol — callers, callees, which execution flows it participates in — use `context({name: "symbolName"})`.
- For security review, `explain({target: "fileOrSymbol"})` lists taint findings (source→sink flows; needs `analyze --pdg`).

## Never Do

- NEVER edit a function, class, or method without first running `impact` on it.
- NEVER ignore HIGH or CRITICAL risk warnings from impact analysis.
- NEVER rename symbols with find-and-replace — use `rename` which understands the call graph.
- NEVER commit changes without running `detect_changes()` to check affected scope.

## Resources

| Resource | Use for |
|----------|---------|
| `gitnexus://repo/flutter_sing_box/context` | Codebase overview, check index freshness |
| `gitnexus://repo/flutter_sing_box/clusters` | All functional areas |
| `gitnexus://repo/flutter_sing_box/processes` | All execution flows |
| `gitnexus://repo/flutter_sing_box/process/{name}` | Step-by-step execution trace |

## CLI

| Task | Read this skill file |
|------|---------------------|
| Understand architecture / "How does X work?" | `.claude/skills/gitnexus/gitnexus-exploring/SKILL.md` |
| Blast radius / "What breaks if I change X?" | `.claude/skills/gitnexus/gitnexus-impact-analysis/SKILL.md` |
| Trace bugs / "Why is X failing?" | `.claude/skills/gitnexus/gitnexus-debugging/SKILL.md` |
| Rename / extract / split / refactor | `.claude/skills/gitnexus/gitnexus-refactoring/SKILL.md` |
| Tools, resources, schema reference | `.claude/skills/gitnexus/gitnexus-guide/SKILL.md` |
| Index, status, clean, wiki CLI commands | `.claude/skills/gitnexus/gitnexus-cli/SKILL.md` |

<!-- gitnexus:end -->
