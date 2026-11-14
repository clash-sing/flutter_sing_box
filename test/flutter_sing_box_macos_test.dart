import 'dart:async';

import 'package:flutter_sing_box/flutter_sing_box.dart';
import 'package:flutter_sing_box/flutter_sing_box_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  FlutterSingBoxMacos buildPlatform({
    Future<bool> Function()? ruleSetExtractor,
  }) {
    return FlutterSingBoxMacos(
      ruleSetExtractor: ruleSetExtractor ?? () async => true,
    );
  }

  group('proxyStateStream', () {
    test('新订阅者先收到初始 stopped 状态', () async {
      final platform = buildPlatform();
      expect(await platform.proxyStateStream.first, ProxyState.stopped);
    });

    test('startVpn 下发 starting + 带 errMessage 的 stopped，不抛异常', () async {
      final platform = buildPlatform();
      final events = <ProxyState>[];
      final sub = platform.proxyStateStream.listen(events.add);
      addTearDown(sub.cancel);
      await pumpEventQueue();
      expect(events, [ProxyState.stopped]); // 初始重放

      await platform.startVpn();
      await pumpEventQueue();

      expect(events.length, 3);
      expect(events[1], ProxyState.starting);
      expect(events[2], isA<ProxyStopped>());
      expect(
        (events[2] as ProxyStopped).errMessage,
        FlutterSingBoxMacos.unsupportedMessage,
      );
    });

    test('同一 stream 对象可被二次订阅（广播流）', () async {
      final platform = buildPlatform();
      final stream = platform.proxyStateStream;

      final first = <ProxyState>[];
      final second = <ProxyState>[];
      final sub1 = stream.listen(first.add);
      final sub2 = stream.listen(second.add);
      addTearDown(sub1.cancel);
      addTearDown(sub2.cancel);
      await pumpEventQueue();

      expect(first, [ProxyState.stopped]);
      expect(second, [ProxyState.stopped]); // 第二订阅者也收到初始重放
    });

    test('同一轮次 listen + startVpn 不丢 starting', () async {
      final platform = buildPlatform();
      final events = <ProxyState>[];
      final sub = platform.proxyStateStream.listen(events.add);
      addTearDown(sub.cancel);

      // 不等待事件队列，立即触发启动：初始重放与后续状态都不得丢失
      await platform.startVpn();
      await pumpEventQueue();

      expect(events.length, 3);
      expect(events[0], ProxyState.stopped);
      expect(events[1], ProxyState.starting);
      expect(
        (events[2] as ProxyStopped).errMessage,
        FlutterSingBoxMacos.unsupportedMessage,
      );
    });

    test('stopVpn 下发正常 stopped', () async {
      final platform = buildPlatform();
      final events = <ProxyState>[];
      final sub = platform.proxyStateStream.listen(events.add);
      addTearDown(sub.cancel);
      await pumpEventQueue();

      await platform.stopVpn();
      await pumpEventQueue();

      expect(events.last, ProxyState.stopped);
    });
  });

  group('其余 API', () {
    test('init 调用规则集释放钩子', () async {
      var calls = 0;
      final platform = buildPlatform(
        ruleSetExtractor: () async {
          calls++;
          return false;
        },
      );
      await platform.init();
      expect(calls, 1);
    });

    test('规则集释放抛异常时 init 不上抛', () async {
      final platform = buildPlatform(
        ruleSetExtractor: () async => throw StateError('boom'),
      );
      await expectLater(platform.init(), completes);
    });

    test('getSingBoxVersion 返回 unsupported', () async {
      expect(await buildPlatform().getSingBoxVersion(), 'unsupported');
    });

    test('Windows 服务相关 API 返回非 Windows 默认值', () async {
      final platform = buildPlatform();
      expect(
        await platform.queryServiceStatus(),
        WindowsServiceStatus.unsupported,
      );
      expect(
        await platform.installService(
          serviceName: 's',
          displayName: 'd',
          description: 'x',
        ),
        isTrue,
      );
      expect(await platform.uninstallService(), isFalse);
      expect(await platform.startService(), isFalse);
      expect(await platform.stopService(), isFalse);
      expect(await platform.hasPendingHelperUpdate(), isFalse);
      expect(await platform.restartService(), isFalse);
    });

    test('空操作 API 正常完成', () async {
      final platform = buildPlatform();
      await platform.serviceReload();
      await platform.setClashMode('rule');
      await platform.selectOutbound(groupTag: 'g', outboundTag: 'o');
      await platform.setGroupExpand(groupTag: 'g', isExpand: true);
      await platform.urlTest(groupTag: 'g');
    });

    test('四条事件流为空且可重复监听', () async {
      final platform = buildPlatform();
      final streams = <Stream<dynamic>>[
        platform.connectedStatusStream,
        platform.groupStream,
        platform.clashModeStream,
        platform.logStream,
      ];
      for (final stream in streams) {
        expect(await stream.toList(), isEmpty);
        expect(await stream.toList(), isEmpty); // 广播流，可二次监听
      }
    });
  });

  group('registerWith', () {
    test('注册后平台实例为 macOS 实现', () {
      final original = FlutterSingBoxPlatform.instance;
      addTearDown(() => FlutterSingBoxPlatform.instance = original);
      FlutterSingBoxMacos.registerWith();
      expect(FlutterSingBoxPlatform.instance, isA<FlutterSingBoxMacos>());
    });
  });
}
