import 'dart:io';

import 'package:flutter_sing_box/flutter_sing_box.dart';
import 'package:flutter_sing_box/flutter_sing_box_platform_interface.dart';
import 'package:flutter_sing_box/src/windows/helper_http_client.dart';
import 'package:flutter_test/flutter_test.dart';

/// 本地假 helper API：记录收到的请求路径，统一返回 JSON 编码的 [response]。
class _FakeHelperServer {
  _FakeHelperServer(this.server);

  final HttpServer server;
  final List<String> requests = [];

  static Future<_FakeHelperServer> start(String response) async {
    final fake = _FakeHelperServer(await HttpServer.bind('127.0.0.1', 0));
    fake.server.listen((request) async {
      fake.requests.add(request.uri.path);
      // dio 只对 application/json 响应做 JSON 解码（生产 Go 服务端也设了此头）
      request.response.headers.contentType = ContentType.json;
      request.response.write('"$response"');
      await request.response.close();
    });
    return fake;
  }

  int get port => server.port;
}

HelperConfig _configOf(int port) => HelperConfig(
      helperServiceName: 'test',
      helperServiceDisplayName: 'test',
      helperServiceDescription: 'test',
      singBoxExecute: 'test.exe',
      singBoxConfig: 'config.json',
      helperPort: port,
    );

void main() {
  setUp(() {
    // emitProxyState 会读 CsSettingsStorage().systemProxyActive，需 mock MMKV
    CsSettingsStorage.mockInit();
  });

  /// 平台实例 + 状态流收集（含初始 stopped 重放），返回收集列表供断言。
  Future<List<ProxyState>> setUpPlatform() async {
    final platform = FlutterSingBoxWindows();
    FlutterSingBoxPlatform.instance = platform;
    final events = <ProxyState>[];
    final sub = platform.proxyStateStream.listen(events.add);
    addTearDown(() async {
      await sub.cancel();
      platform.dispose();
      FlutterSingBoxPlatform.instance = MethodChannelFlutterSingBox();
    });
    await Future<void>.delayed(Duration.zero); // 收初始 stopped 重放
    return events;
  }

  group('start/restart/stop 失败（B 模型：错误唯一出口是状态流）', () {
    test('start 失败：emit 带 errMessage 的 stopped，不抛异常', () async {
      final events = await setUpPlatform();
      await HelperHttpClient.forTest(() async => _configOf(1)).start();
      await Future<void>.delayed(Duration.zero);
      expect(events.length, 3);
      expect(events[0], ProxyState.stopped);
      expect(events[1], ProxyState.starting);
      expect(events[2], isA<ProxyStopped>());
      expect((events[2] as ProxyStopped).errMessage, isNotNull);
    });

    test('restart 失败：emit 带 errMessage 的 stopped，不抛异常', () async {
      final events = await setUpPlatform();
      await HelperHttpClient.forTest(() async => _configOf(1)).restart();
      await Future<void>.delayed(Duration.zero);
      expect(events.length, 3);
      expect(events[0], ProxyState.stopped);
      expect(events[1], ProxyState.starting);
      expect(events[2], isA<ProxyStopped>());
      expect((events[2] as ProxyStopped).errMessage, isNotNull);
    });

    test('stop 失败：emit 带 errMessage 的 stopped，不抛异常', () async {
      final events = await setUpPlatform();
      await HelperHttpClient.forTest(() async => _configOf(1)).stop();
      await Future<void>.delayed(Duration.zero);
      expect(events.length, 3);
      expect(events[0], ProxyState.stopped);
      expect(events[1], ProxyState.stopping);
      expect(events[2], isA<ProxyStopped>());
      expect((events[2] as ProxyStopped).errMessage, isNotNull);
    });
  });

  group('端口现读（服务重启换端口，任何跨调用缓存都会作废）', () {
    test('stop：helper.json 端口变化后，请求打到新端口', () async {
      await setUpPlatform();
      final fake1 = await _FakeHelperServer.start('success');
      final fake2 = await _FakeHelperServer.start('success');
      addTearDown(() => fake1.server.close(force: true));
      addTearDown(() => fake2.server.close(force: true));

      // currentPort 模拟 helper.json 当前内容：服务重启后由旧端口换成新端口
      var currentPort = fake1.port;
      final client = HelperHttpClient.forTest(() async => _configOf(currentPort));

      await client.stop();
      currentPort = fake2.port; // 模拟服务崩溃自愈、端口回写
      await client.stop();

      expect(fake1.requests, ['/stop']);
      expect(fake2.requests, ['/stop']);
    });

    test('stop：连接被拒后重读配置重试一次（撞上服务自动重启窗口）', () async {
      final events = await setUpPlatform();
      final live = await _FakeHelperServer.start('success');
      addTearDown(() => live.server.close(force: true));

      var loadCount = 0;
      final client = HelperHttpClient.forTest(() async {
        loadCount++;
        // 第一次读到旧端口（已失效），重试读到服务重启后的新端口
        return loadCount == 1 ? _configOf(1) : _configOf(live.port);
      });

      await client.stop();
      await Future<void>.delayed(Duration.zero);

      expect(loadCount, 2);
      expect(live.requests, ['/stop']);
      expect(events, [ProxyState.stopped, ProxyState.stopping, ProxyState.stopped]);
    });
  });

  test('status：running → emit started', () async {
    final events = await setUpPlatform();
    final fake = await _FakeHelperServer.start('running');
    addTearDown(() => fake.server.close(force: true));
    await HelperHttpClient.forTest(() async => _configOf(fake.port)).status();
    await Future<void>.delayed(Duration.zero);
    expect(events, [ProxyState.stopped, ProxyState.started]);
  });
}
