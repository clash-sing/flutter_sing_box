import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_sing_box/src/const/outbound_type.dart';
import 'package:yaml/yaml.dart';

import '../../flutter_sing_box.dart';

class SingBoxConfig {
  static Future<SingBox> buildConfig(dynamic data) async {
    SingBox? singBox;
    if (data is Map<String, dynamic>) {
      try {
        singBox = SingBox.fromJson(data);
      } catch (e) {
        singBox = await _fixSingBoxConfig(data);
      }
    } else if (data is String) {
      try {
        final config = jsonDecode(data);
        final singBox = SingBox.fromJson(config);
        return singBox;
      } catch (e) {
        final yaml = loadYaml(data);
        throw Exception(e);
      }
    }
    if (singBox != null) {
      return singBox;
    } else {
      singBox = throw Exception("Invalid content");
    }
  }

  static Future<SingBox?> _fixSingBoxConfig(Map<String, dynamic> data) async {
    const defaultConfigPath = 'packages/flutter_sing_box/assets/default_config.json';
    final defaultConfig = await rootBundle.loadString(defaultConfigPath);
    final jsonConfig = jsonDecode(defaultConfig);
    final defaultSingBox = SingBox.fromJson(jsonConfig);
    List<dynamic> outbounds = data['outbounds'];
    for (var outbound in outbounds) {
      Outbound? sbOutbound;
      switch (outbound['type']) {
        case OutboundType.selector:
          sbOutbound = Outbound.fromJson(outbound);
          break;
        case OutboundType.urltest:
          sbOutbound = Outbound.fromJson(outbound);
          break;
        case OutboundType.direct:
          sbOutbound = Outbound.fromJson(outbound);
          break;
        default:
          break;
      }
      if (sbOutbound != null) {
        defaultSingBox.outbounds.add(sbOutbound);
      }
    }
    return defaultSingBox;
  }
}