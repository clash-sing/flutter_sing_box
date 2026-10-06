// test/tool/names_test.dart
import 'package:flutter_test/flutter_test.dart';
import '../../tool/src/names.dart';

void main() {
  group('命名转换', () {
    test('snake_case 转 lowerCamelCase', () {
      expect(lowerCamel('server_port'), 'serverPort');
      expect(lowerCamel('tcp_fast_open'), 'tcpFastOpen');
      expect(lowerCamel('tag'), 'tag');
    });

    test('类型串转出站类名', () {
      expect(classNameForOutbound('hysteria2'), 'Hysteria2Outbound');
      expect(classNameForOutbound('urltest'), 'UrltestOutbound');
      expect(classNameForOutbound('anytls'), 'AnytlsOutbound');
      expect(classNameForOutbound('shadowtls'), 'ShadowtlsOutbound');
      expect(classNameForOutbound('snell'), 'SnellOutbound');
    });

    test('类型串转入站类名', () {
      expect(classNameForInbound('tun'), 'TunInbound');
      expect(classNameForInbound('mixed'), 'MixedInbound');
    });

    test('类名转文件名', () {
      expect(fileNameFor('Hysteria2Outbound'), 'hysteria2_outbound.dart');
      expect(fileNameFor('OutboundTLSOptions'), 'outbound_tls_options.dart');
    });

    test('白名单与常量表一致', () {
      // OutboundType 常量表全集（17 项，见 Global Constraints）
      expect(outboundWhitelist, containsAll(<String>[
        'direct', 'selector', 'urltest', 'block',
        'hysteria2', 'hysteria', 'anytls', 'trojan', 'vmess', 'vless',
        'shadowsocks', 'tuic', 'naive', 'socks', 'http', 'shadowtls', 'snell',
      ]));
      expect(outboundWhitelist.length, 17);
      expect(inboundWhitelist, ['tun', 'mixed']);
    });
  });
}
