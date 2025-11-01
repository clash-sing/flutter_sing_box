export '../src/settings/sing_box_manager.dart';
export '../src/services/services.dart';
export '../src/models/models.dart';
export '../src/const/const.dart';
export '../src/profile/profile.dart';

import 'flutter_sing_box.dart';
import 'flutter_sing_box_platform_interface.dart';

class FlutterSingBox {
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

  Stream<StatusClient> get connectedStatusStream =>
      FlutterSingBoxPlatform.instance.connectedStatusStream;

  Stream<dynamic> get groupStream =>
      FlutterSingBoxPlatform.instance.groupStream;

  Stream<dynamic> get clashModeStream =>
      FlutterSingBoxPlatform.instance.clashModeStream;

}
