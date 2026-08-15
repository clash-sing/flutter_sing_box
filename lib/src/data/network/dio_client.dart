import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:flutter/foundation.dart';

/// User-Agent 格式说明：APP名称/APP版本 (编译版本好; 平台 系统版本; 内核名称/内核版本)

class DioClient {
  DioClient._internal();
  static final DioClient _instance = DioClient._internal();
  /// Creates the singleton [DioClient] instance.
  factory DioClient() => _instance;

  late final Dio _dio = _initDio();
  /// The configured [Dio] instance.
  Dio get dio => _dio;

  /// 是否放行证书校验失败的 HTTPS 连接。
  ///
  /// 由宿主 App 的「允许不安全连接」设置驱动（默认 false，严格校验）。
  /// [HttpClient.badCertificateCallback] 在每次握手失败时都会重新读取本字段，
  /// 运行期修改即时生效，无需重建客户端。
  bool allowBadCertificates = false;

  Dio _initDio() {
    final myDio = Dio(
      BaseOptions(
        // connectTimeout: Duration(seconds: 5),
        // receiveTimeout: Duration(seconds: 3),
        headers: {
          // 'User-Agent': 'SFA/1.12.10 mihomo/1.19.13 ClashMeta clash-verge v2ray',
          // 'User-Agent': 'mihomo/1.19.13 ClashMeta clash-verge v2ray',
          // 'User-Agent': 'ClashSing/1.0 (1; sing-box 1.12.10; mihomo 1.19.13; ClashMeta; clash-verge; v2ray; language zh_Hans_CN)',
          // 'User-Agent': 'ClashSing/1.2 (Android 13) sing-box/1.12.10 ClashMeta/1.19.15',
          // 'User-Agent': 'sing-box 1.12.24;mihomo/1.19.16;ClashMeta;clash-verge;v2ray',
          'Accept': 'application/json, application/yaml;q=0.9, text/plain;q=0.8',
          'Accept-Encoding': 'gzip',
        },
      ),
    );

    // 添加 HttpClientAdapter 并配置安全上下文
    myDio.httpClientAdapter = IOHttpClientAdapter(
      createHttpClient: () {
        final client = HttpClient();
        // 证书校验失败时询问此回调：debug 构建一律放行（便于抓包调试），
        // release 构建遵循 [allowBadCertificates] 开关（默认拒绝）。
        // Windows 桌面端的典型触发场景：订阅站点证书链不完整（未下发
        // 中间证书），且本机没有中间证书缓存（如全新系统），导致
        // CERTIFICATE_VERIFY_FAILED。详见 Dart VM 的证书静态枚举机制。
        client.badCertificateCallback = (X509Certificate cert, String host, int port) =>
            kDebugMode || allowBadCertificates;
        return client;
      },
    );

    // 在 Debug 模式下添加日志拦截器
    assert(() {
      myDio.interceptors.add(
        LogInterceptor(
          requestBody: true,
          // responseBody: true,
        ),
      );
      return true;
    }());

    return myDio;
  }
}
