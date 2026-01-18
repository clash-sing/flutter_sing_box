import 'package:flutter_sing_box/flutter_sing_box.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'flutter_sing_box_method_channel.dart';

/// The interface that implementations of flutter_sing_box must implement.
///
/// Platform implementations should extend this class rather than implementing it as an `interface`.
/// Methods in this class that are not overridden by platform implementations will throw
/// an [UnimplementedError] by default.
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

  /// Initializes the platform interface.
  Future<void> init() async {
    throw UnimplementedError('init() has not been implemented.');
  }

  /// Starts the VPN service.
  Future<void> startVpn() async {
    throw UnimplementedError('startVpn() has not been implemented.');
  }

  /// Stops the VPN service.
  Future<void> stopVpn() async {
    throw UnimplementedError('stopVpn() has not been implemented.');
  }

  /// Reloads the service configuration.
  Future<void> serviceReload() async {
    throw UnimplementedError('serviceReload() has not been implemented.');
  }

  /// Sets the Clash mode.
  Future<void> setClashMode(String mode) async {
    throw UnimplementedError('setClashMode() has not been implemented.');
  }

  /// Selects an outbound for a specific group.
  Future<void> selectOutbound({required String groupTag, required String outboundTag}) async {
    throw UnimplementedError('selectOutbound() has not been implemented.');
  }

  /// Sets the expansion state of a group.
  Future<void> setGroupExpand({required String groupTag, required bool isExpand}) async {
    throw UnimplementedError('setGroupExpand() has not been implemented.');
  }

  /// Performs a URL test for a specific group.
  Future<void> urlTest({required String groupTag}) async {
    throw UnimplementedError('urlTest() has not been implemented.');
  }

  /// Gets the version of the underlying sing-box core.
  Future<String> getSingBoxVersion() async {
    throw UnimplementedError('getSingBoxVersion() has not been implemented.');
  }

  /// A stream of client connection status updates.
  Stream<ClientStatus> get connectedStatusStream {
    throw UnimplementedError('connectedStatusStream has not been implemented.');
  }

  /// A stream of client group updates.
  Stream<List<ClientGroup>> get groupStream {
    throw UnimplementedError('groupStream has not been implemented.');
  }

  /// A stream of client Clash mode updates.
  Stream<ClientClashMode> get clashModeStream {
    throw UnimplementedError('clashModeStream has not been implemented.');
  }

  /// A stream of log messages from the sing-box core.
  Stream<List<String>> get logStream {
    throw UnimplementedError('logStream has not been implemented.');
  }

  /// A stream of proxy state updates.
  Stream<ProxyState> get proxyStateStream {
    throw UnimplementedError('proxyStateStream has not been implemented.');
  }
}
