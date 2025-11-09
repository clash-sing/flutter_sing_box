import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'flutter_sing_box.dart';
import 'flutter_sing_box_platform_interface.dart';

/// An implementation of [FlutterSingBoxPlatform] that uses method channels.
class MethodChannelFlutterSingBox extends FlutterSingBoxPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('flutter_sing_box_method');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }

  @override
  Future<void> startVpn() async {
    await methodChannel.invokeMethod('startVpn');
  }

  @override
  Future<void> stopVpn() async {
    await methodChannel.invokeMethod('stopVpn');
  }

  @override
  Future<void> setClashMode(String mode) async {
    await methodChannel.invokeMethod('setClashMode', mode);
  }

  @override
  Future<void> setOutbound({required String groupTag, required String outboundTag}) async {
    await methodChannel.invokeMethod('setOutbound', {"groupTag": groupTag, "outboundTag": outboundTag});
  }

  @override
  Future<void> setGroupExpand({required String groupTag, required bool isExpand}) async {
    await methodChannel.invokeMethod('setGroupExpand', {"groupTag": groupTag, "isExpand": isExpand});
  }

  static const EventChannel _eventChannelConnectedStatus = EventChannel('connected_status_event');
  static Stream<ClientStatus>? _connectedStatusStream;
  @override
  Stream<ClientStatus> get connectedStatusStream {
    _connectedStatusStream ??= _eventChannelConnectedStatus.receiveBroadcastStream()
        .map((data) => ClientStatus.fromJson(jsonDecode(data)));
    return _connectedStatusStream!;
  }

  static const EventChannel _eventChannelGroup = EventChannel('group_event');
  static Stream<List<ClientGroup>>? _groupStream;
  @override
  Stream<List<ClientGroup>> get groupStream {
    _groupStream ??= _eventChannelGroup.receiveBroadcastStream()
        .map((data) => (jsonDecode(data) as List).map((item) => ClientGroup.fromJson(item)).toList());
    return _groupStream!;
  }

  static const EventChannel _eventChannelClashMode = EventChannel('clash_mode_event');
  static Stream<ClientClashMode>? _clashModeStream;

  @override
  Stream<ClientClashMode> get clashModeStream {
    _clashModeStream ??= _eventChannelClashMode.receiveBroadcastStream()
        .map((data) => ClientClashMode.fromJson(jsonDecode(data)));
    return _clashModeStream!;
  }

  static const EventChannel _eventChannelLog = EventChannel('log_event');
  static Stream<List<String>>? _logStream;
  @override
  Stream<List<String>> get logStream {
    _logStream ??= _eventChannelLog.receiveBroadcastStream()
        .map((data) => (jsonDecode(data) as List).map((item) => item.toString()).toList());
    return _logStream!;
  }

  static const EventChannel _eventChannelProxyState = EventChannel('proxy_state_event');
  static Stream<ProxyState>? _proxyStateStream;
  @override
  Stream<ProxyState> get proxyStateStream {
    _proxyStateStream ??= _eventChannelProxyState.receiveBroadcastStream()
    .map((data) {
      if (data == ProxyState.stopped.name) return ProxyState.stopped;
      if (data == ProxyState.starting.name) return ProxyState.starting;
      if (data == ProxyState.started.name) return ProxyState.started;
      if (data == ProxyState.stopping.name) return ProxyState.stopping;
      return ProxyState.unknown;
    });
    return _proxyStateStream!;
  }
}
