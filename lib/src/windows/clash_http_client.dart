import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_sing_box/src/data/models/clash/clash_configs.dart';
import 'package:flutter_sing_box/src/data/models/client/client_clash_mode.dart';

/// ws://127.0.0.1:9090/connections?token=
/// ws://127.0.0.1:9090/memory?token=
/// ws://127.0.0.1:9090/traffic?token=

class ClashHttpClient {
  ClashHttpClient._();
  static final ClashHttpClient _instance = ClashHttpClient._();
  factory ClashHttpClient() => _instance;

  late final Dio dio = _initDio();

  static const String _baseUrl = 'http://127.0.0.1:9090';
  // ignore: unused_field
  static const String _wsBaseUrl = 'ws://127.0.0.1:9090';

  Dio _initDio() {
    final options = BaseOptions(
      baseUrl: _baseUrl,
      connectTimeout: Duration(seconds: 5),
      receiveTimeout: Duration(seconds: 5),
      headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
    );
    final Dio dio = Dio(options);
    dio.interceptors.add(LogInterceptor());
    return dio;
  }

  Future<ClashConfigs> getConfigs() async {
    final response = await dio.get('/configs');
    final Map<String, dynamic> map = response.data is Map
        ? response.data
        : jsonDecode(response.data);
    final configs = ClashConfigs.fromJson(map);
    return configs;
  }

  /// 将 [ClashConfigs] 映射为 UI 层使用的 [ClientClashMode]（纯函数,可单测）。
  static ClientClashMode modeFromConfigs(ClashConfigs configs) {
    return ClientClashMode(
      modes: configs.modeList,
      currentMode: configs.mode,
    );
  }

  /// 拉取 /configs 并映射为代理模式,供连接成功后刷新 clashModeStream。
  Future<ClientClashMode> getClashMode() async {
    final configs = await getConfigs();
    return modeFromConfigs(configs);
  }
}
