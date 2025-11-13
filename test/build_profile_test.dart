import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_sing_box/flutter_sing_box.dart';
import 'package:flutter_sing_box/src/models/clash/clash.dart';
import 'package:flutter_sing_box/src/utils/base64_parser.dart';
import 'package:flutter_sing_box/src/utils/clash_ext.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yaml/yaml.dart';

void main() async {
  TestWidgetsFlutterBinding.ensureInitialized();
// 为package_info_plus设置mock handler以防止MissingPluginException
  const MethodChannel packageInfoChannel = MethodChannel('dev.fluttercommunity.plus/package_info');
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(packageInfoChannel, (MethodCall methodCall) async {
    if (methodCall.method == 'getAll') {
      return <String, dynamic>{
        'appName': 'Test App',
        'packageName': 'com.example.test',
        'version': '1.0.0',
        'buildNumber': '1',
        'buildSignature': '',
      };
    }
    return null;
  });

  // 为device_info_plus设置mock handler以防止MissingPluginException
  const MethodChannel deviceInfoChannel = MethodChannel('dev.fluttercommunity.plus/device_info');
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(deviceInfoChannel, (MethodCall methodCall) async {
    if (methodCall.method == 'getDeviceInfo') {
      return <String, dynamic>{
        'name': 'Android',
        'version': '11',
        'model': 'Android',
      };
    }
    return null;
  });


  test('loadYaml', () async {
    var yamlStr = await rootBundle.loadString('assets/.local/test_sub.yaml');
    final YamlMap yaml = loadYaml(yamlStr);
    final Map<String, dynamic> map = yaml.toMap();
    final clash = Clash.fromJson(map);
    final List<Outbound> outbounds = [];
    for (var element in clash.proxies) {
      final outbound = element.toOutbound();
      if (outbound != null) {
        outbounds.add(outbound);
      } else {
        debugPrint('${element.name} is not support');
      }
    }
    debugPrint(outbounds.toString());

    final List<Outbound> groupOutbounds = [];
    for (var element in clash.proxyGroups) {
      final outbound = element.toOutbound();
      if (outbound != null) {
        groupOutbounds.add(outbound);
      } else {
        debugPrint('${element.name} is not support');
      }
    }
    debugPrint(groupOutbounds.toString());
  });

  test('testBase64Parser', () async {
    var base64String = await rootBundle.loadString('assets/.local/test_base64.txt');
    // 移除可能的空白字符
    base64String = base64String.replaceAll(RegExp(r'\s+'), '');
    String decodedString = utf8.decode(base64.decode(base64String));
    final parser = Base64Parser.parse(decodedString);
  });
}