import 'package:flutter_sing_box/flutter_sing_box.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'flutter_sing_box_method_channel.dart';

abstract class FlutterSingBoxPlatform extends PlatformInterface {
  /// Constructs a FlutterSingBoxPlatform.
  FlutterSingBoxPlatform() : super(token: _token);

  static final Object _token = Object();

  static FlutterSingBoxPlatform _instance = MethodChannelFlutterSingBox();

  /// The default instance of [FlutterSingBoxPlatform] to use.
  ///
  /// Defaults to [MethodChannelFlutterSingBox].
  static FlutterSingBoxPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [FlutterSingBoxPlatform] when
  /// they register themselves.
  static set instance(FlutterSingBoxPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }

  /// Starts the VPN service
  Future<void> startVpn() {
    throw UnimplementedError('startVpn() has not been implemented.');
  }

  /// Stops the VPN service
  Future<void> stopVpn() {
    throw UnimplementedError('stopVpn() has not been implemented.');
  }

  Stream<StatusClient> get connectedStatusStream {
    throw UnimplementedError('connectedStatusStream has not been implemented.');
  }

  Stream<dynamic> get groupStream {
    throw UnimplementedError('groupStream has not been implemented.');
  }

  Stream<dynamic> get clashModeStream {
    throw UnimplementedError('clashModeStream has not been implemented.');
  }
}
