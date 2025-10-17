import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_sing_box/flutter_sing_box.dart';
import 'package:flutter_sing_box/flutter_sing_box_platform_interface.dart';
import 'package:flutter_sing_box/flutter_sing_box_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockFlutterSingBoxPlatform
    with MockPlatformInterfaceMixin
    implements FlutterSingBoxPlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');

  @override
  Future<void> startVpn() {
    // TODO: implement startVpn
    throw UnimplementedError();
  }

  @override
  Future<void> stopVpn() {
    // TODO: implement stopVpn
    throw UnimplementedError();
  }

  @override
  Future<void> setup() {
    // TODO: implement setup
    throw UnimplementedError();
  }

  @override
  Future<String> importProfile(String url) {
    // TODO: implement importProfile
    throw UnimplementedError();
  }

  @override
  // TODO: implement vpnStatusStream
  Stream get vpnStatusStream => throw UnimplementedError();
}

void main() {
  final FlutterSingBoxPlatform initialPlatform = FlutterSingBoxPlatform.instance;

  test('$MethodChannelFlutterSingBox is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelFlutterSingBox>());
  });

  test('getPlatformVersion', () async {
    FlutterSingBox flutterSingBoxPlugin = FlutterSingBox();
    MockFlutterSingBoxPlatform fakePlatform = MockFlutterSingBoxPlatform();
    FlutterSingBoxPlatform.instance = fakePlatform;

    expect(await flutterSingBoxPlugin.getPlatformVersion(), '42');
  });
}
