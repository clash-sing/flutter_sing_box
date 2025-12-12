import 'dart:convert';
import 'dart:io';

import 'package:flutter_sing_box/flutter_sing_box.dart';

extension ProfileExt on Profile {
  Future<SingBox?> get singBox async  {
    if(!await file.exists()) {
      return null;
    } else {
      final content = await file.readAsString();
      Map<String, dynamic> map = jsonDecode(content);
      return SingBox.fromJson(map);
    }
  }

  File get file => File(typed.path);

}