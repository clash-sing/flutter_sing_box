import 'dart:convert';
import 'dart:io' as io;

import 'package:dio/dio.dart';
import 'package:flutter_sing_box/flutter_sing_box.dart';
import 'package:flutter_sing_box/flutter_sing_box_platform_interface.dart';
import 'package:flutter_sing_box/src/constants/windows_constants.dart';
import 'package:path/path.dart' as p;

class HelperHttpClient {
  HelperConfig? config;
  static const String successValue = 'success';
  FlutterSingBoxWindows get _platform => FlutterSingBoxPlatform.instance as FlutterSingBoxWindows;

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
      _platform.emitProxyState(ProxyState.starting);
      config ??= await _getHelperConfig();
      if (config == null) throw Exception('Helper config not found');
      final result = await dio.get('${config?.helperPort}/start');
      if (result.data == successValue) {
        _platform.emitProxyState(ProxyState.started);
        return;
      }
      throw Exception(result.data);
    } catch (e) {
      throw Exception('Error starting helper: $e');
    }
  }

  Future<void> stop() async {
    try {
      _platform.emitProxyState(ProxyState.stopping);
      config ??= await _getHelperConfig();
      if (config == null) throw Exception('Helper config not found');
      final result = await dio.get('${config?.helperPort}/stop');
      if (result.data == successValue) {
        _platform.emitProxyState(ProxyState.stopped);
        return;
      }
      throw Exception(result.data);
    } catch (e) {
      throw Exception('Error starting helper: $e');
    }
  }

  Future<void> restart() async {
    try {
      _platform.emitProxyState(ProxyState.starting);
      config ??= await _getHelperConfig();
      if (config == null) throw Exception('Helper config not found');
      final result = await dio.get('${config?.helperPort}/restart');
      if (result.data == successValue) {
        _platform.emitProxyState(ProxyState.started);
        return;
      }
      throw Exception(result.data);
    } catch (e) {
      throw Exception('Error starting helper: $e');
    }
  }

  Future<void> status() async {
    try {
      config ??= await _getHelperConfig();
      if (config == null) throw Exception('Helper config not found');
      final result = await dio.get('${config?.helperPort}/status');
      if (result.data == 'running') {
        _platform.emitProxyState(ProxyState.started);
      } else if (result.data == 'stopped') {
        _platform.emitProxyState(ProxyState.stopped);
      } else {
        _platform.emitProxyState(ProxyState.unknown);
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
