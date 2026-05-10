/// 键值存储抽象接口，解耦 MMKV 原生依赖以支持单元测试。
abstract class KeyValueStorage {
  String? getString(String key);
  bool setString(String key, String value);

  int getInt(String key, {int defaultValue = 0});
  bool setInt(String key, int value);

  bool getBool(String key, {bool defaultValue = false});
  bool setBool(String key, bool value);

  void removeValue(String key);

  void removeValues(List<String> keys);

  List<String> get allKeys;

  void clearAll();
}
