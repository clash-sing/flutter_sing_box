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

  group('ClashProxy.toOutbound - SNI 解析（sni/servername/server 回退）', () {
    test('vmess：servername 生效（mihomo TLS 字段）', () {
      final proxy = ClashProxy.fromJson({
        'name': 'vm',
        'type': 'vmess',
        'server': '1.2.3.4',
        'port': 443,
        'uuid': 'u1',
        'tls': true,
        'servername': 'cdn.example.com',
      });
      final o = proxy.toOutbound();
      expect(o!.tls?.serverName, 'cdn.example.com');
      expect(o.tls?.disableSni, isFalse);
    });

    test('vless：servername 生效', () {
      final proxy = ClashProxy.fromJson({
        'name': 'vl',
        'type': 'vless',
        'server': '1.2.3.4',
        'port': 443,
        'uuid': 'u2',
        'tls': true,
        'servername': 'cdn.example.com',
      });
      final o = proxy.toOutbound();
      expect(o!.tls?.serverName, 'cdn.example.com');
      expect(o.tls?.disableSni, isFalse);
    });

    test('trojan：servername 兼容（老 Clash 生态写法）', () {
      final proxy = ClashProxy.fromJson({
        'name': 'tj',
        'type': 'trojan',
        'server': '1.2.3.4',
        'port': 443,
        'password': 'pwd',
        'servername': 'cdn.example.com',
      });
      final o = proxy.toOutbound();
      expect(o!.tls?.serverName, 'cdn.example.com');
      expect(o.tls?.disableSni, isFalse);
    });

    test('sni 与 servername 并存时 sni 优先（mihomo 一般协议字段）', () {
      final proxy = ClashProxy.fromJson({
        'name': 'both',
        'type': 'vmess',
        'server': '1.2.3.4',
        'port': 443,
        'uuid': 'u3',
        'tls': true,
        'sni': 'from-sni.com',
        'servername': 'from-servername.com',
      });
      final o = proxy.toOutbound();
      expect(o!.tls?.serverName, 'from-sni.com');
    });

    test('vmess 无 SNI 时回退 server', () {
      final proxy = ClashProxy.fromJson({
        'name': 'vmn',
        'type': 'vmess',
        'server': 'vm.com',
        'port': 443,
        'uuid': 'u4',
        'tls': true,
      });
      final o = proxy.toOutbound();
      expect(o!.tls?.serverName, 'vm.com');
      expect(o.tls?.disableSni, isFalse);
    });

    test('trojan 无 SNI 时回退 server', () {
      final proxy = ClashProxy.fromJson({
        'name': 'tjn',
        'type': 'trojan',
        'server': 'tj.com',
        'port': 443,
        'password': 'pwd',
      });
      final o = proxy.toOutbound();
      expect(o!.tls?.serverName, 'tj.com');
      expect(o.tls?.disableSni, isFalse);
    });

    test('hysteria2 无 SNI 时回退 server', () {
      final proxy = ClashProxy.fromJson({
        'name': 'hy2s',
        'type': 'hysteria2',
        'server': 'hy2.com',
        'port': 443,
        'password': 'pwd',
      });
      final o = proxy.toOutbound();
      expect(o!.tls?.serverName, 'hy2.com');
      expect(o.tls?.disableSni, isFalse);
    });

    test('tuic：显式 disable-sni 保留，无 SNI 时 serverName 回退 server', () {
      final disabled = ClashProxy.fromJson({
        'name': 'tc1',
        'type': 'tuic',
        'server': 'tc.com',
        'port': 443,
        'uuid': 'u5',
        'password': 'pwd',
        'disable-sni': true,
      });
      expect(disabled.toOutbound()!.tls?.disableSni, isTrue);

      final fallback = ClashProxy.fromJson({
        'name': 'tc2',
        'type': 'tuic',
        'server': 'tc.com',
        'port': 443,
        'uuid': 'u6',
        'password': 'pwd',
      });
      final o = fallback.toOutbound();
      expect(o!.tls?.serverName, 'tc.com');
      expect(o.tls?.disableSni, isFalse);
    });

    test('sni 显式空串时不发送 SNI', () {
      final proxy = ClashProxy.fromJson({
        'name': 'empty',
        'type': 'trojan',
        'server': 'e.com',
        'port': 443,
        'password': 'pwd',
        'sni': '',
      });
      final o = proxy.toOutbound();
      expect(o!.tls?.serverName, '');
      expect(o.tls?.disableSni, isTrue);
    });
  });
}
