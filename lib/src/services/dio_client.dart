import 'package:dio/dio.dart';

class DioClient {
  DioClient._internal();
  static final Dio _dio = _initDio();
  static Dio get instance => _dio;
  static Dio _initDio() {
    final dio = Dio(
      BaseOptions(
        // connectTimeout: Duration(seconds: 5),
        // receiveTimeout: Duration(seconds: 3),
        headers: {
          // 'User-Agent': 'SFA/1.12.10 mihomo/1.19.13 ClashMeta clash-verge v2ray',
          'User-Agent': 'mihomo/1.19.13 ClashMeta clash-verge v2ray',
          'Accept': 'application/json, application/yaml;q=0.9, text/plain;q=0.8',
          'Accept-Encoding': 'gzip',
        },
      ),
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