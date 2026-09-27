import 'dart:convert';

import 'package:flutter_sing_box/flutter_sing_box.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // 将若干分享链接行编码为 base64 订阅体
  String encodeSub(List<String> lines) => base64.encode(utf8.encode(lines.join('\n')));

  group('Base64Provider.provide - vless', () {
    test('Vision + Reality：解析 uuid/flow/reality/utls', () {
      const link = 'vless://b831381d-6324-4d53-ad4f-8cda48b30811@example.com:443'
          '?encryption=none&security=reality&sni=www.microsoft.com&fp=chrome'
          '&pbk=xR8mHkP6QqN&sid=a1b2c3&type=tcp&flow=xtls-rprx-vision#%E8%8A%82%E7%82%B9';
      final outbounds = Base64Provider.provide(encodeSub([link]));
      expect(outbounds, hasLength(1));
      final o = outbounds.first;
      expect(o.type, OutboundType.vless);
      expect(o.uuid, 'b831381d-6324-4d53-ad4f-8cda48b30811');
      expect(o.flow, 'xtls-rprx-vision');
      expect(o.server, 'example.com');
      expect(o.serverPort, 443);
      expect(o.tag, '节点');
      expect(o.tls?.enabled, isTrue);
      expect(o.tls?.reality?.enabled, isTrue);
      expect(o.tls?.reality?.publicKey, 'xR8mHkP6QqN');
      expect(o.tls?.reality?.shortId, 'a1b2c3');
      expect(o.tls?.utls?.fingerprint, 'chrome');
      expect(o.tls?.serverName, 'www.microsoft.com');
      expect(o.transport, isNull);
    });

    test('ws + TLS：path/Host header/alpn 拆分', () {
      const link = 'vless://uuid-1@a.com:443?encryption=none&security=tls'
          '&sni=a.com&type=ws&host=cdn.a.com&path=%2Fws&alpn=h2,http/1.1#ws';
      final o = Base64Provider.provide(encodeSub([link])).first;
      expect(o.tls?.alpn, ['h2', 'http/1.1']);
      expect(o.tls?.enabled, isTrue);
      expect(o.transport?.type, OutboundTransportType.webSocket);
      expect(o.transport?.path, '/ws');
      expect(o.transport?.headers?['Host'], 'cdn.a.com');
    });

    test('grpc：serviceName 优先于 path 兼容', () {
      const link = 'vless://uuid-2@b.com:443?security=tls&type=grpc&serviceName=GunSrv#grpc';
      final o = Base64Provider.provide(encodeSub([link])).first;
      expect(o.transport?.type, OutboundTransportType.gRPC);
      expect(o.transport?.serviceName, 'GunSrv');
    });

    test('grpc：仅有 path 时作为 serviceName 兜底', () {
      const link = 'vless://uuid-2b@b.com:443?security=tls&type=grpc&path=GunSrv2#grpc2';
      final o = Base64Provider.provide(encodeSub([link])).first;
      expect(o.transport?.serviceName, 'GunSrv2');
    });

    test('security=none：tls 为 null，flow 缺省不报错', () {
      const link = 'vless://uuid-3@c.com:80?type=tcp#plain';
      final o = Base64Provider.provide(encodeSub([link])).first;
      expect(o.tls, isNull);
      expect(o.flow, isNull);
      expect(o.transport, isNull);
    });

    test('旧值 security=xtls 按 TLS 处理', () {
      const link = 'vless://u@d.com:443?security=xtls&sni=d.com#legacy';
      final o = Base64Provider.provide(encodeSub([link])).first;
      expect(o.tls?.enabled, isTrue);
      expect(o.tls?.reality, isNull);
    });

    test('packetEncoding 透传', () {
      const link = 'vless://u@e.com:443?security=tls&packetEncoding=packetaddr#pe';
      final o = Base64Provider.provide(encodeSub([link])).first;
      expect(o.packetEncoding, 'packetaddr');
    });

    test('无 sni 的 TLS 链接回退 host 作 serverName', () {
      const link = 'vless://u@g.com:443?security=tls#no-sni';
      final o = Base64Provider.provide(encodeSub([link])).first;
      expect(o.tls?.serverName, 'g.com');
      expect(o.tls?.disableSni, isFalse);
    });

    test('未知 scheme 行被跳过，不影响其他行', () {
      const lines = ['wireguard://x@y:1', 'vless://u@f.com:443?security=tls#ok'];
      final outbounds = Base64Provider.provide(encodeSub(lines));
      expect(outbounds, hasLength(1));
      expect(outbounds.first.tag, 'ok');
    });
  });

  group('Base64Provider.provide - vmess', () {
    // 按 v2rayN 字段名构造 vmess JSON 并编码为分享链接
    String vmessLink(Map<String, dynamic> json) =>
        'vmess://${base64.encode(utf8.encode(jsonEncode(json)))}';

    test('ws + tls：解析 uuid/security/alterId/transport/tls', () {
      final link = vmessLink({
        'v': '2',
        'ps': '节点A',
        'add': 'a.com',
        'port': 443,
        'id': 'b831381d-6324-4d53-ad4f-8cda48b30811',
        'aid': 0,
        'scy': 'auto',
        'net': 'ws',
        'host': 'cdn.a.com',
        'path': '/ws',
        'tls': 'tls',
        'sni': 'a.com',
        'alpn': 'h2,http/1.1',
        'fp': 'chrome',
      });
      final o = Base64Provider.provide(encodeSub([link])).first;
      expect(o.type, OutboundType.vmess);
      expect(o.tag, '节点A');
      expect(o.server, 'a.com');
      expect(o.serverPort, 443);
      expect(o.uuid, 'b831381d-6324-4d53-ad4f-8cda48b30811');
      expect(o.security, 'auto');
      expect(o.alterId, 0);
      expect(o.tls?.enabled, isTrue);
      expect(o.tls?.serverName, 'a.com');
      expect(o.tls?.alpn, ['h2', 'http/1.1']);
      expect(o.tls?.utls?.fingerprint, 'chrome');
      expect(o.transport?.type, OutboundTransportType.webSocket);
      expect(o.transport?.path, '/ws');
      expect(o.transport?.headers?['Host'], 'cdn.a.com');
    });

    test('tcp 无 tls：transport 与 tls 均为 null', () {
      final link = vmessLink({
        'v': '2',
        'ps': 'plain',
        'add': 'b.com',
        'port': 80,
        'id': 'u1',
        'aid': '64',
        'net': 'tcp',
        'tls': '',
      });
      final o = Base64Provider.provide(encodeSub([link])).first;
      expect(o.security, 'auto'); // scy 缺省
      expect(o.alterId, 64); // 字符串型 aid
      expect(o.tls, isNull);
      expect(o.transport, isNull);
    });

    test('grpc：path 映射为 serviceName', () {
      final link = vmessLink({
        'v': '2',
        'ps': 'g',
        'add': 'c.com',
        'port': '443', // 字符串型 port
        'id': 'u2',
        'net': 'grpc',
        'path': 'GunSrv',
        'tls': 'tls',
      });
      final o = Base64Provider.provide(encodeSub([link])).first;
      expect(o.serverPort, 443);
      expect(o.transport?.type, OutboundTransportType.gRPC);
      expect(o.transport?.serviceName, 'GunSrv');
      expect(o.tls?.enabled, isTrue);
    });

    test('URL-safe base64 无 padding 的链接可解析', () {
      final json = {
        'v': '2',
        'ps': 'us',
        'add': 'd.com',
        'port': 443,
        'id': 'u3',
        'net': 'tcp',
      };
      final std = base64.encode(utf8.encode(jsonEncode(json)));
      final urlSafe = std.replaceAll('+', '-').replaceAll('/', '_').replaceAll('=', '');
      final o = Base64Provider.provide(encodeSub(['vmess://$urlSafe'])).first;
      expect(o.tag, 'us');
      expect(o.server, 'd.com');
    });

    test('kcp 传输（sing-box 不支持）整行跳过', () {
      final link = vmessLink({
        'v': '2',
        'ps': 'kcp-node',
        'add': 'e.com',
        'port': 443,
        'id': 'u4',
        'net': 'kcp',
      });
      final outbounds = Base64Provider.provide(encodeSub([link]));
      expect(outbounds, isEmpty);
    });

    test('旧字段名 security 与 allowInsecure 兼容', () {
      final link = vmessLink({
        'v': '2',
        'ps': 'legacy',
        'add': 'f.com',
        'port': 443,
        'id': 'u5',
        'security': 'aes-128-gcm',
        'net': 'ws',
        'tls': 'tls',
        'allowInsecure': '1',
      });
      final o = Base64Provider.provide(encodeSub([link])).first;
      expect(o.security, 'aes-128-gcm');
      expect(o.tls?.insecure, isTrue);
    });

    test('sni 与 host 均缺省时 serverName 回退 add', () {
      final link = vmessLink({
        'v': '2',
        'ps': 'nosni',
        'add': 'nosni.com',
        'port': 443,
        'id': 'u6',
        'net': 'tcp',
        'tls': 'tls',
      });
      final o = Base64Provider.provide(encodeSub([link])).first;
      expect(o.tls?.serverName, 'nosni.com');
      expect(o.tls?.disableSni, isFalse);
    });
  });

  group('Base64Provider.provide - hysteria2 mport 端口跳跃', () {
    test('官方示例格式：范围与单端口逗号混用', () {
      const link = 'hysteria2://pwd@hy2.com:443?sni=hy2.com&mport=20000-30000,443#hy2';
      final o = Base64Provider.provide(encodeSub([link])).first;
      expect(o.serverPorts, ['20000:30000', '443:443']);
    });

    test('单个端口范围（既有行为不回归）', () {
      const link = 'hysteria2://pwd@hy2r.com:443?sni=hy2r.com&mport=20000-30000#hy2r';
      final o = Base64Provider.provide(encodeSub([link])).first;
      expect(o.serverPorts, ['20000:30000']);
    });

    test('单个端口号转为 start:end（sing-box 拒绝纯数字）', () {
      const link = 'hysteria2://pwd@hy2s.com:443?sni=hy2s.com&mport=443#hy2s';
      final o = Base64Provider.provide(encodeSub([link])).first;
      expect(o.serverPorts, ['443:443']);
    });

    test('无 mport 时 server_ports 为 null（既有行为不回归）', () {
      const link = 'hysteria2://pwd@hy2n.com:443?sni=hy2n.com#hy2n';
      final o = Base64Provider.provide(encodeSub([link])).first;
      expect(o.serverPorts, isNull);
    });

    test('无 sni 时回退 host 作 serverName', () {
      const link = 'hysteria2://pwd@hy2f.com:443#hy2f';
      final o = Base64Provider.provide(encodeSub([link])).first;
      expect(o.tls?.serverName, 'hy2f.com');
      expect(o.tls?.disableSni, isFalse);
    });

    test('sni 显式空串时不发送 SNI', () {
      const link = 'hysteria2://pwd@hy2e.com:443?sni=#hy2e';
      final o = Base64Provider.provide(encodeSub([link])).first;
      expect(o.tls?.serverName, '');
      expect(o.tls?.disableSni, isTrue);
    });
  });

  group('Base64Provider.provide - hysteria mport 端口跳跃', () {
    test('范围与单端口逗号混用', () {
      const link =
          'hysteria://auth@hy1.com:443?peer=hy1.com&upmbps=100&downmbps=1000&mport=200-300,443#hy1';
      final o = Base64Provider.provide(encodeSub([link])).first;
      expect(o.serverPorts, ['200:300', '443:443']);
    });

    test('无 mport 时节点不丢弃，server_ports 为 null', () {
      const link = 'hysteria://auth@hy1n.com:443?peer=hy1n.com&upmbps=100&downmbps=1000#hy1n';
      final outbounds = Base64Provider.provide(encodeSub([link]));
      expect(outbounds, hasLength(1));
      expect(outbounds.first.serverPorts, isNull);
    });
  });

  group('Base64Provider.provide - trojan sni/insecure', () {
    test('sni 参数生效（v2rayN 标准），insecure=1 跳过证书校验', () {
      const link = 'trojan://pwd@1.2.3.4:443?sni=cdn.example.com&insecure=1#t';
      final o = Base64Provider.provide(encodeSub([link])).first;
      expect(o.type, OutboundType.trojan);
      expect(o.tls?.serverName, 'cdn.example.com');
      expect(o.tls?.disableSni, isFalse);
      expect(o.tls?.insecure, isTrue);
    });

    test('无 sni 时回退 host 作 serverName', () {
      const link = 'trojan://pwd@t.com:443#t2';
      final o = Base64Provider.provide(encodeSub([link])).first;
      expect(o.tls?.serverName, 't.com');
      expect(o.tls?.disableSni, isFalse);
    });

    test('peer 参数兼容（trojan-go / Shadowrocket 旧写法）', () {
      const link = 'trojan://pwd@1.2.3.4:443?peer=p.com#t3';
      final o = Base64Provider.provide(encodeSub([link])).first;
      expect(o.tls?.serverName, 'p.com');
    });

    test('allowInsecure=1 亦生效', () {
      const link = 'trojan://pwd@t4.com:443?allowInsecure=1#t4';
      final o = Base64Provider.provide(encodeSub([link])).first;
      expect(o.tls?.insecure, isTrue);
    });
  });

  group('Base64Provider.provide - anytls sni/insecure', () {
    test('官方格式：sni 与 insecure 均生效', () {
      const link = 'anytls://pwd@a.com:443?sni=real.example.com&insecure=1#at';
      final o = Base64Provider.provide(encodeSub([link])).first;
      expect(o.type, OutboundType.anytls);
      expect(o.tls?.serverName, 'real.example.com');
      expect(o.tls?.disableSni, isFalse);
      expect(o.tls?.insecure, isTrue);
    });

    test('无 sni 时回退 host 作 serverName', () {
      const link = 'anytls://pwd@b.com:443#at2';
      final o = Base64Provider.provide(encodeSub([link])).first;
      expect(o.tls?.serverName, 'b.com');
      expect(o.tls?.disableSni, isFalse);
    });
  });

  group('Base64Provider.provide - hysteria sni/insecure', () {
    test('peer 为官方主参数名，insecure=1 生效', () {
      const link =
          'hysteria://auth@hy.com:443?peer=hy.example.com&insecure=1&upmbps=100&downmbps=1000#h';
      final o = Base64Provider.provide(encodeSub([link])).first;
      expect(o.tls?.serverName, 'hy.example.com');
      expect(o.tls?.disableSni, isFalse);
      expect(o.tls?.insecure, isTrue);
    });

    test('无 peer 时先兼容 sni，再回退 host', () {
      const link1 = 'hysteria://auth@h1.com:443?sni=s1.com&upmbps=100&downmbps=1000#h1';
      final o1 = Base64Provider.provide(encodeSub([link1])).first;
      expect(o1.tls?.serverName, 's1.com');

      const link2 = 'hysteria://auth@h2.com:443?upmbps=100&downmbps=1000#h2';
      final o2 = Base64Provider.provide(encodeSub([link2])).first;
      expect(o2.tls?.serverName, 'h2.com');
      expect(o2.tls?.disableSni, isFalse);
    });
  });

  group('Base64Provider.provide - hysteria/hysteria2 alpn', () {
    test('hysteria 多值 alpn 逗号拆分（官方 URI 规范）', () {
      const link =
          'hysteria://auth@hy.com:443?peer=hy.com&alpn=h3,hysteria&upmbps=100&downmbps=1000#h';
      final o = Base64Provider.provide(encodeSub([link])).first;
      expect(o.tls?.alpn, ['h3', 'hysteria']);
    });

    test('hysteria alpn 空段被过滤', () {
      const link =
          'hysteria://auth@hye.com:443?peer=hye.com&alpn=h3,,&upmbps=100&downmbps=1000#hye';
      final o = Base64Provider.provide(encodeSub([link])).first;
      expect(o.tls?.alpn, ['h3']);
    });

    test('hysteria 无 alpn 默认 hysteria（v1 协议要求，对齐 mihomo）', () {
      const link =
          'hysteria://auth@hyn.com:443?peer=hyn.com&upmbps=100&downmbps=1000#hyn';
      final o = Base64Provider.provide(encodeSub([link])).first;
      expect(o.tls?.alpn, ['hysteria']);
    });

    test('hysteria2 多值 alpn 逗号拆分', () {
      const link = 'hysteria2://pwd@hy2.com:443?sni=hy2.com&alpn=h3,hysteria#hy2';
      final o = Base64Provider.provide(encodeSub([link])).first;
      expect(o.tls?.alpn, ['h3', 'hysteria']);
    });

    test('hysteria2 alpn 空段被过滤', () {
      const link = 'hysteria2://pwd@hy2e.com:443?sni=hy2e.com&alpn=,h3,#hy2e';
      final o = Base64Provider.provide(encodeSub([link])).first;
      expect(o.tls?.alpn, ['h3']);
    });

    test('hysteria2 无 alpn 默认 h3（既有行为不回归）', () {
      const link = 'hysteria2://pwd@hy2n.com:443?sni=hy2n.com#hy2n';
      final o = Base64Provider.provide(encodeSub([link])).first;
      expect(o.tls?.alpn, ['h3']);
    });
  });
}
