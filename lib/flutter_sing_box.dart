
import 'package:flutter_sing_box/src/settings/sing_box_manager.dart';

import 'flutter_sing_box_platform_interface.dart';

class FlutterSingBox {

  Future<String?> getPlatformVersion() {
    return FlutterSingBoxPlatform.instance.getPlatformVersion();
  }

  Future<void> setup() {
    return FlutterSingBoxPlatform.instance.setup();
  }

  Future<String> importProfile(String url) async {
    String result = await FlutterSingBoxPlatform.instance.importProfile(url);
    singBoxManager.profile = result;
    return result;
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
