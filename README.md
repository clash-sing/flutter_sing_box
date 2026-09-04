# flutter_sing_box

[![pub package](https://img.shields.io/pub/v/flutter_sing_box.svg)](https://pub.dev/packages/flutter_sing_box)
[![license](https://img.shields.io/github/license/clash-sing/flutter_sing_box.svg)](https://github.com/clash-sing/flutter_sing_box/blob/master/LICENSE)

English | [中文简体](README_CN.md)

A powerful Flutter plugin for [sing-box](https://github.com/SagerNet/sing-box), the universal proxy platform.

## 🚀 Projects Using This Plugin

- [**clash_sing**](https://github.com/clash-sing/clash_sing): A full-featured GUI client based on sing-box and Clash, providing a powerful and intuitive user experience.

## Features

- **VPN / Service Management**: Start and stop VPN services on Android (VpnService); on Windows, sing-box is hosted as a system service, with `installService()` / `uninstallService()` / `queryServiceStatus()` for service lifecycle management.
- **Dual Proxy Modes (Windows)**: Tun mode (system-wide transparent proxying via a virtual network adapter) and System Proxy mode (registry-based, covering apps that respect the system proxy).
- **Advanced Configuration Support**:
    - **Native sing-box**: Direct support for native JSON configurations.
    - **YAML to sing-box**: Automatic conversion of Clash-style YAML configurations.
    - **Base64 to sing-box**: Seamless parsing of Base64 encoded subscription links.
- **Profile Management**: Import, manage, and switch between local and remote profiles (subscription links).
- **Clash API Support**: Full support for Clash-compatible API for managing proxies, groups, and selecting outbounds.
- **Real-time Monitoring**: Monitor connection status, traffic (uplink/downlink), and logs in real-time via streams.
- **Multi-Protocol Support**: Inherits support for various protocols from sing-box, including Hysteria, TUIC, WireGuard, Shadowsocks, and more.

## Platform Support

| Platform | Support | Status |
| :--- |:-------:| :--- |
| Android |    ✅    | Production Ready |
| Windows |    ✅    | Production Ready |
| iOS |    ☐    | Planned |
| macOS |   ☐️    | Planned |
| Linux |    ☐    | Planned |

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

### Windows Notes

On Windows, sing-box runs as a system service (`clash_sing_service`) instead of a VPN service:

- Call `installService()` once to install the service (this triggers a UAC elevation prompt). Use `queryServiceStatus()` to check its state and `uninstallService()` to remove it.
- `startVpn()` / `stopVpn()` map to starting and stopping the service.
- Two proxy modes are available via `ProxyMode`: `tun` (default, system-wide transparent proxying) and `systemProxy` (registry-based system proxy, default mixed port `8890`).

## Example

Check out the [example](https://github.com/clash-sing/flutter_sing_box/tree/master/example) directory for a complete demo application using Riverpod for state management.

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request or open an issue if you encounter any bugs or have feature requests.

## License

This project is licensed under the [GPL-3.0 License](LICENSE).
