import 'dart:convert';

import 'package:flutter_sing_box/flutter_sing_box.dart';

class CsSettingsStorage {
  CsSettingsStorage._internal();
  static final CsSettingsStorage _instance = CsSettingsStorage._internal();
  static CsSettingsStorage get instance => _instance;
  factory CsSettingsStorage() => _instance;

  /// 仅用于单元测试, 用 [MemoryStorage] 代替默认的 [MmkvStorage]
  static void mockInit() => _storage = MemoryStorage();

  static KeyValueStorage? _storage;
  static KeyValueStorage get storage => _storage ??= MmkvStorage('cs_settings');

  int getPerAppProxyMode() {
    return storage.getInt(_Keys.perAppProxyMode, defaultValue: _Keys.perAppProxyDisabled);
  }

  void setPerAppProxyMode(int mode) {
    assert(
      mode == _Keys.perAppProxyDisabled ||
          mode == _Keys.perAppProxyExclude ||
          mode == _Keys.perAppProxyInclude,
      "Invalid per app proxy mode",
    );
    storage.setInt(_Keys.perAppProxyMode, mode);
  }

  List<String> getAppList(int mode) {
    assert(
      mode == _Keys.perAppProxyDisabled ||
          mode == _Keys.perAppProxyExclude ||
          mode == _Keys.perAppProxyInclude,
      "Invalid app list mode",
    );
    if (mode == _Keys.perAppProxyExclude) {
      return List<String>.from(jsonDecode(storage.getString(_Keys.excludeAppList) ?? "[]"));
    } else if (mode == _Keys.perAppProxyInclude) {
      return List<String>.from(jsonDecode(storage.getString(_Keys.includeAppList) ?? "[]"));
    } else {
      return List.empty();
    }
  }

  void setAppList(List<String> appList, int mode) {
    assert(
      mode == _Keys.perAppProxyDisabled ||
          mode == _Keys.perAppProxyExclude ||
          mode == _Keys.perAppProxyInclude,
      "Invalid app list mode",
    );
    final strAppPackages = jsonEncode(appList);
    if (mode == _Keys.perAppProxyExclude) {
      storage.setString(_Keys.excludeAppList, strAppPackages);
    } else if (mode == _Keys.perAppProxyInclude) {
      storage.setString(_Keys.includeAppList, strAppPackages);
    }
    setPerAppProxyMode(mode);
  }

  void clear() {
    storage.clearAll();
  }
}

class _Keys {
  static const String perAppProxyMode = "per_app_proxy_mode";
  static const int perAppProxyDisabled = 0;
  static const int perAppProxyInclude = 1;
  static const int perAppProxyExclude = 2;

  static const String includeAppList = "per_app_proxy_include_list";
  static const String excludeAppList = "per_app_proxy_exclude_list";
}
