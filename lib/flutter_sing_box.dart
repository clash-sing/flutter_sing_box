export '../src/settings/sing_box_manager.dart';
export '../src/services/services.dart';
export '../src/models/models.dart';
export '../src/const/const.dart';
export '../src/profile/profile.dart';

import 'dart:convert';

import 'src/models/singbox/sing_box.dart';
import 'src/settings/sing_box_manager.dart';
import 'package:collection/collection.dart'; // 用于 firstWhereOrNull

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

  Future<SingBox> importProfile(String url) async {
    String result = await FlutterSingBoxPlatform.instance.importProfile(url);
    final jsonObject = json.decode(result);
    final singBox = SingBox.fromJson(jsonObject);
    final outbound = singBox.outbounds.firstWhereOrNull(
            (item) => item.type == "selector"
    );
    outbound?.outbounds?.insert(0, "auto");
    final content = json.encode(singBox.toJson());
    singBoxManager.profile = content;
    return singBox;
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
