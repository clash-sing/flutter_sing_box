# flutter_sing_box

[![pub package](https://img.shields.io/pub/v/flutter_sing_box.svg)](https://pub.dev/packages/flutter_sing_box)
[![license](https://img.shields.io/github/license/clash-sing/flutter_sing_box.svg)](https://github.com/clash-sing/flutter_sing_box/blob/master/LICENSE)

English | [中文文档](README_CN.md)

A powerful Flutter plugin for [sing-box](https://github.com/SagerNet/sing-box), the universal proxy platform.

## 🚀 Projects Using This Plugin

- [**clash_sing_app**](https://github.com/clash-sing/clash_sing_app): A full-featured GUI client based on sing-box and Clash, providing a powerful and intuitive user experience.

## Features

- **VPN Service Management**: Easily start and stop VPN services on supported platforms.
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
| iOS |    ☐    | Planned |
| Windows |   ☐️    | Planned |
| macOS |   ☐️    | Planned |
| Linux |    ☐    | Planned |

## Getting Started

### Installation

Add `flutter_sing_box` to your `pubspec.yaml`:

```yaml
dependencies:
  flutter_sing_box: ^1.0.1
```

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

## Example

Check out the [example](https://github.com/clash-sing/flutter_sing_box/tree/master/example) directory for a complete demo application using Riverpod for state management.

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request or open an issue if you encounter any bugs or have feature requests.

## License

This project is licensed under the [GPL-3.0 License](LICENSE).
