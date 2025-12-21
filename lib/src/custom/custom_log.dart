import 'dart:convert';

import 'package:flutter_sing_box/flutter_sing_box.dart';
import 'package:flutter_sing_box/src/constants/log_level.dart';
import 'package:flutter_sing_box/src/custom/custom_keys.dart';
import 'package:flutter_sing_box/src/custom/custom_manager.dart';

class CustomLog {
  Log getCustom() {
    String? strCustom = CustomManager().mmkv.decodeString(CustomKeys.log);
    if (strCustom == null) {
      return defaultLog;
    } else {
      try {
        final map = jsonDecode(strCustom);
        return Log.fromJson(map);
      } catch (e) {
        return defaultLog;
      }
    }
  }

  void setCustom(Log log) {
    CustomManager().mmkv.encodeString(CustomKeys.log, jsonEncode(log));
  }

  void clear() {
    CustomManager().mmkv.removeValue(CustomKeys.log);
  }

  Log get defaultLog {
    return Log(
      disabled: false,
      level: LogLevel.trace.level,
      output: null,
      timestamp: true,
    );
  }

}