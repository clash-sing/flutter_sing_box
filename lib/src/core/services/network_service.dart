import 'dart:io' as io;

import 'package:dio/dio.dart';
import 'package:flutter_sing_box/src/core/services/subscribe_user_agent.dart';

import '../../data/network/api_result.dart';
import '../../data/network/dio_client.dart';

/// 订阅内容的网络下载服务。
class NetworkService {
  NetworkService._internal();

  /// 单例实例。
  static final NetworkService instance = NetworkService._internal();

  /// 单例工厂构造器。
  factory NetworkService() => instance;

  /// 下载 [uri] 的订阅内容，结果包装为 [ApiResult]。
  ///
  /// [userAgent] 缺省用 [SubscribeUserAgent.getDefaultUserAgent] 的默认 UA。
  Future<ApiResult<dynamic>> fetchSubscription(Uri uri, {String? userAgent}) async {
    try {
      final response = await DioClient().dio.getUri(
        uri,
        options: Options(
          headers: {
            ...DioClient().dio.options.headers,
            'User-Agent': userAgent ?? await SubscribeUserAgent.getDefaultUserAgent(),
          },
        ),
      );
      if (response.statusCode == io.HttpStatus.ok) {
        final apiResult = ApiResult(response.data, response.headers.map);
        return apiResult;
      } else {
        throw Exception(
          'Failed to load, statusCode: ${response.statusCode}, message: ${response.statusMessage}, for $uri',
        );
      }
    } catch (e) {
      rethrow;
    }
  }

  /*
  Future<String> _getUserAgent() async {
    final deviceInfo = await _getDeviceInfo();
    return '($deviceInfo) mihomo/1.19.15 ClashMeta/1.19.15 sing-box/1.12.12 v2ray';
    // return '$packageInfo ($deviceInfo) sing-box/1.12.12 mihomo/1.19.15 ClashMeta/1.19.15 v2ray';
  }

  Future<String> _getDeviceInfo() async {
    final DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    late final String device;
    if (io.Platform.isAndroid) {
      final androidInfo = await deviceInfo.androidInfo;
      device = 'Android ${androidInfo.version.release}';
    } else if (io.Platform.isIOS) {
      final iosInfo = await deviceInfo.iosInfo;
      device = 'iOS ${iosInfo.utsname.release}';
    } else if (io.Platform.isWindows) {
      final windowsInfo = await deviceInfo.windowsInfo;
      device = 'Windows ${windowsInfo.productName}';
    } else if (io.Platform.isLinux) {
      final linuxInfo = await deviceInfo.linuxInfo;
      device = 'Linux ${linuxInfo.prettyName}';
    } else if (io.Platform.isMacOS) {
      final macosInfo = await deviceInfo.macOsInfo;
      device = 'MacOS ${macosInfo.kernelVersion}';
    } else {
      device = 'Unknown';
    }
    return device;
  }
*/
}
