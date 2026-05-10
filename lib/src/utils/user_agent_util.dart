import 'dart:io' as io;

import 'package:flutter_sing_box/flutter_sing_box.dart';

class UserAgentUtil {
  static Future<String> getDefaultUserAgent() async {
    final String singBoxVersion = await FlutterSingBox().getSingBoxVersion();
    const String clashVerge = 'clash-verge/2.4.7';

    if (io.Platform.isIOS) {
      return 'SFI/$singBoxVersion sing-box/$singBoxVersion $clashVerge';
    } else if (io.Platform.isAndroid) {
      return 'SFA/$singBoxVersion sing-box/$singBoxVersion ClashMetaForAndroid/2.11.27 $clashVerge';
    } else if (io.Platform.isWindows) {
      return 'SFW/$singBoxVersion sing-box/$singBoxVersion $clashVerge ClashForWindows/0.19.23';
    } else if (io.Platform.isMacOS) {
      return 'SFM/$singBoxVersion sing-box/$singBoxVersion $clashVerge';
    } else if (io.Platform.isLinux) {
      return 'SFL/$singBoxVersion sing-box/$singBoxVersion $clashVerge';
    } else {
      return 'sing-box/$singBoxVersion $clashVerge';
    }
  }
}
