import 'key_value_storage.dart';

/// 纯 Dart 内存存储，用于单元测试，零原生依赖。
class MemoryStorage implements KeyValueStorage {
  final _data = <String, dynamic>{};

  @override
  String? getString(String key) => _data[key] as String?;

  @override
  bool setString(String key, String value) {
    _data[key] = value;
    return true;
  }

  @override
  int getInt(String key, {int defaultValue = 0}) => (_data[key] as int?) ?? defaultValue;

  @override
  bool setInt(String key, int value) {
    _data[key] = value;
    return true;
  }

  @override
  bool getBool(String key, {bool defaultValue = false}) => (_data[key] as bool?) ?? defaultValue;

  @override
  bool setBool(String key, bool value) {
    _data[key] = value;
    return true;
  }

  @override
  void removeValue(String key) => _data.remove(key);

  @override
  void removeValues(List<String> keys) {
    _data.removeWhere((key, value) => keys.contains(key));
  }

  @override
  List<String> get allKeys => _data.keys.toList();

  @override
  void clearAll() => _data.clear();
}
