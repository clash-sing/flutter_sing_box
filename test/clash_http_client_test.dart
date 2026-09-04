import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_sing_box/flutter_sing_box.dart';
import 'package:flutter_sing_box/src/windows/clash_http_client.dart';
import 'package:flutter_test/flutter_test.dart';

import 'test_utils.dart';

/// 用本地 HttpServer + WebSocketTransformer 模拟 Clash API 的 /logs 端点，
/// 验证 ClashHttpClient.subscribeLogs 的真实行为（真实网络、无 mock）。
void main() {
  setUp(CsSettingsStorage.mockInit);

  group('ClashHttpClient.subscribeLogs', () {
    test('连接设置端口的 /logs 并将 info 消息解析为 ClientLog', () async {
      final server = await HttpServer.bind('127.0.0.1', 0);
      addTearDown(() => server.close(force: true));
      CsSettingsStorage().setClashApiPort(server.port);

      final connected = Completer<WebSocket>();
      late Uri requestUri;
      server.listen((request) async {
        requestUri = request.uri;
        connected.complete(await WebSocketTransformer.upgrade(request));
      });

      final firstLog = Completer<List<ClientLog>>();
      final subscription = ClashHttpClient().subscribeLogs().listen(firstLog.complete);

      final serverSocket = await connected.future;
      addTearDown(serverSocket.close);
      serverSocket.add(jsonEncode({'type': 'info', 'payload': 'hello sing-box'}));

      final logs = await firstLog.future.timeout(const Duration(seconds: 5));
      expect(requestUri.path, '/logs');
      expect(logs, hasLength(1));
      expect(logs.first.level, 4);
      expect(logs.first.message, 'hello sing-box');
      await subscription.cancel();
    });

    test('将 Clash 日志 type 映射为 ClientLog.level 数字', () async {
      final server = await HttpServer.bind('127.0.0.1', 0);
      addTearDown(() => server.close(force: true));
      CsSettingsStorage().setClashApiPort(server.port);

      final connected = Completer<WebSocket>();
      server.listen((request) async {
        connected.complete(await WebSocketTransformer.upgrade(request));
      });

      final levels = <int>[];
      final messages = <String>[];
      final subscription = ClashHttpClient().subscribeLogs().listen((logs) {
        levels.add(logs.single.level);
        messages.add(logs.single.message);
      });

      final serverSocket = await connected.future;
      addTearDown(serverSocket.close);
      serverSocket.add(jsonEncode({'type': 'debug', 'payload': 'm1'}));
      serverSocket.add(jsonEncode({'type': 'warning', 'payload': 'm2'}));
      serverSocket.add(jsonEncode({'type': 'warn', 'payload': 'm2b'}));
      serverSocket.add(jsonEncode({'type': 'error', 'payload': 'm3'}));
      serverSocket.add(jsonEncode({'type': 'whatever', 'payload': 'm4'}));

      await until(() => levels.length >= 5);
      expect(levels, [5, 3, 3, 2, 4]);
      expect(messages, ['m1', 'm2', 'm2b', 'm3', 'm4']);
      await subscription.cancel();
    });

    test('取消订阅后断开底层 WebSocket 连接', () async {
      final server = await HttpServer.bind('127.0.0.1', 0);
      addTearDown(() => server.close(force: true));
      CsSettingsStorage().setClashApiPort(server.port);

      final connected = Completer<WebSocket>();
      server.listen((request) async {
        connected.complete(await WebSocketTransformer.upgrade(request));
      });

      final firstLog = Completer<List<ClientLog>>();
      final subscription = ClashHttpClient().subscribeLogs().listen(firstLog.complete);

      final serverSocket = await connected.future;
      // 服务端必须消费事件流，否则 dart:io 不会处理关闭帧、done 永不完成。
      serverSocket.listen((_) {});
      serverSocket.add(jsonEncode({'type': 'info', 'payload': 'bye'}));
      await firstLog.future.timeout(const Duration(seconds: 5));

      // cancel 本身必须在短时间内完成，且服务端要感知到客户端断开。
      await subscription.cancel().timeout(const Duration(seconds: 2));
      await serverSocket.done.timeout(const Duration(seconds: 5));
    });
  });
}
