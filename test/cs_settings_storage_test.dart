import 'package:flutter_sing_box/flutter_sing_box.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  setUp(CsSettingsStorage.mockInit); // 注入 MemoryStorage,隔离 MMKV

  group('proxyMode', () {
    test('未设置时默认为 tun', () {
      expect(CsSettingsStorage().proxyMode, ProxyMode.tun);
    });
    test('设为 systemProxy 后读取为 systemProxy', () {
      CsSettingsStorage().proxyMode = ProxyMode.systemProxy;
      expect(CsSettingsStorage().proxyMode, ProxyMode.systemProxy);
    });
  });

  group('mixedPort', () {
    test('未设置时默认为 8890', () {
      expect(CsSettingsStorage().mixedPort, 8890);
    });
    test('设为 7890 后读取为 7890', () {
      CsSettingsStorage().mixedPort = 7890;
      expect(CsSettingsStorage().mixedPort, 7890);
    });
  });

  group('systemProxyActive', () {
    test('未设置时默认为 false', () {
      expect(CsSettingsStorage().systemProxyActive, isFalse);
    });
    test('设为 true 后读取为 true', () {
      CsSettingsStorage().systemProxyActive = true;
      expect(CsSettingsStorage().systemProxyActive, isTrue);
    });
  });
}
