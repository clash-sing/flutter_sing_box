import 'dart:io' as io;

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter_sing_box/flutter_sing_box.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../utils/dio_client.dart';

class NetworkService {
  NetworkService._internal();
  static final NetworkService instance = NetworkService._internal();
  factory NetworkService() => instance;

  Future<ApiResult<dynamic>> fetchSubscription(Uri uri) async {
    try {
      final dioClient = DioClient.instance;
      dioClient.options.headers.addAll({
        // 'User-Agent': await getUserAgent(),
      });
      final response = await dioClient.getUri(uri);
      if (response.statusCode == io.HttpStatus.ok) {
        final apiResult = ApiResult(response.data, response.headers.map);
        return apiResult;
      } else {
        throw Exception('Failed to load, statusCode: ${response.statusCode}, message: ${response.statusMessage}, for $uri');
      }
    } catch (e) {
      rethrow;
    }
  }

  static Future<String> getUserAgent() async {
    final packageInfo = await _getPackageInfo();
    final deviceInfo = await _getDeviceInfo();
    return '$packageInfo ($deviceInfo) sing-box/1.12.10 ClashMeta/1.19.15';
  }

  static Future<String> _getPackageInfo() async {
    final info = await PackageInfo.fromPlatform();
    return 'ClashSing/${info.version}';
  }

  static Future<String> _getDeviceInfo() async {
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
      device =  'MacOS ${macosInfo.kernelVersion}';
    } else {
      device = 'Unknown';
    }
    return device;
  }

}

final networkService = NetworkService();