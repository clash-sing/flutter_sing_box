import 'dart:convert';
import 'dart:io' as io;

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_sing_box/flutter_sing_box.dart';
import 'package:flutter_sing_box/flutter_sing_box_platform_interface.dart';
import 'package:flutter_sing_box/src/constants/windows_constants.dart';
import 'package:path/path.dart' as p;

class HelperHttpClient {
  static const String successValue = 'success';
  FlutterSingBoxWindows get _platform => FlutterSingBoxPlatform.instance as FlutterSingBoxWindows;

  /// 配置读取器：每次请求前现读 helper.json 取最新端口。
  ///
  /// helper API 监听随机端口，服务每次重启（含崩溃自愈）都会换端口并回写
  /// helper.json——任何跨调用的端口缓存都会在服务重启后拿到作废端口，
  /// 导致所有请求 connection refused 直到重启 App（issue #19 验收发现）。
  final Future<HelperConfig?> Function() _loadConfig;

  HelperHttpClient._(this._loadConfig);

  static final HelperHttpClient _instance = HelperHttpClient._(_readHelperConfig);

  factory HelperHttpClient() => _instance;

  /// 仅供测试：注入配置读取器构造独立实例（如返回固定端口/动态换端口）。
  @visibleForTesting
  HelperHttpClient.forTest(Future<HelperConfig?> Function() loadConfig)
      : this._(loadConfig);

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

  /// 发 GET 到 helper API，返回解码后的响应数据。
  ///
  /// 端口每次现取；连接被拒/超时（撞上服务 1 秒自动重启窗口、旧端口已死）时
  /// 重读配置换新端口再试一次，仍失败才抛出。
  Future<dynamic> _get(String path) async {
    var config = await _loadConfig();
    if (config == null) throw Exception('Helper config not found');
    try {
      final result = await dio.get('${config.helperPort}$path');
      return result.data;
    } on DioException catch (e) {
      if (e.type != DioExceptionType.connectionError &&
          e.type != DioExceptionType.connectionTimeout) {
        rethrow;
      }
      config = await _loadConfig();
      if (config == null) throw Exception('Helper config not found');
      final result = await dio.get('${config.helperPort}$path');
      return result.data;
    }
  }

  Future<void> start() async {
    try {
      _platform.emitProxyState(ProxyState.starting);
      final data = await _get('/start');
      if (data == successValue) {
        _platform.emitProxyState(ProxyState.started);
        return;
      }
      throw Exception(data);
    } catch (e) {
      // 错误唯一出口是状态流：emit 带 errMessage 的 stopped 归位状态机，不再上抛异常
      _platform.emitProxyState(ProxyStopped(errMessage: e.toString()));
    }
  }

  Future<void> stop() async {
    try {
      _platform.emitProxyState(ProxyState.stopping);
      final data = await _get('/stop');
      if (data == successValue) {
        _platform.emitProxyState(ProxyState.stopped);
        return;
      }
      throw Exception(data);
    } catch (e) {
      // 与 start/restart 一致：错误唯一出口是状态流
      _platform.emitProxyState(ProxyStopped(errMessage: e.toString()));
    }
  }

  Future<void> restart() async {
    try {
      _platform.emitProxyState(ProxyState.starting);
      final data = await _get('/restart');
      if (data == successValue) {
        _platform.emitProxyState(ProxyState.started);
        return;
      }
      throw Exception(data);
    } catch (e) {
      // 错误唯一出口是状态流：emit 带 errMessage 的 stopped 归位状态机，不再上抛异常
      _platform.emitProxyState(ProxyStopped(errMessage: e.toString()));
    }
  }

  /// 查询 helper /status 的原始结果（'running' / 'stopped'）；连接失败抛异常。
  ///
  /// 供连接期间的存活轮询用（FlutterSingBoxWindows._watchHelperAlive），
  /// 与 [status] 不同，本方法不 emit 任何状态。
  Future<String> probeStatus() async {
    final data = await _get('/status');
    return data as String;
  }

  Future<void> status() async {
    try {
      final data = await _get('/status');
      if (data == 'running') {
        _platform.emitProxyState(ProxyState.started);
      } else {
        _platform.emitProxyState(ProxyState.stopped);
      }
    } catch (e) {
      throw Exception('Error starting helper: $e');
    }
  }

  /// 默认配置读取器：从 App 存储目录读 helper.json。
  static Future<HelperConfig?> _readHelperConfig() async {
    final io.Directory dir = await ProfileStorage().getStorageDirectory();
    final io.File configFile = io.File(p.join(dir.path, WindowsConstants.helperConfigFileName));
    if (!await configFile.exists()) {
      return null;
    }
    final String configJson = await configFile.readAsString();
    return HelperConfig.fromJson(json.decode(configJson));
  }
}
