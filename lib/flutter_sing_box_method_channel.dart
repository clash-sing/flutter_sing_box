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
  // 1. 我们自己的、对外暴露的广播 Controller
  static StreamController<ClientClashMode>? _clashModeController;
  // 2. 用于缓存最后一次收到的值
  static ClientClashMode? _lastClashMode;
  // 3. 对原生 EventChannel 的订阅，需要持有它以便管理
  static StreamSubscription? _clashModeSubscription;

  @override
  Stream<ClientClashMode> get clashModeStream {
    // 4. 首次调用时，进行一次性初始化
    if (_clashModeController == null) {
      // 创建一个广播 StreamController
      _clashModeController = StreamController<ClientClashMode>.broadcast(
        // 5. 当有新的监听者订阅我们的 Stream 时，onListen 会被调用
        onListen: () {
          // 如果我们已经缓存了一个值，立即把它发给这个新的监听者
          if (_lastClashMode != null) {
            _clashModeController!.add(_lastClashMode!);
          }
        },
      );

      // 6. 监听原生的 EventChannel Stream
      _clashModeSubscription = _eventChannelClashMode
          .receiveBroadcastStream()
          .map((data) => ClientClashMode.fromJson(jsonDecode(data)))
          .listen((newMode) {
        // 7. 当收到原生端的新数据时...
        // a. 更新我们的缓存
        _lastClashMode = newMode;
        // b. 把新数据添加到我们自己的 Controller 中，以通知所有当前的监听者
        _clashModeController!.add(newMode);
      });
    }

    // 8. 始终返回我们自己 Controller 的 Stream
    return _clashModeController!.stream;
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
