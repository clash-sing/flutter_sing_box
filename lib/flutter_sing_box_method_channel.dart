import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'flutter_sing_box.dart';
import 'flutter_sing_box_platform_interface.dart';

/// An implementation of [FlutterSingBoxPlatform] that uses method channels.
class MethodChannelFlutterSingBox extends FlutterSingBoxPlatform {
  static void registerWith() {
    FlutterSingBoxPlatform.instance = MethodChannelFlutterSingBox();
  }

  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('flutter_sing_box_method');

  @override
  Future<void> init() async {
    return await methodChannel.invokeMethod('init');
  }

  @override
  Future<void> startVpn() async {
    return await methodChannel.invokeMethod('startVpn');
  }

  @override
  Future<void> stopVpn() async {
    return await methodChannel.invokeMethod('stopVpn');
  }

  @override
  Future<void> serviceReload() async {
    return await methodChannel.invokeMethod('serviceReload');
  }

  @override
  Future<void> setClashMode(String mode) async {
    return await methodChannel.invokeMethod('setClashMode', mode);
  }

  @override
  Future<void> selectOutbound({required String groupTag, required String outboundTag}) async {
    return await methodChannel.invokeMethod('selectOutbound', {
      "groupTag": groupTag,
      "outboundTag": outboundTag,
    });
  }

  @override
  Future<void> setGroupExpand({required String groupTag, required bool isExpand}) async {
    return await methodChannel.invokeMethod('setGroupExpand', {
      "groupTag": groupTag,
      "isExpand": isExpand,
    });
  }

  @override
  Future<void> urlTest({required String groupTag}) async {
    return await methodChannel.invokeMethod('urlTest', groupTag);
  }

  @override
  Future<String> getSingBoxVersion() async {
    return await methodChannel.invokeMethod('getSingBoxVersion');
  }

  @override
  Future<WindowsServiceStatus> queryServiceStatus() async {
    // Android / iOS 等非 Windows 桌面平台走此默认实现，无该服务概念。
    return WindowsServiceStatus.unsupported;
  }

  @override
  Future<bool> installService({
    required String serviceName,
    required String displayName,
    required String description,
  }) async => true;

  @override
  Future<bool> uninstallService() async => false;

  @override
  Future<bool> startService() async => false;

  @override
  Future<bool> stopService() async => false;

  final _eventChannelConnectedStatus = const EventChannel('connected_status_event');
  Stream<ClientStatus>? _connectedStatusStream;
  @override
  Stream<ClientStatus> get connectedStatusStream {
    _connectedStatusStream ??= _eventChannelConnectedStatus.receiveBroadcastStream().map((data) {
      return ClientStatus.fromJson(jsonDecode(data));
    });
    return _connectedStatusStream!;
  }

  final _eventChannelGroup = const EventChannel('group_event');
  Stream<List<ClientGroup>>? _groupStream;
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

  @override
  Stream<ClientClashMode> get clashModeStream {
    _clashModeStream ??= _eventChannelClashMode.receiveBroadcastStream().map(
      (data) => ClientClashMode.fromJson(jsonDecode(data)),
    );
    return _clashModeStream!;
  }

  final _eventChannelLog = const EventChannel('log_event');
  Stream<List<ClientLog>>? _logStream;
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
