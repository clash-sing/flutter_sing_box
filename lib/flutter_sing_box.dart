
import 'flutter_sing_box_platform_interface.dart';

class FlutterSingBox {

  Future<void> setup() {
    return FlutterSingBoxPlatform.instance.setup();
  }

  Future<String?> getPlatformVersion() {
    return FlutterSingBoxPlatform.instance.getPlatformVersion();
  }

  /// Starts the VPN service
  Future<void> startVpn() {
    return FlutterSingBoxPlatform.instance.startVpn();
  }

  /// Stops the VPN service
  Future<void> stopVpn() {
    return FlutterSingBoxPlatform.instance.stopVpn();
  }
}
