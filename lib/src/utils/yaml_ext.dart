import 'package:yaml/yaml.dart';

extension YamlMapExt on YamlMap {
  dynamic _convertNode(dynamic v) {
    if (v is YamlMap) {
      return _convertYamlMap(v);
    } else if (v is YamlList) {
      return _convertYamlList(v);
    } else if (v is YamlScalar) {
      return v.value;
    } else {
      return v;
    }
  }

  Map<String, dynamic> _convertYamlMap(YamlMap yamlMap) {
    var map = <String, dynamic>{};
    yamlMap.nodes.forEach((key, value) {
      if (key is YamlScalar) {
        map[key.value.toString()] = _convertNode(value);
      }
    });
    return map;
  }

  List<dynamic> _convertYamlList(YamlList yamlList) {
    var list = <dynamic>[];
    for (var item in yamlList) {
      list.add(_convertNode(item));
    }
    return list;
  }

  Map<String, dynamic> toMap() {
    return _convertYamlMap(this);
  }

}