import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'flutter_sing_box_platform_interface.dart';
import 'package:package_info_plus/package_info_plus.dart';

/// An implementation of [FlutterSingBoxPlatform] that uses method channels.
class MethodChannelFlutterSingBox extends FlutterSingBoxPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('flutter_sing_box');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }

  @override
  Future<void> setup() async {
    final packageInfo = await PackageInfo.fromPlatform();
    await methodChannel.invokeMethod('setup', {
      'isDebug': kDebugMode,
      'packageName': packageInfo.packageName,
      'versionName': packageInfo.version,
      'versionCode': packageInfo.buildNumber,
    });
  }

  @override
  Future<String> importProfile(String url) async {
    return  await methodChannel.invokeMethod('importProfile', {
      'url': url,
    });

  }

  @override
  Future<void> startVpn() async {
    await methodChannel.invokeMethod('startVpn');
  }

  @override
  Future<void> stopVpn() async {
    await methodChannel.invokeMethod('stopVpn');
  }
}
