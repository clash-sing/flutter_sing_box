import 'package:flutter/services.dart';
import 'package:flutter_sing_box/flutter_sing_box.dart';
import 'package:flutter_test/flutter_test.dart';

/// EventChannel 模拟辅助：响应 listen/cancel，并提供向客户端推送事件的能力。
class _FakeEventChannelHost {
  _FakeEventChannelHost(String channelName) : _channelName = channelName;

  final String _channelName;
  static const StandardMethodCodec _codec = StandardMethodCodec();

  void register() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMessageHandler(
      _channelName,
      (ByteData? message) async {
        // 校验消息可解码（listen/cancel 的 MethodCall），统一以 success envelope 回复
        _codec.decodeMethodCall(message);
        return _codec.encodeSuccessEnvelope(null);
      },
    );
  }

  void unregister() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMessageHandler(_channelName, null);
  }

  /// 模拟原生侧 success 事件。
  Future<void> emitSuccess(Object? event) async {
    await _deliver(_codec.encodeSuccessEnvelope(event));
  }

  /// 模拟原生侧 error 事件（对应 Kotlin 侧 EventSink.error(code, message, null)）。
  Future<void> emitError(String code, String? message) async {
    await _deliver(_codec.encodeErrorEnvelope(code: code, message: message));
  }

  Future<void> _deliver(ByteData? envelope) async {
    await TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .handlePlatformMessage(_channelName, envelope, (ByteData? data) {});
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late final _FakeEventChannelHost proxyStateHost;
  setUpAll(() {
    proxyStateHost = _FakeEventChannelHost('proxy_state_event')..register();
  });

  tearDownAll(() {
    proxyStateHost.unregister();
  });

  group('proxyStateStream', () {
    test('success 事件按状态名解析', () async {
      final platform = MethodChannelFlutterSingBox();
      final events = <ProxyState>[];
      final sub = platform.proxyStateStream.listen(events.add);
      await Future<void>.delayed(Duration.zero);

      await proxyStateHost.emitSuccess('Started');
      await Future<void>.delayed(Duration.zero);
      await sub.cancel();

      expect(events, [ProxyState.started]);
    });

    test('error 事件的 message 透传为 stopped 的 errMessage', () async {
      final platform = MethodChannelFlutterSingBox();
      final events = <ProxyState>[];
      final sub = platform.proxyStateStream.listen(events.add);
      await Future<void>.delayed(Duration.zero);

      // 对应 Android 原生侧 onServiceAlert: error(code: "Stopped", message: 错误信息)
      await proxyStateHost.emitError('Stopped', '启动失败');
      await Future<void>.delayed(Duration.zero);
      await sub.cancel();

      expect(events.single, const ProxyStopped(errMessage: '启动失败'));
    });
  });
}
