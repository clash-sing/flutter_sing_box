/// 键值存储抽象接口，解耦 MMKV 原生依赖以支持单元测试。
abstract class KeyValueStorage {
  /// 读取 [key] 的字符串值；不存在时返回 `null`。
  String? getString(String key);

  /// 将 [value] 存入 [key]；成功返回 `true`。
  bool setString(String key, String? value);

  /// 读取 [key] 的 int 值；不存在时返回 [defaultValue]。
  int getInt(String key, {int defaultValue = 0});

  /// 将 [value] 存入 [key]；成功返回 `true`。
  bool setInt(String key, int? value);

  /// 读取 [key] 的 bool 值；不存在时返回 [defaultValue]。
  bool getBool(String key, {bool defaultValue = false});

  /// 将 [value] 存入 [key]；成功返回 `true`。
  bool setBool(String key, bool? value);

  /// 读取 [key] 的 double 值；不存在时返回 [defaultValue]。
  double getDouble(String key, {double defaultValue = 0.0});
  /// 将 [value] 存入 [key]；成功返回 `true`。
  bool setDouble(String key, double? value);

  /// 删除 [key] 对应的值。
  void removeValue(String key);

  /// 批量删除 [keys] 对应的值。
  void removeValues(List<String> keys);

  /// 当前存储中的全部键。
  List<String> get allKeys;

  /// 清空存储中的全部键值。
  void clearAll();
}
