import 'package:flutter_sing_box/flutter_sing_box.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ClashProxy.toOutbound - vless reality', () {
    test('reality-opts 映射且 enabled 必须为 true（sing-box 必需字段）', () {
      final proxy = ClashProxy.fromJson({
        'name': 'rv',
        'type': 'vless',
        'server': 's.com',
        'port': 443,
        'uuid': 'u1',
        'flow': 'xtls-rprx-vision',
        'tls': true,
        'sni': 'www.apple.com',
        'client-fingerprint': 'chrome',
        'reality-opts': {'public-key': 'pbk1', 'short-id': 'sid1'},
      });
      final o = proxy.toOutbound();
      expect(o, isNotNull);
      expect(o!.tls?.enabled, isTrue);
      expect(o.tls?.reality?.enabled, isTrue);
      expect(o.tls?.reality?.publicKey, 'pbk1');
      expect(o.tls?.reality?.shortId, 'sid1');
      expect(o.tls?.utls?.fingerprint, 'chrome');
      expect(o.tls?.serverName, 'www.apple.com');
      expect(o.flow, 'xtls-rprx-vision');
    });

    test('只写 reality-opts 未写 tls: true 时仍启用 TLS', () {
      final proxy = ClashProxy.fromJson({
        'name': 'rv2',
        'type': 'vless',
        'server': 's.com',
        'port': 443,
        'uuid': 'u2',
        'sni': 'www.apple.com',
        'reality-opts': {'public-key': 'pbk2'},
      });
      final o = proxy.toOutbound();
      expect(o!.tls?.enabled, isTrue);
      expect(o.tls?.reality?.enabled, isTrue);
      expect(o.tls?.reality?.publicKey, 'pbk2');
      // short-id 可选：未提供时保持 null
      expect(o.tls?.reality?.shortId, isNull);
    });

    test('无 reality-opts 且无 tls 时 TLS 不启用（既有行为不回归）', () {
      final proxy = ClashProxy.fromJson({
        'name': 'plain',
        'type': 'vless',
        'server': 's.com',
        'port': 80,
        'uuid': 'u3',
      });
      final o = proxy.toOutbound();
      expect(o!.tls?.enabled, isFalse);
      expect(o.tls?.reality, isNull);
    });
  });
}
