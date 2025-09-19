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
