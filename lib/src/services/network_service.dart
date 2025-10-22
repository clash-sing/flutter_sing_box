import 'dart:io' as io;

import 'package:device_info_plus/device_info_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter_sing_box/flutter_sing_box.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../const/profile_type.dart';
import '../models/database/typed_profile.dart';
import '../models/database/user_info.dart';


class NetworkService {
  NetworkService._internal();
  static final NetworkService instance = NetworkService._internal();
  factory NetworkService() => instance;

  Future<ApiResult<dynamic>> fetchSubscription(Uri uri) async {
    try {
      final dioClient = DioClient.instance;
      dioClient.options.headers.addAll({
        'User-Agent': await getUserAgent(),
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

  /// 解析订阅
  /// @example content-disposition: attachment;filename*=UTF-8''%E7%8B%97%E7%8B%97%E5%8A%A0%E9%80%9F.com
  /// @example profile-title: base64:5LiJ5q+b5py65Zy6
  /// @example profile-update-interval: 24
  /// @example profile-web-page-url: https://panel.dg5.biz
  /// @example subscription-userinfo: upload=8761515695; download=60139076905; total=214748364800; expire=1777514961
  /// @example content-type: text/html; charset=UTF-8
  Future<Profile> _parseSubscription(dynamic data, Headers headers) async {
    try {

      final typed = TypedProfile(type: ProfileType.remote, autoUpdate: false);
      return Profile(name: "hello", typed: typed);
    } catch (e) {
      rethrow;
    }
  }

  UserInfo _parseUserInfo(String data) {
    try {
      final info = UserInfo();
      return info;
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