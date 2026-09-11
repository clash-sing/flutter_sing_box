import 'package:flutter_sing_box/flutter_sing_box.dart';
import 'package:flutter_sing_box/flutter_sing_box_platform_interface.dart';
import 'package:flutter_sing_box/src/windows/helper_http_client.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // start/restart 失败路径的公共断言（B 模型）：错误唯一出口是状态流——
  // emit 带 errMessage 的 stopped，调用方 Future 正常完成、不再抛异常。
  Future<void> expectFailureEmitsStoppedWithError(Future<void> Function() action) async {
    // emitProxyState(stopped) 会读 CsSettingsStorage().systemProxyActive，需 mock MMKV
    CsSettingsStorage.mockInit();
    final platform = FlutterSingBoxWindows();
    FlutterSingBoxPlatform.instance = platform;
    addTearDown(() {
      platform.dispose();
      FlutterSingBoxPlatform.instance = MethodChannelFlutterSingBox();
      HelperHttpClient().config = null;
    });

    final events = <ProxyState>[];
    final sub = platform.proxyStateStream.listen(events.add);
    await Future<void>.delayed(Duration.zero); // 收初始 stopped 重放

    // 指向必然连接失败的端口，触发 catch 路径
    HelperHttpClient().config = HelperConfig(
      helperServiceName: 'test',
      helperServiceDisplayName: 'test',
      helperServiceDescription: 'test',
      singBoxExecute: 'test.exe',
      singBoxConfig: 'config.json',
      helperPort: 1,
    );

    // 不再抛异常：调用正常完成，失败只经状态流传递
    await action();
    await Future<void>.delayed(Duration.zero); // 等事件送达订阅者
    await sub.cancel();

    expect(events.length, 3);
    expect(events[0], ProxyState.stopped);
    expect(events[1], ProxyState.starting);
    expect(events[2], isA<ProxyStopped>());
    expect((events[2] as ProxyStopped).errMessage, isNotNull);
  }

  test('start 失败：emit 带 errMessage 的 stopped，不抛异常', () async {
    await expectFailureEmitsStoppedWithError(() => HelperHttpClient().start());
  });

  test('restart 失败：emit 带 errMessage 的 stopped，不抛异常', () async {
    await expectFailureEmitsStoppedWithError(() => HelperHttpClient().restart());
  });
}
