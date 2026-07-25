import 'package:flutter_sing_box/src/data/models/clash/clash_configs.dart';
import 'package:flutter_sing_box/src/windows/clash_http_client.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ClashHttpClient.modeFromConfigs', () {
    test('mode/modeList 映射到 currentMode/modes', () {
      final configs = ClashConfigs(
        port: 7890,
        socksPort: 7891,
        redirPort: 0,
        tproxyPort: 0,
        mixedPort: 7892,
        allowLan: false,
        bindAddress: '*',
        mode: 'rule',
        modeList: ['rule', 'global', 'direct'],
        logLevel: 'info',
        ipv6: false,
      );

      final mode = ClashHttpClient.modeFromConfigs(configs);

      expect(mode.currentMode, 'rule');
      expect(mode.modes, ['rule', 'global', 'direct']);
    });
  });
}
