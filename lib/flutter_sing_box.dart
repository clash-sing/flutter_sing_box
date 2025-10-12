
import 'dart:convert';

import 'package:flutter_sing_box/src/schema/singbox/sing_box.dart';
import 'package:flutter_sing_box/src/settings/sing_box_manager.dart';
import 'package:collection/collection.dart'; // 用于 firstWhereOrNull

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
    final jsonObject = json.decode(result);
    final singBox = SingBox.fromJson(jsonObject);
    final outbound = singBox.outbounds.firstWhereOrNull(
            (item) => item.type == "selector"
    );
    outbound?.outbounds?.insert(0, "auto");
    final content = json.encode(singBox.toJson());
    singBoxManager.profile = content;
    return content;
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
