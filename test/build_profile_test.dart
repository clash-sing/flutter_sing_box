import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_sing_box/flutter_sing_box.dart';
import 'package:flutter_sing_box/flutter_sing_box_method_channel.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mmkv/mmkv.dart';
import 'package:yaml/yaml.dart';

void main() async {
  TestWidgetsFlutterBinding.ensureInitialized();
// 为package_info_plus设置mock handler以防止MissingPluginException
  const MethodChannel packageInfoChannel = MethodChannel('dev.fluttercommunity.plus/package_info');
  packageInfoChannel.setMockMethodCallHandler((MethodCall methodCall) async {
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
  deviceInfoChannel.setMockMethodCallHandler((MethodCall methodCall) async {
    if (methodCall.method == 'getDeviceInfo') {
      return <String, dynamic>{
        'name': 'Windows',
        'version': '10.0.19044',
        'model': 'Windows PC',
      };
    }
    return null;
  });

  test('importRemote', () async {
    var yamlStr = await rootBundle.loadString('assets/.local/test_link.yaml');
    final YamlMap yaml = loadYaml(yamlStr);
    final map = yaml.toMap();
    final uri = Uri.parse(map['link1']);
    final apiResult = await networkService.fetchSubscription(uri);
    debugPrint(apiResult.data.toString());
  });

  test('loadYaml', () async {
    var yamlStr = await rootBundle.loadString('assets/.local/test_sub.yaml');
    final YamlMap yaml = loadYaml(yamlStr);
    final Map<String, dynamic> map = yaml.toMap();
    debugPrint(map.toString());
  });
}