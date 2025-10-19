import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_sing_box/flutter_sing_box.dart';


class NetworkService {
  NetworkService._internal();
  static final NetworkService instance = NetworkService._internal();
  factory NetworkService() => instance;

  Future<Profile> fetchSubscription(Uri uri) async {
    try {
      final response = await DioClient.instance.getUri(uri);
      if (response.statusCode == HttpStatus.ok) {
        return _parseSubscription(response.data, response.headers);
      } else {
        throw Exception('Failed to load, statusCode: ${response.statusCode}, message: ${response.statusMessage}, for $uri');
      }
    } catch (e) {
      rethrow;
    }
  }

  /// 解析订阅
  /// @example content-disposition: attachment;filename*=UTF-8''%E7%8B%97%E7%8B%97%E5%8A%A0%E9%80%9F.com
  /// @example profile-update-interval: 24
  /// @example profile-web-page-url: https://panel.dg5.biz
  /// @example subscription-userinfo: upload=8761515695; download=60139076905; total=214748364800; expire=1777514961
  /// @example content-type: text/html; charset=UTF-8
  Future<Profile> _parseSubscription(String data, Headers headers) async {
    try {

      final typed = TypedProfile(type: ProfileType.remote, autoUpdate: false);
      return Profile(name: "hello", typed: typed);
    } catch (e) {
      rethrow;
    }
  }

}

final networkService = NetworkService();