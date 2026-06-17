import 'package:mmkv/mmkv.dart';

import 'key_value_storage.dart';

/// 基于 MMKV 的键值存储实现。
class MmkvStorage implements KeyValueStorage {
  final MMKV _mmkv;

  MmkvStorage(String id, {MMKVMode mode = MMKVMode.MULTI_PROCESS_MODE})
    : _mmkv = MMKV(id, mode: mode);

  @override
  String? getString(String key) => _mmkv.decodeString(key);

  @override
  bool setString(String key, String value) => _mmkv.encodeString(key, value);

  @override
  int getInt(String key, {int defaultValue = 0}) =>
      _mmkv.decodeInt(key, defaultValue: defaultValue);

  @override
  bool setInt(String key, int value) => _mmkv.encodeInt(key, value);

  @override
  bool getBool(String key, {bool defaultValue = false}) =>
      _mmkv.decodeBool(key, defaultValue: defaultValue);

  @override
  bool setBool(String key, bool value) => _mmkv.encodeBool(key, value);

  @override
  void removeValue(String key) => _mmkv.removeValue(key);

  @override
  void removeValues(List<String> keys) {
    _mmkv.removeValues(keys);
  }

  @override
  List<String> get allKeys => _mmkv.allKeys;

  @override
  void clearAll() => _mmkv.clearAll();
}
