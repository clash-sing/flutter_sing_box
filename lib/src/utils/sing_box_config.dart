import 'dart:convert';

import 'package:yaml/yaml.dart';

import '../../flutter_sing_box.dart';

class SingBoxConfig {
  static SingBox buildConfig(String data) {
    try {
      final config = jsonDecode(data);
      final singBox = SingBox.fromJson(config);
      return singBox;
    } catch (e) {
      final yaml = loadYaml(data);
      throw Exception(e);
    }
  }
}