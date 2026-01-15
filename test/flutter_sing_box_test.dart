import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_sing_box/flutter_sing_box.dart';
import 'package:flutter_sing_box/flutter_sing_box_platform_interface.dart';
import 'package:flutter_sing_box/flutter_sing_box_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockFlutterSingBoxPlatform
    with MockPlatformInterfaceMixin
    implements FlutterSingBoxPlatform {

  @override
  Future<void> init() {
    // TODO: implement init
    throw UnimplementedError();
  }

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
  Future<void> serviceReload() {
    // TODO: implement serviceReload
    throw UnimplementedError();
  }

  @override
  Future<void> setClashMode(String mode) {
    // TODO: implement setClashMode
    throw UnimplementedError();
  }

  @override
  Future<void> selectOutbound({required String groupTag, required String outboundTag}) {
    // TODO: implement selectOutbound
    throw UnimplementedError();
  }

  @override
  Future<void> urlTest({required String groupTag}) {
    // TODO: implement urlTest
    throw UnimplementedError();
  }

  @override
  Future<void> setGroupExpand({required String groupTag, required bool isExpand}) {
    // TODO: implement setGroupExpand
    throw UnimplementedError();
  }


  @override
  // TODO: implement clashModeStream
  Stream<ClientClashMode> get clashModeStream => throw UnimplementedError();

  @override
  // TODO: implement connectedStatusStream
  Stream<ClientStatus> get connectedStatusStream => throw UnimplementedError();

  @override
  // TODO: implement groupStream
  Stream<List<ClientGroup>> get groupStream => throw UnimplementedError();

  @override
  // TODO: implement logStream
  Stream<List<String>> get logStream => throw UnimplementedError();

  @override
  // TODO: implement proxyStateStream
  Stream<ProxyState> get proxyStateStream => throw UnimplementedError();

  @override
  Future<String> getSingBoxVersion() {
    // TODO: implement getSingBoxVersion
    throw UnimplementedError();
  }

}

void main() {
  final FlutterSingBoxPlatform initialPlatform = FlutterSingBoxPlatform.instance;

  test('$MethodChannelFlutterSingBox is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelFlutterSingBox>());
  });

  // test('getPlatformVersion', () async {
  //   FlutterSingBox flutterSingBoxPlugin = FlutterSingBox();
  //   MockFlutterSingBoxPlatform fakePlatform = MockFlutterSingBoxPlatform();
  //   FlutterSingBoxPlatform.instance = fakePlatform;
  //
  //   expect(await flutterSingBoxPlugin.getPlatformVersion(), '42');
  // });
}
