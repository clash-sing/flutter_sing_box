import 'dart:io' as io;

import 'package:flutter_sing_box/flutter_sing_box.dart';

class SubscribeUserAgent {
  static String? _cachedVersion;

  static Future<String> getDefaultUserAgent() async {
    _cachedVersion ??= await FlutterSingBox().getSingBoxVersion();
    const String clashVerge = 'clash-verge/2.4.7';

    if (io.Platform.isIOS) {
      return 'SFI/$_cachedVersion sing-box/$_cachedVersion $clashVerge';
    } else if (io.Platform.isAndroid) {
      return 'SFA/$_cachedVersion sing-box/$_cachedVersion ClashMetaForAndroid/2.11.27 $clashVerge';
    } else if (io.Platform.isWindows) {
      return 'SFW/$_cachedVersion sing-box/$_cachedVersion $clashVerge ClashForWindows/0.19.23';
    } else if (io.Platform.isMacOS) {
      return 'SFM/$_cachedVersion sing-box/$_cachedVersion $clashVerge';
    } else if (io.Platform.isLinux) {
      return 'SFL/$_cachedVersion sing-box/$_cachedVersion $clashVerge';
    } else {
      return 'sing-box/$_cachedVersion $clashVerge';
    }
  }
}
