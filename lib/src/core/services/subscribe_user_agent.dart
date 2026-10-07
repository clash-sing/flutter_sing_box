import 'package:flutter_sing_box/flutter_sing_box.dart';

/// Builds the default User-Agent string for subscription requests.
class SubscribeUserAgent {
  static String? _cachedVersion;

  static Future<String> getCoresInUserAgent() async {
    _cachedVersion ??= await FlutterSingBox().getSingBoxVersion();
    const String mihomo = 'mihomo/1.19.32';
    const String v2ray = 'v2ray/5.22.0';
    return 'sing-box/$_cachedVersion $mihomo $v2ray';
  }

  /// Returns the default User-Agent string for the current platform.
  static Future<String> getDefaultUserAgent() async {
    return await getCoresInUserAgent();
    // TODO：服务端不识别 SFW/${Version}，待服务端修复后，再打开下面的代码。

    // _cachedVersion ??= await FlutterSingBox().getSingBoxVersion();
    // String? client;
    // if (io.Platform.isIOS) {
    //   client = 'SFI/$_cachedVersion (iOS)';
    // } else if (io.Platform.isAndroid) {
    //   client = 'SFA/$_cachedVersion (Android)';
    // } else if (io.Platform.isWindows) {
    //   client = 'SFW/$_cachedVersion (Windows)';
    // } else if (io.Platform.isMacOS) {
    //   client = 'SFM/$_cachedVersion (Macintosh)';
    // } else if (io.Platform.isLinux) {
    //   client = 'SFL/$_cachedVersion (Linux)';
    // }
    // final String cores = await getCoresInUserAgent();
    // return client == null ? cores : '$client $cores';
  }
}
