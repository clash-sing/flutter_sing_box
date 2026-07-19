import 'dart:convert';
import 'dart:io' as io;

import 'package:dio/dio.dart';
import 'package:flutter_sing_box/flutter_sing_box.dart';
import 'package:flutter_sing_box/src/constants/windows_constants.dart';
import 'package:path/path.dart' as p;

class HelperHttpClient {
  HelperConfig? config;
  static const String successValue = 'success';

  HelperHttpClient._();
  static final HelperHttpClient _instance = HelperHttpClient._();
  factory HelperHttpClient() => _instance;

  late final Dio dio = _initDio();

  Dio _initDio() {
    final Dio dio = Dio(
      BaseOptions(
        baseUrl: 'http://127.0.0.1:',
        connectTimeout: Duration(seconds: 5),
        receiveTimeout: Duration(seconds: 5),
      ),
    );
    dio.interceptors.add(LogInterceptor(responseBody: true));
    return dio;
  }

  // Future<Directory> get executeDir async {
  //   return getApplicationCacheDirectory();
  // }

  Future<void> start() async {
    try {
      config ??= await _getHelperConfig();
      if (config == null) throw Exception('Helper config not found');
      final result = await dio.get('${config?.helperPort}/start');
      if (result.data == successValue) {
        return;
      }
      throw Exception(result.data);
    } catch (e) {
      throw Exception('Error starting helper: $e');
    }
  }

  Future<void> stop() async {
    try {
      config ??= await _getHelperConfig();
      if (config == null) throw Exception('Helper config not found');
      final result = await dio.get('${config?.helperPort}/stop');
      if (result.data == successValue) {
        return;
      }
      throw Exception(result.data);
    } catch (e) {
      throw Exception('Error starting helper: $e');
    }
  }

  Future<void> restart() async {
    try {
      config ??= await _getHelperConfig();
      if (config == null) throw Exception('Helper config not found');
      final result = await dio.get('${config?.helperPort}/restart');
      if (result.data == successValue) {
        return;
      }
      throw Exception(result.data);
    } catch (e) {
      throw Exception('Error starting helper: $e');
    }
  }

  Future<ProxyState> status() async {
    try {
      config ??= await _getHelperConfig();
      if (config == null) throw Exception('Helper config not found');
      final result = await dio.get('${config?.helperPort}/status');
      if (result.data == 'running') {
        return ProxyState.started;
      } else if (result.data == 'stopped') {
        return ProxyState.stopped;
      } else {
        return ProxyState.unknown;
      }
    } catch (e) {
      throw Exception('Error starting helper: $e');
    }
  }

  Future<HelperConfig?> _getHelperConfig() async {
    final io.Directory dir = await ProfileStorage().getStorageDirectory();
    final io.File configFile = io.File(p.join(dir.path, WindowsConstants.helperConfigFileName));
    if (!await configFile.exists()) {
      return null;
    }
    final String configJson = await configFile.readAsString();
    return HelperConfig.fromJson(json.decode(configJson));
  }
}
