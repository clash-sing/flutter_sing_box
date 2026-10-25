import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'flutter_sing_box.dart';
import 'flutter_sing_box_platform_interface.dart';

/// 基于 MethodChannel / EventChannel 的 [FlutterSingBoxPlatform] 实现（Android/iOS）。
class MethodChannelFlutterSingBox extends FlutterSingBoxPlatform {
  /// 注册本实现为平台默认实例（由 dart_plugin_registrant 调用）。
  static void registerWith() {
    FlutterSingBoxPlatform.instance = MethodChannelFlutterSingBox();
  }

  /// 与原生平台通信的 method channel。
  @visibleForTesting
  final methodChannel = const MethodChannel('flutter_sing_box_method');

  /// 初始化插件（转发原生 method channel）。
  @override
  Future<void> init() async {
    return await methodChannel.invokeMethod('init');
  }

  /// 启动 VPN 服务（转发原生）。
  @override
  Future<void> startVpn() async {
    return await methodChannel.invokeMethod('startVpn');
  }

  /// 停止 VPN 服务（转发原生）。
  @override
  Future<void> stopVpn() async {
    return await methodChannel.invokeMethod('stopVpn');
  }

  /// 重载服务配置（转发原生）。
  @override
  Future<void> serviceReload() async {
    return await methodChannel.invokeMethod('serviceReload');
  }

  /// 设置 Clash 模式（转发原生）。
  @override
  Future<void> setClashMode(String mode) async {
    return await methodChannel.invokeMethod('setClashMode', mode);
  }

  /// 在分组中选中出站（转发原生）。
  @override
  Future<void> selectOutbound({required String groupTag, required String outboundTag}) async {
    return await methodChannel.invokeMethod('selectOutbound', {
      "groupTag": groupTag,
      "outboundTag": outboundTag,
    });
  }

  /// 设置分组展开状态（转发原生）。
  @override
  Future<void> setGroupExpand({required String groupTag, required bool isExpand}) async {
    return await methodChannel.invokeMethod('setGroupExpand', {
      "groupTag": groupTag,
      "isExpand": isExpand,
    });
  }

  /// 对分组执行 URL 测速（转发原生）。
  @override
  Future<void> urlTest({required String groupTag}) async {
    return await methodChannel.invokeMethod('urlTest', groupTag);
  }

  /// 获取 sing-box 内核版本号（转发原生）。
  @override
  Future<String> getSingBoxVersion() async {
    return await methodChannel.invokeMethod('getSingBoxVersion');
  }

  /// 非 Windows 平台默认实现：无系统服务概念，返回 [WindowsServiceStatus.unsupported]。
  @override
  Future<WindowsServiceStatus> queryServiceStatus() async {
    // Android / iOS 等非 Windows 桌面平台走此默认实现，无该服务概念。
    return WindowsServiceStatus.unsupported;
  }

  /// 非 Windows 平台默认实现：无系统服务概念，恒返回 `true`。
  @override
  Future<bool> installService({
    required String serviceName,
    required String displayName,
    required String description,
  }) async => true;

  /// 非 Windows 平台默认实现：恒返回 `false`。
  @override
  Future<bool> uninstallService() async => false;

  /// 非 Windows 平台默认实现：恒返回 `false`。
  @override
  Future<bool> startService() async => false;

  /// 非 Windows 平台默认实现：恒返回 `false`。
  @override
  Future<bool> stopService() async => false;

  final _eventChannelConnectedStatus = const EventChannel('connected_status_event');
  Stream<ClientStatus>? _connectedStatusStream;
  /// 客户端连接状态流（EventChannel `connected_status_event`）。
  @override
  Stream<ClientStatus> get connectedStatusStream {
    _connectedStatusStream ??= _eventChannelConnectedStatus.receiveBroadcastStream().map((data) {
      return ClientStatus.fromJson(jsonDecode(data));
    });
    return _connectedStatusStream!;
  }

  final _eventChannelGroup = const EventChannel('group_event');
  Stream<List<ClientGroup>>? _groupStream;
  /// 分组列表流（EventChannel `group_event`）。
  @override
  Stream<List<ClientGroup>> get groupStream {
    _groupStream ??= _eventChannelGroup.receiveBroadcastStream().map((data) {
      final List<dynamic> list = jsonDecode(data);
      final groups = list.map((item) {
        return ClientGroup.fromJson(item);
      }).toList();
      return groups;
    });
    return _groupStream!;
  }

  final _eventChannelClashMode = const EventChannel('clash_mode_event');
  Stream<ClientClashMode>? _clashModeStream;

  /// Clash 模式流（EventChannel `clash_mode_event`）。
  @override
  Stream<ClientClashMode> get clashModeStream {
    _clashModeStream ??= _eventChannelClashMode.receiveBroadcastStream().map(
      (data) => ClientClashMode.fromJson(jsonDecode(data)),
    );
    return _clashModeStream!;
  }

  final _eventChannelLog = const EventChannel('log_event');
  Stream<List<ClientLog>>? _logStream;
  /// 内核日志流（EventChannel `log_event`，按批推送）。
  @override
  Stream<List<ClientLog>> get logStream {
    _logStream ??= _eventChannelLog.receiveBroadcastStream().map(
      (data) => (jsonDecode(data) as List<dynamic>)
          .map((item) => ClientLog.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
    return _logStream!;
  }

  final _eventChannelProxyState = const EventChannel('proxy_state_event');
  Stream<ProxyState>? _proxyStateStream;
  /// 代理状态流（EventChannel `proxy_state_event`）；原生 error 转为带 errMessage 的 [ProxyStopped]。
  @override
  Stream<ProxyState> get proxyStateStream {
    _proxyStateStream ??= _eventChannelProxyState.receiveBroadcastStream().transform(
      StreamTransformer<dynamic, ProxyState>.fromHandlers(
        handleData: (data, sink) {
          debugPrint('proxyStateStream handleData: $data');
          sink.add(ProxyState.fromName(data.toString()));
        },
        handleError: (error, stackTrace, sink) {
          debugPrint('proxyStateStream handleError: $error');
          // Android 原生侧异常停止经 EventSink.error(code: "Stopped", message: 错误信息) 下发，
          // PlatformException.message 即错误原因；其他错误兜底用 toString。
          final message = error is PlatformException ? error.message : null;
          sink.add(ProxyStopped(errMessage: message ?? error.toString()));
        },
      ),
    );
    return _proxyStateStream!;
  }
}
