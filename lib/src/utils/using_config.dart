import 'dart:convert';
import 'dart:io';

import 'package:flutter_sing_box/flutter_sing_box.dart';
import 'package:flutter_sing_box/src/custom/custom_log.dart';

class UsingConfig {
  static Future<void> create() async {
    final Profile? profile = ProfileManager().getSelectedProfile();
    if (profile != null) {
      final srcFile = File(profile.typed.path);
      if (await srcFile.exists()) {
        final content = await srcFile.readAsString();
        final singBox = SingBox.fromJson(jsonDecode(content));
        singBox.log = CustomLog().getCustom();
        await _writeUsingConfig(singBox);
      }
    }
  }

  static Future<void> _writeUsingConfig(SingBox singBox) async {
    final File file = await ProfileManager().getUsingConfig();
    if (!await file.exists()) {
      await file.create(recursive: true);
    }
    await file.writeAsString(jsonEncode(singBox.toJson()));
    ProfileManager().setUsingConfig(file.parent.path);
  }

}