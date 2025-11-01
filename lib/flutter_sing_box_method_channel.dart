import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

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

  static const EventChannel _eventChannel =
      EventChannel('flutter_sing_box_event');

  static Stream<dynamic>? _vpnStatusStream;

  @override
  Stream<dynamic> get vpnStatusStream {
    _vpnStatusStream ??= _eventChannel.receiveBroadcastStream();
    return _vpnStatusStream!;
  }
}
