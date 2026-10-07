import 'dart:io' as io;

import 'package:flutter_sing_box/flutter_sing_box.dart';

/// Builds the default User-Agent string for subscription requests.
class SubscribeUserAgent {
  static String? _cachedVersion;

  /// Returns the default User-Agent string for the current platform.
  static Future<String> getDefaultUserAgent() async {
    _cachedVersion ??= await FlutterSingBox().getSingBoxVersion();
    final String version = _cachedVersion!;
    const String mihomo = 'mihomo/1.19.32';
    const String v2ray = 'v2ray/5.22.0';

    String? client;
    if (io.Platform.isIOS) {
      client = 'SFI/$version (iOS)';
    } else if (io.Platform.isAndroid) {
      client = 'SFA/$version (Android)';
    } else if (io.Platform.isWindows) {
      client = 'SFW/$version (Windows)';
    } else if (io.Platform.isMacOS) {
      client = 'SFM/$version (Macintosh)';
    } else if (io.Platform.isLinux) {
      client = 'SFL/$version (Linux)';
    }
    final String cores = 'sing-box/$version $mihomo $v2ray';
    return client == null ? cores : '$client $cores';
  }
}
