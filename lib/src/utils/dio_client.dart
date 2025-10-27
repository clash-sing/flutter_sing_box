import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dio/io.dart';
/// User-Agent 格式说明：APP名称/APP版本 (编译版本好; 平台 系统版本; 内核名称/内核版本)

class DioClient {
  DioClient._internal();
  static final Dio _dio = _initDio();
  static Dio get dio => _dio;
  static Dio _initDio() {
    final dio = Dio(
      BaseOptions(
        // connectTimeout: Duration(seconds: 5),
        // receiveTimeout: Duration(seconds: 3),
        headers: {
          // 'User-Agent': 'SFA/1.12.10 mihomo/1.19.13 ClashMeta clash-verge v2ray',
          // 'User-Agent': 'mihomo/1.19.13 ClashMeta clash-verge v2ray',
          // 'User-Agent': 'ClashSing/1.0 (1; sing-box 1.12.10; mihomo 1.19.13; ClashMeta; clash-verge; v2ray; language zh_Hans_CN)',
          // 'User-Agent': 'ClashSing/1.2 (Android 13) sing-box/1.12.10 ClashMeta/1.19.15',
          'User-Agent': 'SFI/1.2 (sing-box 1.12.10) sing-box/1.12.10 ClashMeta/1.19.15',
          'Accept': 'application/json, application/yaml;q=0.9, text/plain;q=0.8',
          'Accept-Encoding': 'gzip',
        },
      ),
    );

    // 添加 HttpClientAdapter 并配置安全上下文
    dio.httpClientAdapter = IOHttpClientAdapter(
      createHttpClient: () {
        final client = HttpClient();
        // 允许自签名证书（仅用于测试环境）
        client.badCertificateCallback = (X509Certificate cert, String host, int port) => true;
        return client;
      },
    );

    // 在 Debug 模式下添加日志拦截器
    assert(() {
      dio.interceptors.add(
        LogInterceptor(
          requestBody: true,
          responseBody: true,
        ),
      );
      return true;
    }());

    return dio;
  }
}