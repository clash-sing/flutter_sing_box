import 'dart:convert';

import 'package:flutter/material.dart';
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
    final List<String> errorTags =  [];
    List<dynamic> outbounds = data['outbounds'];
    for (var outbound in outbounds) {
      Outbound? sbOutbound;
      try {
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
          case OutboundType.hysteria2:
            sbOutbound = Outbound.fromJson(outbound);
            break;
          case OutboundType.hysteria:
            sbOutbound = Outbound.fromJson(outbound);
            break;
          case OutboundType.trojan:
            sbOutbound = Outbound.fromJson(outbound);
            break;
          case OutboundType.anytls:
            sbOutbound = Outbound.fromJson(outbound);
            break;
          case OutboundType.vmess:
            sbOutbound = Outbound.fromJson(outbound);
            break;
          case OutboundType.vless:
            sbOutbound = Outbound.fromJson(outbound);
            break;
          default:
            break;
        }
      } catch (e) {
        errorTags.add(outbound["tag"]);
      }
      if (sbOutbound != null) {
        defaultSingBox.outbounds.add(sbOutbound);
      }
    }
    if (errorTags.isNotEmpty) {
      // 从 【代理组】 中移除错误的 tag
      for (var outbound in defaultSingBox.outbounds) {
        if (outbound.outbounds?.isNotEmpty ?? false) {
          if (outbound.defaultTag?.isNotEmpty ?? false) {
            if (errorTags.contains(outbound.defaultTag)) {
              // 移除错误的 默认 tag
              outbound.defaultTag = null;
            }
          }
          outbound.outbounds?.removeWhere((element) {
            return errorTags.contains(element);
          });
        }
      }
    }
    _fixOutboundInRoute(defaultSingBox);
    return defaultSingBox;
  }

  static SingBox _fixOutboundInRoute(SingBox singBox) {
    List<String> tags = singBox.outbounds.map((element) => element.tag ).toList();
    if(!tags.contains(singBox.route.routeFinal)) {
      final firstOutbound = singBox.outbounds.firstWhere((element) => element.type == OutboundType.selector);
      singBox.route.routeFinal = firstOutbound.tag;
    }
    for (var routeRule in singBox.route.rules) {
      if (routeRule.outbound?.isNotEmpty ?? false) {
        if (routeRule.outbound != OutboundType.direct && routeRule.outbound != singBox.route.routeFinal) {
          routeRule.outbound = singBox.route.routeFinal;
        }
      }
    }

    return singBox;
  }
}