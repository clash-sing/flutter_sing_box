
import 'flutter_sing_box_platform_interface.dart';

class FlutterSingBox {

  Future<String?> getPlatformVersion() {
    return FlutterSingBoxPlatform.instance.getPlatformVersion();
  }

  Future<void> setup() {
    return FlutterSingBoxPlatform.instance.setup();
  }

  Future<String> importProfile(String url) {
    return FlutterSingBoxPlatform.instance.importProfile(url);
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
