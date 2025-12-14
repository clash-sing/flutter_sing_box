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
    return await methodChannel.invokeMethod('selectOutbound', {"groupTag": groupTag, "outboundTag": outboundTag});
  }

  @override
  Future<void> setGroupExpand({required String groupTag, required bool isExpand}) async {
    return await methodChannel.invokeMethod('setGroupExpand', {"groupTag": groupTag, "isExpand": isExpand});
  }

  @override
  Future<void> urlTest({required String groupTag}) async {
    return await methodChannel.invokeMethod('urlTest', groupTag);
  }

  final _eventChannelConnectedStatus = const EventChannel('connected_status_event');
  Stream<ClientStatus>? _connectedStatusStream;
  @override
  Stream<ClientStatus> get connectedStatusStream {
    _connectedStatusStream ??= _eventChannelConnectedStatus.receiveBroadcastStream()
        .map((data) {
      return ClientStatus.fromJson(jsonDecode(data));
    });
    return _connectedStatusStream!;
  }

  final _eventChannelGroup = const EventChannel('group_event');
  Stream<List<ClientGroup>>? _groupStream;
  @override
  Stream<List<ClientGroup>> get groupStream {
    _groupStream ??= _eventChannelGroup.receiveBroadcastStream()
        .map((data) {
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
    _clashModeStream ??= _eventChannelClashMode.receiveBroadcastStream()
        .map((data) => ClientClashMode.fromJson(jsonDecode(data)));
    return _clashModeStream!;
  }

  final _eventChannelLog = const EventChannel('log_event');
  Stream<List<String>>? _logStream;
  @override
  Stream<List<String>> get logStream {
    _logStream ??= _eventChannelLog.receiveBroadcastStream()
        .map((data) => (jsonDecode(data) as List).map((item) => item.toString()).toList());
    return _logStream!;
  }

  final _eventChannelProxyState = const EventChannel('proxy_state_event');
  Stream<ProxyState>? _proxyStateStream;
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
