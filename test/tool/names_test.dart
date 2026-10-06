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

    test('保留字字段名加下划线避让（原名走 @JsonKey 保真）', () {
      // schema 的 JSON 键可能是 Dart 保留字/内建标识符（DNS 的 final、
      // selector 的 default 等），直接作字段名是语法错误，须加下划线后缀
      expect(safeFieldName('final'), 'final_');
      expect(safeFieldName('default'), 'default_');
      expect(safeFieldName('in'), 'in_');
      // PascalCase 键先降首字母小写再查关键字：'Final' 降成 'final' 后
      // 撞保留字，须加下划线（降小写在关键字检查之前，反了会漏检）
      expect(safeFieldName('Final'), 'final_');
      // schema 原生 PascalCase 键（User 的 Username/Password）降为小写开头，
      // 否则触发 non_constant_identifier_names
      expect(safeFieldName('Username'), 'username');
      expect(safeFieldName('Password'), 'password');
      // 普通键不受影响
      expect(safeFieldName('server_port'), 'serverPort');
      expect(safeFieldName('tag'), 'tag');
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
