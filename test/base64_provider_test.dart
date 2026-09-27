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

    test('未知 scheme 行被跳过，不影响其他行', () {
      const lines = ['wireguard://x@y:1', 'vless://u@f.com:443?security=tls#ok'];
      final outbounds = Base64Provider.provide(encodeSub(lines));
      expect(outbounds, hasLength(1));
      expect(outbounds.first.tag, 'ok');
    });
  });
}
