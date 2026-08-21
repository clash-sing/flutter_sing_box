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
}
