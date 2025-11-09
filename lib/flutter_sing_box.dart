export '../src/settings/sing_box_manager.dart';
export '../src/services/index.dart';
export '../src/models/index.dart';
export '../src/const/index.dart';
export '../src/profile/index.dart';

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

  Future<void> setClashMode(String clashMode) {
    return FlutterSingBoxPlatform.instance.setClashMode(clashMode);
  }

  Future<void> setOutbound({required String groupTag, required String outboundTag}) {
    return FlutterSingBoxPlatform.instance.setOutbound(groupTag: groupTag, outboundTag: outboundTag);
  }

  Future<void> setGroupExpand({required String groupTag, required bool isExpand}) {
    return FlutterSingBoxPlatform.instance.setGroupExpand(groupTag: groupTag, isExpand: isExpand);
  }

  Stream<ClientStatus> get connectedStatusStream =>
      FlutterSingBoxPlatform.instance.connectedStatusStream;

  Stream<List<ClientGroup>> get groupStream =>
      FlutterSingBoxPlatform.instance.groupStream;

  Stream<ClientClashMode> get clashModeStream =>
      FlutterSingBoxPlatform.instance.clashModeStream;

  Stream<List<String>> get logStream =>
      FlutterSingBoxPlatform.instance.logStream;

  Stream<ProxyState> get proxyStateStream =>
      FlutterSingBoxPlatform.instance.proxyStateStream;
}
