import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_sing_box/src/utils/clash_ext.dart';
import 'package:yaml/yaml.dart';

import '../../flutter_sing_box.dart';
import '../models/clash/clash.dart';

class SingBoxConfig {
  static Future<SingBox> buildConfig(final dynamic data) async {
    SingBox? singBox;
    try {
      if (data is Map<String, dynamic>) {
        try {
          singBox = SingBox.fromJson(data);
        } catch (e) {
          singBox = await _fixSingBoxConfig(data);
        }
      } else if (data is String) {
        try {
          final config = jsonDecode(data);
          singBox = SingBox.fromJson(config);
        } catch (e) {
          try {
            final YamlMap yamlMap = loadYaml(data);
            final outbounds = _clash2SingBoxOutbounds(yamlMap);
            final List<Map<String, dynamic>> listMap = outbounds.map((element) => element.toJson()).toList();
            singBox = await _fixSingBoxConfig({"outbounds": listMap});
          } catch (e) {
            String decodedString = utf8.decode(base64.decode(data));
            debugPrint(decodedString);
          }
        }
      }
    } catch (e) {
      debugPrint(e.toString());
    }
    if (singBox != null) {
      return singBox;
    } else {
      singBox = throw Exception("Invalid content");
    }
  }

  static List<Outbound> _clash2SingBoxOutbounds(final YamlMap yamlMap) {
    final Map<String, dynamic> clashMap = yamlMap.toMap();
    final clash = Clash.fromJson(clashMap);
    final List<Outbound> outbounds = [];
    for (var element in clash.proxies) {
      final outbound = element.toOutbound();
      if (outbound != null) {
        outbounds.add(outbound);
      } else {
        debugPrint('${element.name} is not support');
      }
    }
    for (var element in clash.proxyGroups.reversed) {
      final outbound = element.toOutbound();
      if (outbound != null) {
        outbounds.insert(0, outbound);
      } else {
        debugPrint('${element.name} is not support');
      }
    }
    return outbounds;
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
    final allTags = defaultSingBox.outbounds.map((outbound) => outbound.tag).toList();
    final groups = defaultSingBox.outbounds.where((outbound) => outbound.outbounds?.isNotEmpty == true);
    for (var group in groups) {
      if (group.defaultTag?.isNotEmpty == true && errorTags.contains(group.defaultTag)) {
        // 移除错误的 默认 tag
        group.defaultTag = null;
      }
      group.outbounds?.removeWhere((tag) => !allTags.contains(tag));
    }
    if (defaultSingBox.outbounds.indexWhere((outbound) => outbound.type == OutboundType.direct) == -1) {
      // 查找最后一个 group 的索引
      final index = defaultSingBox.outbounds.lastIndexWhere((outbound) => outbound.outbounds?.isNotEmpty == true);
      final directOutbound = Outbound(
        tag: OutboundType.direct,
        type: OutboundType.direct,
      );
      defaultSingBox.outbounds.insert(index+1, directOutbound);
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