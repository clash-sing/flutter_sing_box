import 'package:flutter_sing_box/src/storage/cs_settings_storage.dart';
import 'package:flutter_sing_box/src/windows/system_proxy_service.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeApplier implements SystemProxyApplier {
  int enableCalls = 0;
  int disableCalls = 0;
  String? lastProxy;
  @override
  Future<void> enable(String proxy) async {
    enableCalls++;
    lastProxy = proxy;
  }

  @override
  Future<void> disable() async {
    disableCalls++;
  }
}

void main() {
  setUp(CsSettingsStorage.mockInit);

  test('enable 以默认端口拼代理地址并置标志 true', () async {
    final fake = _FakeApplier();
    await SystemProxyService(applier: fake).enable();
    expect(fake.enableCalls, 1);
    expect(fake.lastProxy, '127.0.0.1:8890');
    expect(CsSettingsStorage().systemProxyActive, isTrue);
  });

  test('disable 置标志 false', () async {
    CsSettingsStorage().systemProxyActive = true;
    final fake = _FakeApplier();
    await SystemProxyService(applier: fake).disable();
    expect(fake.disableCalls, 1);
    expect(CsSettingsStorage().systemProxyActive, isFalse);
  });

  test('mixedPort 改为 7890 后 enable 用 7890', () async {
    CsSettingsStorage().mixedPort = 7890;
    final fake = _FakeApplier();
    await SystemProxyService(applier: fake).enable();
    expect(fake.lastProxy, '127.0.0.1:7890');
  });
}
