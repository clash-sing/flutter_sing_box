import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_sing_box/src/data/models/clash/clash_configs.dart';

/// ws://127.0.0.1:9090/connections?token=
/// ws://127.0.0.1:9090/memory?token=
/// ws://127.0.0.1:9090/traffic?token=

class ClashHttpClient {
  ClashHttpClient._();
  static final ClashHttpClient _instance = ClashHttpClient._();
  factory ClashHttpClient() => _instance;

  late final Dio dio = _initDio();

  static const String _baseUrl = 'http://127.0.0.1:9090';
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
}
