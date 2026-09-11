# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

Android native (Kotlin) implementation of the `flutter_sing_box` plugin. The Dart-side layout, build commands, and code-generation conventions live in [`../CLAUDE.md`](../CLAUDE.md); this file covers only the Kotlin layer under `android/`.

## Build & Test

- This module has **no gradle wrapper of its own** — it is built as a module of the example app. The example app lives at the **plugin repo root** (`../example/`, standard Flutter plugin layout), not under `android/`. Run native unit tests from there:
  ```bash
  cd ../example/android
  ./gradlew testDebugUnitTest                    # Windows: gradlew.bat testDebugUnitTest
  ./gradlew testDebugUnitTest --tests "com.clashsing.flutter_sing_box.FlutterSingBoxPluginTest"  # 单个测试类
  ```
  `flutter analyze` / `flutter test` (repo root, CI) only cover the Dart side.
- Gradle is Kotlin DSL (`build.gradle.kts`). AGP library plugin, compileSdk 37, minSdk 26, Java 17, core-library desugaring enabled.
- Sources live in `src/main/kotlin` and `src/test/kotlin` (wired explicitly via `sourceSets`), not `src/main/java`.
- Key dependencies: `com.github.singbox-android:libbox` (jitpack — version must stay in sync with the sing-box version mentioned in `../CLAUDE.md` and `../pubspec.yaml`), MMKV 2.4.2, kotlinx-serialization-json. Unit tests use kotlin-test + Mockito on JUnit Platform.
- AIDL is required (`buildFeatures { aidl = true }`) — `IService`/`IServiceCallback` under `src/main/aidl` drive cross-process communication (see below).

## The Two-Package Layout

