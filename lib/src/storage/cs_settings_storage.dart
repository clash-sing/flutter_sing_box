import 'dart:convert';

import 'package:flutter_sing_box/flutter_sing_box.dart';

/// App 设置存取（MMKV 持久化，`cs_settings` 实例）。
///
/// 键名集中在 `_Keys`；读写走 [storage] 抽象，测试可换 [MemoryStorage]。
class CsSettingsStorage {
  CsSettingsStorage._internal();
  static final CsSettingsStorage _instance = CsSettingsStorage._internal();
  /// 单例实例。
  static CsSettingsStorage get instance => _instance;
  /// 单例工厂构造器。
  factory CsSettingsStorage() => _instance;

  /// 仅用于单元测试, 用 [MemoryStorage] 代替默认的 [MmkvStorage]
  static void mockInit() => _storage = MemoryStorage();

  static KeyValueStorage? _storage;
  /// 底层键值存储；缺省惰性初始化为 MMKV。
  static KeyValueStorage get storage => _storage ??= MmkvStorage('cs_settings');

  /// 读取分应用代理模式（0 关闭 / 1 白名单 / 2 黑名单）。
  int getPerAppProxyMode() {
    return storage.getInt(_Keys.perAppProxyMode, defaultValue: _Keys.perAppProxyDisabled);
  }

  /// 写入分应用代理模式；非法值触发断言。
  void setPerAppProxyMode(int mode) {
    assert(
      mode == _Keys.perAppProxyDisabled ||
          mode == _Keys.perAppProxyExclude ||
          mode == _Keys.perAppProxyInclude,
      "Invalid per app proxy mode",
    );
    storage.setInt(_Keys.perAppProxyMode, mode);
  }

  /// 读取 [mode] 对应的应用包名列表；关闭模式返回空表。
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

  /// 保存应用包名列表并同步更新代理模式。
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

  /// Clash API 监听端口，缺省 [FlutterSingBoxConstants.defaultClashApiPort]。
  int getClashApiPort() {
    return storage.getInt(
      _Keys.clashApiPort,
      defaultValue: FlutterSingBoxConstants.defaultClashApiPort,
    );
  }

  /// 写入 Clash API 监听端口。
  void setClashApiPort(int? port) {
    storage.setInt(_Keys.clashApiPort, port);
  }

  /// 测速 URL，缺省 [FlutterSingBoxConstants.defaultTestUrl]。
  String getTestUrl() {
    return storage.getString(_Keys.testUrl) ?? FlutterSingBoxConstants.defaultTestUrl;
  }

  /// 写入测速 URL。
  void setTestUrl(String? url) {
    storage.setString(_Keys.testUrl, url);
  }

  /// Windows 桌面端代理模式（tun / systemProxy），默认 tun。
  ProxyMode get proxyMode {
    final name = storage.getString(_Keys.proxyMode);
    return ProxyMode.values.firstWhere(
      (m) => m.name == name,
      orElse: () => ProxyMode.tun,
    );
  }

  set proxyMode(ProxyMode mode) {
    storage.setString(_Keys.proxyMode, mode.name);
  }

  /// mixed 入站监听端口，默认 8890。
  int get mixedPort {
    return storage.getInt(_Keys.mixedPort, defaultValue: FlutterSingBoxConstants.defaultMixedPort);
  }

  set mixedPort(int? port) {
    storage.setInt(_Keys.mixedPort, port);
  }

  /// 系统代理是否处于已设状态（崩溃自愈用标志）。
  bool get systemProxyActive {
    return storage.getBool(_Keys.systemProxyActive, defaultValue: false);
  }

  set systemProxyActive(bool value) {
    storage.setBool(_Keys.systemProxyActive, value);
  }

  /// 清空全部设置。
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
  static const String clashApiPort = "clash_api_port";
  static const String testUrl = "test_url";

  static const String proxyMode = "proxy_mode";
  static const String mixedPort = "mixed_port";
  static const String systemProxyActive = "system_proxy_active";
}
