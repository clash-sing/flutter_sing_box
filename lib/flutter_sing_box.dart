export '../src/data/models/index.dart';
export '../src/constants/index.dart';
export '../src/utils/index.dart';
export '../src/core/index.dart';

import 'flutter_sing_box.dart';
import 'flutter_sing_box_platform_interface.dart';

class FlutterSingBox {
  Future<void> init() async {
    return await FlutterSingBoxPlatform.instance.init();
  }

  /// Starts the VPN service
  Future<void> startVpn() async {
    return await FlutterSingBoxPlatform.instance.startVpn();
  }

  /// Stops the VPN service
  Future<void> stopVpn() async {
    return await FlutterSingBoxPlatform.instance.stopVpn();
  }

  Future<void> serviceReload() async {
    return await FlutterSingBoxPlatform.instance.serviceReload();
  }

  Future<void> setClashMode(String clashMode) async {
    return await FlutterSingBoxPlatform.instance.setClashMode(clashMode);
  }

  Future<void> selectOutbound({required String groupTag, required String outboundTag}) async {
    return await FlutterSingBoxPlatform.instance.selectOutbound(groupTag: groupTag, outboundTag: outboundTag);
  }

  Future<void> setGroupExpand({required String groupTag, required bool isExpand}) async {
    return await FlutterSingBoxPlatform.instance.setGroupExpand(groupTag: groupTag, isExpand: isExpand);
  }

  Future<void> urlTest({required String groupTag}) async {
    return await FlutterSingBoxPlatform.instance.urlTest(groupTag: groupTag);
  }

  Future<String> getSingBoxVersion() async {
    return await FlutterSingBoxPlatform.instance.getSingBoxVersion();
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
