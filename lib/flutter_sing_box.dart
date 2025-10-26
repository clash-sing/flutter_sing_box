export '../src/settings/sing_box_manager.dart';
export '../src/services/services.dart';
export '../src/models/models.dart';
export '../src/const/const.dart';
export '../src/profile/profile.dart';

import 'flutter_sing_box_platform_interface.dart';

class FlutterSingBox {
  Stream<dynamic> get vpnStatusStream =>
      FlutterSingBoxPlatform.instance.vpnStatusStream;

  Future<String?> getPlatformVersion() {
    return FlutterSingBoxPlatform.instance.getPlatformVersion();
  }

  Future<void> init(bool isDebug) {
    return FlutterSingBoxPlatform.instance.init(isDebug);
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
