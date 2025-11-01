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

  static const EventChannel _eventChannelConnectedStatus = EventChannel('connected_status_event');
  static Stream<ClientStatus>? _connectedStatusStream;
  @override
  Stream<ClientStatus> get connectedStatusStream {
    _connectedStatusStream ??= _eventChannelConnectedStatus.receiveBroadcastStream()
        .map((data) => ClientStatus.fromJson(jsonDecode(data)));
    return _connectedStatusStream!;
  }

  static const EventChannel _eventChannelGroup = EventChannel('group_event');
  static Stream<dynamic>? _groupStream;
  @override
  Stream<dynamic> get groupStream {
    _groupStream ??= _eventChannelGroup.receiveBroadcastStream();
    return _groupStream!;
  }

  static const EventChannel _eventChannelClashMode = EventChannel('clash_mode_event');
  static Stream<dynamic>? _clashModeStream;
  @override
  Stream<dynamic> get clashModeStream {
    _clashModeStream ??= _eventChannelClashMode.receiveBroadcastStream();
    return _clashModeStream!;
  }
}