| Package | Origin | Role |
|---------|--------|------|
| `com.clashsing.flutter_sing_box` | this project | Flutter-facing plugin layer: `FlutterSingBoxPlugin` (MethodChannel), `SingBoxConnector` (EventChannels), `PluginManager` (app context + Libbox setup), `utils/ProfileManager` / `utils/SettingsManager` (MMKV), `cs/models/*` (DTOs) |
| `io.nekohasekai.sfa.*` | vendored & adapted from [sing-box-for-android](https://github.com/SagerNet/sing-box-for-android) (SFA) | Service layer: `bg/BoxService` (all service logic, implements libbox `CommandServerHandler`), `bg/VPNService` / `bg/ProxyService` (thin `Service` wrappers), `utils/CommandClient`, `bg/PlatformInterfaceWrapper` (libbox `PlatformInterface` impl), constants (`Action`, `Status`, `Alert`, `ServiceMode`) |

## Process Model — the part invisible from any single file

The VPN service runs in a **separate process** (`android:process=":remote"` in the manifest, foregroundServiceType `systemExempted`, always-on enabled). Everything else follows from that split:

- **Two communication channels, with different jobs:**
  - **AIDL** (`IService` / `IServiceCallback`): lifecycle only. The UI process binds the service (`SingBoxConnector.MyServiceConnection`) to receive status changes (Stopped/Starting/Started/Stopping) and alerts. These transitions also gate the data channel: `Started` → `connectClient()`, `Stopped` → `disconnectClient()`. `VPNService.onBind` returns the system binder for `android.net.VpnService` intents and the AIDL `ServiceBinder` for everything else.
  - **libbox `CommandClient`** (local command socket): all real-time data — status/traffic, proxy groups, Clash mode, logs. `SingBoxConnector` creates one `CommandClient` per `ConnectionType`, each feeding one EventChannel. Control commands (`selectOutbound`, `setClashMode`, `urlTest`, `serviceReload`) are issued directly via `Libbox.newStandaloneCommandClient()`.
- **MMKV `MULTI_PROCESS_MODE` is the Dart→service config hand-off.** The Dart side writes the generated config path into MMKV id `cs_profile` (keys `using_config` = directory, plus `using_config.json` = filename — see `lib/src/storage/profile_storage.dart`); the `:remote` process reads it in `ProfileManager.getUsingConfig()`. This is the only way config reaches the service process — there is no config payload in any intent or method-channel call. Runtime settings live in a second multi-process MMKV, `cs_settings` (`SettingsManager`: `service_mode`, `started_by_user`, per-app proxy, …), read by both processes.

## Service Lifecycle

`BoxService` is a plain class, **not** an Android `Service` — `VPNService`/`ProxyService` construct `BoxService(this, this)` in `onCreate()` and delegate every lifecycle callback (`onStartCommand` / `onBind` / `onDestroy` / `onRevoke`) to it.

- Start: Dart `startVpn()` → MethodChannel `startVpn` → `VpnService.prepare()` permission flow (`VPN_REQUEST_CODE = 1001`, the MethodChannel `Result` is parked in `pendingStartVpnResult` until `onActivityResult`) → `BoxService.start()` → `startForegroundService` on `SettingsManager.serviceClass()` — which is `VPNService` or `ProxyService` depending on the `service_mode` MMKV setting → `BoxService.onStartCommand()` → libbox `CommandServer` → `startOrReloadService(configContent, OverrideOptions)`.
- Stop/restart are **broadcasts**, not binds: `Action.SERVICE_CLOSE` / `Action.SERVICE_RESTART`. Note `serviceReload` is implemented as a full stop-then-start restart (see the `isRestart` flag in `stopService()`), not an in-place reload.
- `PluginManager.init()` (double-checked singleton) must run before anything touches `appContext` / MMKV / `Libbox.setup`; it is called both from `onAttachedToEngine` and from `VPNService.onCreate()` (whichever process gets there first).

## Flutter Channels

MethodChannel `flutter_sing_box_method`: `init`, `startVpn`, `stopVpn`, `serviceReload`, `setClashMode`, `selectOutbound`, `setGroupExpand`, `urlTest`, `getSingBoxVersion`.

EventChannels (in `SingBoxConnector`): `connected_status_event`, `group_event`, `clash_mode_event`, `log_event`, `proxy_state_event`.

Event payloads on the four data channels (`connected_status` / `group` / `clash_mode` / `log`) are **JSON-encoded strings** (kotlinx-serialization) of the `cs/models/*` DTOs. These mirror the Dart models in `lib/src/data/models/client/` — when changing a field, update both sides in lockstep or the Dart decode breaks at runtime. **`proxy_state_event` is the exception**: it sends the bare `Status` enum name (e.g. `"Started"`) via `success`, and abnormal stops arrive as an EventChannel **error** (code = `Status.Stopped.name`, message = the alert text from `onServiceAlert`), so the Dart side must handle both shapes.

## Vendored SFA Code Conventions

- Upstream SFA package/file names are preserved on purpose so the code can be diffed against upstream. Don't rename `io.nekohasekai.sfa` classes to "nicer" names.
- Large blocks of commented-out SFA code (imports of `io.nekohasekai.sfa.database.Settings`, `Application`, per-app-proxy handling, …) mark spots where SFA's own single-app logic was replaced by this plugin's `SettingsManager` / `ProfileManager`. They are reference material, not TODOs — don't "restore" them.
- `bg/LogEntry.java`, `PackageEntry.java`, `ParceledListSlice.java` are Java because AIDL parcelables require it.
- **libbox 1.14 API changes** (already adapted here; relevant when diffing against older SFA or upgrading libbox):
  - `Libbox.redirectStderr` no longer exists — `Libbox.setup` itself redirects stderr to `workingDir/CrashReport-<source>.log` (see `PluginManager.initSingBox`).
  - `libbox.Notification.identifier` is now a notification tag, and the channel ID is derived from `typeID` (see `BoxService.sendNotification`).
  - `TunOptions.dnsServerAddress` became an iterator, guarded by the new `dnsMode` check (see `VPNService.openTun`).
  - `CommandClientHandler.writeOutbounds` is a new callback; this plugin doesn't subscribe to `CommandOutbounds`, so it stays empty.

## Known Stubs / Gotchas

- `FlutterSingBoxPluginTest` is leftover plugin-template code: it tests a `getPlatformVersion` method that no longer exists in `onMethodCall`, so it fails if actually run. Don't assume `testDebugUnitTest` is green.
- `BootReceiver` (auto-start on boot when `startedByUser`) exists but is **not registered** in the manifest — currently dormant.
- `ProxyService` is also **not registered** in the manifest (only `VPNService` is). `SettingsManager.serviceClass()` returns it when `service_mode != vpn`, but `startForegroundService`/`bindService` on an unregistered service throws. In practice the mode never changes: the MethodChannel exposes no setter for `service_mode`, so it stays at the default `vpn`.
- `consumer-rules.pro` keeps AIDL stubs under `com.clashsing.flutter_sing_box.aidl.**`, but the generated stubs actually live in `io.nekohasekai.sfa.aidl` — that rule matches nothing, and no rule keeps `io.nekohasekai.sfa.**` at all. Watch this if a host app enables R8/minification.
- `BoxService` uses `GlobalScope` + `runBlocking` in several places (inherited from SFA); be careful adding code that assumes structured cancellation.
- `CommandClient.connect()` swallows its own exceptions (logs `connect failed` and returns) — a failed connect never reaches Dart; the channel just stays silent until the next `connect()` call.
