import 'dart:async';
import 'dart:convert';
import 'dart:io' as io;

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_sing_box/flutter_sing_box.dart';
import 'package:flutter_sing_box/flutter_sing_box_platform_interface.dart';
import 'package:flutter_sing_box/src/constants/windows_constants.dart';
import 'package:flutter_sing_box/src/windows/clash_http_client.dart';
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
        unawaited(_refreshClashMode());
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
        unawaited(_refreshClashMode());
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
        unawaited(_refreshClashMode());
      } else if (result.data == 'stopped') {
        _platform.emitProxyState(ProxyState.stopped);
      } else {
        _platform.emitProxyState(ProxyState.unknown);
      }
    } catch (e) {
      throw Exception('Error starting helper: $e');
    }
  }

  /// 连接成功后拉取代理模式并回推到 clashModeStream。
  ///
  /// fire-and-forget: 失败仅 debugPrint,不影响 proxyState 流、不阻塞 start/restart。
  /// 9090 在 sing-box 进程刚拉起时未必就绪,故重试 3 次、间隔 800ms。
  Future<void> _refreshClashMode() async {
    const int maxAttempts = 3;
    const Duration interval = Duration(milliseconds: 800);
    for (int i = 0; i < maxAttempts; i++) {
      try {
        final mode = await ClashHttpClient().getClashMode();
        _platform.emitClashMode(mode);
        return;
      } catch (e) {
        debugPrint('helper 拉取 clash mode 失败 (第 ${i + 1}/$maxAttempts 次): $e');
        if (i < maxAttempts - 1) {
          await Future.delayed(interval);
        }
      }
    }
    debugPrint('helper 拉取 clash mode 最终失败,放弃本轮刷新');
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
