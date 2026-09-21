# flutter_sing_box

[![pub package](https://img.shields.io/pub/v/flutter_sing_box.svg)](https://pub.dev/packages/flutter_sing_box)
[![license](https://img.shields.io/github/license/clash-sing/flutter_sing_box.svg)](https://github.com/clash-sing/flutter_sing_box/blob/master/LICENSE)

English | [中文简体](https://github.com/clash-sing/flutter_sing_box/blob/main/README_CN.md)

A powerful Flutter plugin for [sing-box](https://github.com/SagerNet/sing-box), the universal proxy platform, bundling the sing-box `1.14.1` core on Android and Windows.

## 🚀 Projects Using This Plugin

- [**clash-sing**](https://github.com/clash-sing/clash-sing): A full-featured GUI client based on sing-box and Clash, providing a powerful and intuitive user experience.

## Features

- **VPN / Service Management**: Start and stop VPN services on Android (VpnService); on Windows, sing-box is hosted as a system service, with `installService()` / `uninstallService()` / `queryServiceStatus()` for service lifecycle management.
- **Dual Proxy Modes (Windows)**: Tun mode (system-wide transparent proxying via a virtual network adapter) and System Proxy mode (registry-based, covering apps that respect the system proxy).
- **Advanced Configuration Support**:
    - **Native sing-box**: Direct support for native JSON configurations (the new DNS format is required — the legacy `dns.servers` format was removed in sing-box 1.14.1).
    - **YAML to sing-box**: Automatic conversion of Clash-style YAML configurations.
    - **Base64 to sing-box**: Seamless parsing of Base64 encoded subscription links.
- **Profile Management**: Import, manage, and switch between local and remote profiles (subscription links).
- **Clash API Support**: Full support for the Clash-compatible API — manage proxies and groups, select outbounds, test latency, and stream real-time logs over WebSocket (with automatic reconnection).
- **Real-time Monitoring**: Monitor connection status, traffic (uplink/downlink), and logs in real-time via streams; the proxy lifecycle is exposed as a `ProxyState` sealed class, whose `ProxyStopped.errMessage` carries the reason of an abnormal stop (start failure, core crash, etc.).
- **Multi-Protocol Support**: Inherits support for various protocols from sing-box, including Hysteria, TUIC, WireGuard, Shadowsocks, and more.

## Platform Support

| Platform | Support | Status |
| :--- |:-------:| :--- |
| Android |    ✅    | Production Ready |
| Windows |    ✅    | Production Ready |
| iOS |    ☐    | Planned |
| macOS |   ☐️    | Planned |
| Linux |    ☐    | Planned |

## Requirements

- Flutter `>=3.44.0` / Dart SDK `^3.12.0`

## Getting Started

### Initialization

Initialize the plugin in your `main()` function:

```dart
import 'package:flutter_sing_box/flutter_sing_box.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FlutterSingBox().init();
  runApp(MyApp());
}
```

### Basic Usage

#### Start VPN

```dart
try {
  await FlutterSingBox().startVpn();
} catch (e) {
  print("Failed to start VPN: $e");
}
```

> Since 2.0.0, startup failures on Windows are no longer thrown from this future — they are reported via `proxyStateStream` instead (see [Listen to Proxy State](#listen-to-proxy-state) below).

#### Stop VPN

```dart
await FlutterSingBox().stopVpn();
```

#### Listen to Status

```dart
FlutterSingBox().connectedStatusStream.listen((status) {
  print("Uplink: ${status.uplink}, Downlink: ${status.downlink}");
});
```

#### Listen to Proxy State

The proxy lifecycle is exposed as a `ProxyState` **sealed class** — `ProxyStopped` / `ProxyStarting` / `ProxyStarted` / `ProxyStopping` — best consumed with exhaustive pattern matching:

```dart
FlutterSingBox().proxyStateStream.listen((state) {
  switch (state) {
    case ProxyStopped(:final errMessage) when errMessage != null:
      print("Abnormally stopped: $errMessage");
    case ProxyStopped():
      print("Stopped");
    case ProxyStarting():
      print("Starting...");
    case ProxyStarted():
      print("Started");
    case ProxyStopping():
      print("Stopping...");
  }
});
```

`ProxyStopped.errMessage` is non-null when the service stopped abnormally (start failure, core crash) — on both Android and Windows, this is the single source of truth for startup failures.

### Windows Notes

On Windows, sing-box runs as a system service (`clash_sing_service`) instead of a VPN service:

- Call `installService()` once to install the service (this triggers a UAC elevation prompt). Use `queryServiceStatus()` to check its state and `uninstallService()` to remove it.
- `startVpn()` / `stopVpn()` map to starting and stopping the service.
- Since 2.0.0, `startVpn()` / `serviceReload()` failures no longer throw; the reason is emitted as `ProxyStopped(errMessage: ...)` on `proxyStateStream`.
- Two proxy modes are available via `ProxyMode`: `tun` (default, system-wide transparent proxying) and `systemProxy` (registry-based system proxy, default mixed port `8890`).

### Android 32-bit (armeabi-v7a) Builds

MMKV 2.x no longer supports 32-bit Android. If your app needs to ship an armeabi-v7a package (e.g. for 32-bit Android TV boxes), you can downgrade the `mmkv` dependency to 1.3.x — this plugin's constraint is relaxed (`>=1.3.17 <3.0.0`), and the native side reads the actually-resolved mmkv version from `pubspec.lock` and automatically pairs the same-version `com.tencent:mmkv` AAR, so you don't need to sync versions manually in Gradle:

```yaml
dependencies:
  mmkv: 1.3.17   # 32-bit Android lane; keep ^2.4.x for the 64-bit lane
```

Note: the Dart-side mmkv and the native AAR must be the same version (their cbridge signatures are incompatible across major versions); the automatic pairing mechanism guarantees this — do not override it by hand-writing an mmkv version in your app's Gradle.

### Migrating to 2.0.0

- **`ProxyState` is now a sealed class** — `ProxyStopped` / `ProxyStarting` / `ProxyStarted` / `ProxyStopping`, each its own `final class`. Exhaustive `switch`es over the old enum must migrate to type patterns (`case ProxyStopped():`). Legacy `== ProxyState.started`-style comparisons keep working via preserved `static const` compatibility constants, and `name` / `fromName()` keep their original semantics.
- **Windows: startup failures no longer throw.** `startVpn()` / `serviceReload()` emit the failure reason as `ProxyStopped(errMessage: ...)` on `proxyStateStream` (also resetting the state machine from `starting`), making the state stream the single source of truth for startup failures.

## Example

Check out the [example](https://github.com/clash-sing/flutter_sing_box/tree/master/example) directory for a complete demo application using Riverpod for state management.

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request or open an issue if you encounter any bugs or have feature requests.

## License

This project is licensed under the [GPL-3.0 License](LICENSE).
