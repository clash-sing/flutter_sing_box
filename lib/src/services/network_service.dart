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