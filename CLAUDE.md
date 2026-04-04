# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Flutter plugin wrapping [sing-box](https://github.com/SagerNet/sing-box) for VPN proxy functionality. Only Android is production-ready; iOS/Windows/macOS/Linux are planned.

- **Plugin package**: `com.clashsiing.flutter_sing_box`
- **Dart SDK**: ^3.9.0, **Flutter**: >=3.3.0
- **License**: GPL-3.0

## Build & Development Commands

```bash
# 依赖安装
flutter pub get

# 代码生成（修改 @JsonSerializable 模型后必须运行）
dart run build_runner build --delete-conflicting-outputs

# 持续监听并生成
dart run build_runner watch --delete-conflicting-outputs

# 静态分析
flutter analyze --fatal-infos

# 测试
flutter test
```

CI pipeline runs `flutter analyze --fatal-infos` then `flutter test` before publishing on `v*` tags.

## Architecture

### Plugin Layer Pattern
```
FlutterSingBox (lib/flutter_sing_box.dart)
  → FlutterSingBoxPlatform (platform interface)
    → FlutterSingBoxMethodChannel (method channel)
      → Native implementations (Kotlin / Swift)
```

- `FlutterSingBox` is the public API facade — delegates everything to the platform interface
- Platform communication uses Flutter Method Channels
- Streams (`connectedStatusStream`, `groupStream`, `clashModeStream`, `logStream`, `proxyStateStream`) provide real-time updates from native side

### Source Layout (`lib/src/`)

| Directory | Purpose |
|-----------|---------|
| `constants/` | Enums: `ClashMode`, `ProfileType`, `OutboundType`, `ProxyState`, `LogLevel`, etc. |
| `core/provider/` | Config format converters: `SingBoxConfigProvider` (native JSON), `ClashProvider` (YAML→sing-box), `Base64Provider` (Base64 subscription→sing-box) |
| `core/services/` | `ProfileService` (profile CRUD), `NetworkService` (HTTP for remote profiles) |
| `core/` | `ProfileManager` (singleton, MMKV-backed profile storage), `CsSettingsManager` (app settings) |
| `custom/` | Custom key-value storage (`CustomManager`) and logging (`CustomLog`) |
| `data/models/singbox/` | sing-box config models (`SingBox`, `Outbound`, `Route`, `DNS`, `Inbound`, `Log`, `Experimental`) |
| `data/models/clash/` | Clash-compatible models (`Clash`, `ClashGroup`, `ClashProxy`) |
| `data/models/client/` | UI-facing models (`ClientStatus`, `ClientGroup`, `ClientClashMode`) — streamed to Flutter side |
| `data/models/database/` | Persistence models (`Profile`, `TypedProfile`, `UserInfo`) |
| `data/network/` | `DioClient` (HTTP), `ApiResult` (response wrapper) |
| `utils/` | Extensions for YAML, profiles, and config merging (`UsingConfig`) |

### Key Design Patterns

- **Singleton**: `ProfileManager` and `CsSettingsManager` use singleton pattern
- **MMKV**: Fast KV storage for profiles and settings (multi-process mode)
- **Index barrels**: Each subdirectory has an `index.dart` that re-exports public API
- **JSON serialization**: All models use `json_serializable` + `build_runner` (configured to exclude null fields in `build.yaml`)
- **Config providers**: Strategy pattern for converting different subscription formats (native/YAML/Base64) into sing-box JSON

### Native Side (Android)

- Kotlin, min SDK 26, uses sing-box libbox v1.12.25
- Key classes: `BoxService`, `ClashSingVpnService` (VPN service), `ProxyService`, `ProfileManager`, `SettingsManager`
- AIDL-based communication between service and plugin

## Conventions

- Code comments in simplified Chinese
- Git commit messages in simplified Chinese
- `*.g.dart` files are auto-generated — never edit them directly; regenerate with `build_runner`
- When adding/modifying model classes with `@JsonSerializable`, always run build_runner afterward
