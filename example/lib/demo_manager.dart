import 'package:flutter/services.dart';
import 'package:yaml/yaml.dart';

class DemoManager {
  static final DemoManager _instance = DemoManager._internal();
  factory DemoManager() => _instance;
  DemoManager._internal();

  late YamlMap _yamlMap;
  var _isLoaded = false;
  Future<void> loadData() async {
    if (!_isLoaded) {
      final strData = await rootBundle.loadString('assets/demo_data.yaml');
      _yamlMap = loadYaml(strData);
      _isLoaded = true;
    }
  }
  String getSubscriptionLink01() {
    return _getValue('subscription_link_01') as String;
  }
  dynamic _getValue(String key) {
    if (!_isLoaded) {
      throw StateError('Config not loaded. Call loadConfig() first.');
    }
    return _yamlMap[key];
  }
}
final demoManager = DemoManager();