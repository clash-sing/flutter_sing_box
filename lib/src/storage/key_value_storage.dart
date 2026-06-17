/// 键值存储抽象接口，解耦 MMKV 原生依赖以支持单元测试。
abstract class KeyValueStorage {
  /// Reads the string value for [key], or null if absent.
  String? getString(String key);
  /// Stores [value] under [key]; returns true on success.
  bool setString(String key, String value);

  /// Reads the int value for [key], or [defaultValue] if absent.
  int getInt(String key, {int defaultValue = 0});
  /// Stores [value] under [key]; returns true on success.
  bool setInt(String key, int value);

  /// Reads the bool value for [key], or [defaultValue] if absent.
  bool getBool(String key, {bool defaultValue = false});
  /// Stores [value] under [key]; returns true on success.
  bool setBool(String key, bool value);

  /// Removes the value stored under [key].
  void removeValue(String key);

  /// Removes all values stored under [keys].
  void removeValues(List<String> keys);

  /// All keys currently held in storage.
  List<String> get allKeys;

  /// Removes every value from storage.
  void clearAll();
}
