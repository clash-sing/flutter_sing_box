import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_sing_box/flutter_sing_box.dart';
import 'package:flutter_test/flutter_test.dart';

import 'test_utils.dart';

void main() {
  group('FlutterSingBoxWindows.clashModeStream', () {
    test('emitClashMode 后 stream 推送该模式（缓存路径）', () async {
      final platform = FlutterSingBoxWindows();
      final mode = ClientClashMode(
        modes: ['rule', 'global', 'direct'],
        currentMode: 'global',
      );

      platform.emitClashMode(mode);

      final result = await platform.clashModeStream.first;
      expect(result.currentMode, 'global');
      expect(result.modes, ['rule', 'global', 'direct']);
    });
  });

  group('FlutterSingBoxWindows.logStream', () {
    setUp(CsSettingsStorage.mockInit);

    test('emitLogs 后 stream 推送该日志（无缓存，事件流）', () async {
      final platform = FlutterSingBoxWindows();

      // 先订阅再 emit：日志是事件流，无 _last 缓存重放
      final firstLog = platform.logStream.first;
      platform.emitLogs([const ClientLog(level: 4, message: 'hi')]);
      final logs = await firstLog.timeout(const Duration(seconds: 5));
      expect(logs.single.level, 4);
      expect(logs.single.message, 'hi');
    });

    test('started 后订阅 Clash API 日志，stopped 后断开订阅', () async {
      final server = await HttpServer.bind('127.0.0.1', 0);
      addTearDown(() => server.close(force: true));
      CsSettingsStorage().setClashApiPort(server.port);

      final connected = Completer<WebSocket>();
      server.listen((request) async {
        if (request.uri.path == '/logs') {
          connected.complete(await WebSocketTransformer.upgrade(request));
        } else {
          // _refreshClashMode/_refreshClientGroup 会轮询 /configs、/proxies，回 404 即可
          request.response.statusCode = 404;
          await request.response.close();
        }
      });

      final platform = FlutterSingBoxWindows();
      final received = <String>[];
      final sub = platform.logStream.listen((logs) => received.add(logs.single.message));

      platform.emitProxyState(ProxyState.started);
      final serverSocket = await connected.future;
      serverSocket.listen((_) {});
      serverSocket.add(jsonEncode({'type': 'info', 'payload': 'L1'}));
      await until(() => received.contains('L1'));
      expect(received, ['L1']);

      platform.emitProxyState(ProxyState.stopped);
      // stopped 后底层 WS 被断开（服务端感知 done），此后不再有日志推送。
      await serverSocket.done.timeout(const Duration(seconds: 5));

      await sub.cancel();
      platform.dispose();
    });
  });

  group('FlutterSingBoxWindows.helper 存活轮询', () {
    setUp(CsSettingsStorage.mockInit);

    /// 起一个 404 服务器吸收 started 触发的 Clash API 副作用流（clash mode/group/log）。
    Future<void> setUpClashStub() async {
      final server = await HttpServer.bind('127.0.0.1', 0);
      server.listen((request) async {
        request.response.statusCode = 404;
        await request.response.close();
      });
      CsSettingsStorage().setClashApiPort(server.port);
      addTearDown(() => server.close(force: true));
    }

    /// 平台实例 + 探测注入 + 状态流收集，返回收集列表。
    List<ProxyState> setUpPlatform(
      FlutterSingBoxWindows platform, {
      Future<String> Function()? probe,
      Duration interval = const Duration(milliseconds: 30),
    }) {
      platform.helperWatchInterval = interval;
      platform.helperStatusProbe =
          probe ?? (() async => 'running');
      final events = <ProxyState>[];
      final sub = platform.proxyStateStream.listen(events.add);
      addTearDown(() async {
        await sub.cancel();
        platform.dispose();
      });
      return events;
    }

    test('探测失败（helper 服务崩溃）→ emit 带 errMessage 的 ProxyStopped', () async {
      await setUpClashStub();
      final platform = FlutterSingBoxWindows();
      var probeCount = 0;
      final events = setUpPlatform(platform, probe: () async {
        probeCount++;
        if (probeCount <= 2) return 'running';
        throw Exception('connection refused');
      });

      await Future<void>.delayed(Duration.zero); // 收初始 stopped 重放
      platform.emitProxyState(ProxyState.started);
      await until(() => events.any((e) => e is ProxyStopped && e.errMessage != null));

      expect(events[0], ProxyState.stopped); // 初始重放
      expect(events[1], ProxyState.started);
      final stopped = events.last as ProxyStopped;
      expect(stopped.errMessage, contains('不可达'));
    });

    test('探测返回 stopped（sing-box 退出）→ emit 带 errMessage 的 ProxyStopped', () async {
      await setUpClashStub();
      final platform = FlutterSingBoxWindows();
      final events = setUpPlatform(platform, probe: () async => 'stopped');

      await Future<void>.delayed(Duration.zero);
      platform.emitProxyState(ProxyState.started);
      await until(() => events.any((e) => e is ProxyStopped && e.errMessage != null));

      final stopped = events.last as ProxyStopped;
      expect(stopped.errMessage, contains('sing-box'));
    });

    test('stopped 后轮询终止，不再探测', () async {
      await setUpClashStub();
      final platform = FlutterSingBoxWindows();
      var probeCount = 0;
      final events = setUpPlatform(platform, probe: () async {
        probeCount++;
        return 'running';
      });

      await Future<void>.delayed(Duration.zero);
      platform.emitProxyState(ProxyState.started);
      await until(() => probeCount >= 2);
      platform.emitProxyState(ProxyState.stopped);

      final probesAtStop = probeCount;
      await Future<void>.delayed(const Duration(milliseconds: 150));
      expect(probeCount, probesAtStop);
      // 状态流只有初始重放与正常 stopped 两次，均无 errMessage（无异常停止）
      expect(events.whereType<ProxyStopped>().length, 2);
      expect(events.any((e) => e is ProxyStopped && e.errMessage != null), isFalse);
    });
  });
}
