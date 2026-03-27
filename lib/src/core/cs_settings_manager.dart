import 'dart:convert';

import 'package:mmkv/mmkv.dart';

class CsSettingsManager {
  static final CsSettingsManager _instance = CsSettingsManager._internal();
  factory CsSettingsManager() => _instance;

  CsSettingsManager._internal();

  MMKV? _mmkv;

  MMKV get mmkv {
    _mmkv ??= MMKV("cs_settings", mode: MMKVMode.MULTI_PROCESS_MODE);
    return _mmkv!;
  }

  int getPerAppProxyMode() {
    return mmkv.decodeInt(_Keys.perAppProxyMode, defaultValue: _Keys.perAppProxyDisabled);
  }

  void setPerAppProxyMode(int mode) {
    assert(
      mode == _Keys.perAppProxyDisabled ||
          mode == _Keys.perAppProxyExclude ||
          mode == _Keys.perAppProxyInclude,
      "Invalid per app proxy mode",
    );
    mmkv.encodeInt(_Keys.perAppProxyMode, mode);
  }

  List<String> getAppList(int mode) {
    assert(mode == _Keys.perAppProxyExclude || mode == _Keys.perAppProxyInclude, "Invalid app list mode");
    if (mode == _Keys.perAppProxyExclude) {
      return jsonDecode(mmkv.decodeString(_Keys.excludeAppList) ?? "[]");
    } else if (mode == _Keys.perAppProxyInclude) {
      return jsonDecode(mmkv.decodeString(_Keys.includeAppList) ?? "[]");
    } else {
      return [];
    }
  }

  void setAppList(List<String> appList, int mode) {
    assert(mode == _Keys.perAppProxyExclude || mode == _Keys.perAppProxyInclude, "Invalid app list mode");
    final strAppPackages = jsonEncode(appList);
    if (mode == _Keys.perAppProxyExclude) {
      mmkv.encodeString(_Keys.excludeAppList, strAppPackages);
    } else {
      mmkv.encodeString(_Keys.includeAppList, strAppPackages);
    }
    setPerAppProxyMode(mode);
  }

  void clear() {
    mmkv.clearAll();
  }

}

class _Keys {
  static const String perAppProxyMode = "per_app_proxy_mode";
  static const int perAppProxyDisabled = 0;
  static const int perAppProxyExclude = 1;
  static const int perAppProxyInclude = 2;

  static const String excludeAppList = "per_app_proxy_exclude_list";
  static const String includeAppList = "per_app_proxy_include_list";
}
