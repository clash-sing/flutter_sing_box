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

  group('ClashProxy.toOutbound - hysteria2 ports 端口跳跃', () {
    test('wiki 完整示例：斜杠与逗号分隔的多段范围加单端口', () {
      final proxy = ClashProxy.fromJson({
        'name': 'hy2',
        'type': 'hysteria2',
        'server': 's.com',
        'port': 443,
        'password': 'pwd',
        'ports': '114-514/810-1919,65530',
      });
      final o = proxy.toOutbound();
      expect(o!.serverPorts, ['114:514', '810:1919', '65530:65530']);
    });

    test('仅逗号分隔的多段', () {
      final proxy = ClashProxy.fromJson({
        'name': 'hy2c',
        'type': 'hysteria2',
        'server': 's.com',
        'port': 443,
        'password': 'pwd',
        'ports': '114-514,810-1919',
      });
      final o = proxy.toOutbound();
      expect(o!.serverPorts, ['114:514', '810:1919']);
    });

    test('单个端口范围（既有行为不回归）', () {
      final proxy = ClashProxy.fromJson({
        'name': 'hy2r',
        'type': 'hysteria2',
        'server': 's.com',
        'port': 443,
        'password': 'pwd',
        'ports': '114-514',
      });
      final o = proxy.toOutbound();
      expect(o!.serverPorts, ['114:514']);
    });

    test('单个端口号转为 start:end（sing-box 拒绝纯数字）', () {
      final proxy = ClashProxy.fromJson({
        'name': 'hy2s',
        'type': 'hysteria2',
        'server': 's.com',
        'port': 443,
        'password': 'pwd',
        'ports': '65530',
      });
      final o = proxy.toOutbound();
      expect(o!.serverPorts, ['65530:65530']);
    });

    test('空段被忽略', () {
      final proxy = ClashProxy.fromJson({
        'name': 'hy2e',
        'type': 'hysteria2',
        'server': 's.com',
        'port': 443,
        'password': 'pwd',
        'ports': '114-514,,65530/',
      });
      final o = proxy.toOutbound();
      expect(o!.serverPorts, ['114:514', '65530:65530']);
    });

    test('未配置 ports 时 server_ports 为 null（既有行为不回归）', () {
      final proxy = ClashProxy.fromJson({
        'name': 'hy2n',
        'type': 'hysteria2',
        'server': 's.com',
        'port': 443,
        'password': 'pwd',
      });
      final o = proxy.toOutbound();
      expect(o!.serverPorts, isNull);
    });

    test('hysteria 分支沿用同一转换', () {
      final proxy = ClashProxy.fromJson({
        'name': 'hy1',
        'type': 'hysteria',
        'server': 's.com',
        'port': 443,
        'ports': '114-514/810-1919,65530',
      });
      final o = proxy.toOutbound();
      expect(o!.serverPorts, ['114:514', '810:1919', '65530:65530']);
    });
  });
}
