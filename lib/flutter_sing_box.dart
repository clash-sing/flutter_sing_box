export '../src/data/models/index.dart';
export '../src/constants/index.dart';
export '../src/utils/index.dart';
export '../src/core/index.dart';

import 'flutter_sing_box.dart';
import 'flutter_sing_box_platform_interface.dart';

/// The main class for interacting with the flutter_sing_box plugin.
class FlutterSingBox {
  /// Initializes the plugin.
  Future<void> init() async {
    return await FlutterSingBoxPlatform.instance.init();
  }

  /// Starts the VPN service.
  Future<void> startVpn() async {
    return await FlutterSingBoxPlatform.instance.startVpn();
  }

  /// Stops the VPN service.
  Future<void> stopVpn() async {
    return await FlutterSingBoxPlatform.instance.stopVpn();
  }

  /// Reloads the service configuration.
  Future<void> serviceReload() async {
    return await FlutterSingBoxPlatform.instance.serviceReload();
  }

  /// Sets the Clash mode.
  ///
  /// [clashMode] The new Clash mode to set (e.g., 'Global', 'Rule', 'Direct').
  Future<void> setClashMode(String clashMode) async {
    return await FlutterSingBoxPlatform.instance.setClashMode(clashMode);
  }

  /// Selects an outbound for a specific group.
  ///
  /// [groupTag] The tag of the group.
  /// [outboundTag] The tag of the outbound to select.
  Future<void> selectOutbound({required String groupTag, required String outboundTag}) async {
    return await FlutterSingBoxPlatform.instance.selectOutbound(groupTag: groupTag, outboundTag: outboundTag);
  }

  /// Sets the expansion state of a group in the UI.
  ///
  /// [groupTag] The tag of the group.
  /// [isExpand] Whether the group should be expanded or collapsed.
  Future<void> setGroupExpand({required String groupTag, required bool isExpand}) async {
    return await FlutterSingBoxPlatform.instance.setGroupExpand(groupTag: groupTag, isExpand: isExpand);
  }

  /// Performs a URL test for a specific group.
  ///
  /// [groupTag] The tag of the group to test.
  Future<void> urlTest({required String groupTag}) async {
    return await FlutterSingBoxPlatform.instance.urlTest(groupTag: groupTag);
  }

  /// Gets the version of the underlying sing-box core.
  Future<String> getSingBoxVersion() async {
    return await FlutterSingBoxPlatform.instance.getSingBoxVersion();
  }

  /// A stream of client connection status updates.
  Stream<ClientStatus> get connectedStatusStream =>
      FlutterSingBoxPlatform.instance.connectedStatusStream;

  /// A stream of client group updates.
  Stream<List<ClientGroup>> get groupStream =>
      FlutterSingBoxPlatform.instance.groupStream;

  /// A stream of client Clash mode updates.
  Stream<ClientClashMode> get clashModeStream =>
      FlutterSingBoxPlatform.instance.clashModeStream;

  /// A stream of log messages from the sing-box core.
  Stream<List<String>> get logStream =>
      FlutterSingBoxPlatform.instance.logStream;

  /// A stream of proxy state updates.
  Stream<ProxyState> get proxyStateStream =>
      FlutterSingBoxPlatform.instance.proxyStateStream;
}
