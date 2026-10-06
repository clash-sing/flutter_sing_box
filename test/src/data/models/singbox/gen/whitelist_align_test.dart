// 白名单对齐测试：常量表（OutboundType/InboundType，消费侧使用的契约）
// 与生成注册表（kOutboundTypeNames/kInboundTypeNames，tool 白名单的产物）
// 必须一致。失配说明常量表改了没重新生成，或白名单改了没同步常量表。
import 'package:flutter_sing_box/src/constants/inbound_type.dart';
import 'package:flutter_sing_box/src/constants/outbound_type.dart';
import 'package:flutter_sing_box/src/data/models/singbox/gen/index.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('白名单对齐', () {
    test('OutboundType 常量表与生成注册表一致，失配时给出重跑指引', () {
      const expected = <String>{
        OutboundType.direct,
        OutboundType.selector,
        OutboundType.urltest,
        OutboundType.hysteria2,
        OutboundType.hysteria,
        OutboundType.anytls,
        OutboundType.trojan,
        OutboundType.vmess,
        OutboundType.vless,
        OutboundType.shadowsocks,
        OutboundType.tuic,
        OutboundType.naive,
        OutboundType.socks,
        OutboundType.http,
        OutboundType.shadowTLS,
        OutboundType.snell,
        // block 已被 sing-box 废弃但常量表与白名单均保留，仍须对齐
        // ignore: deprecated_member_use
        OutboundType.block,
      };
      expect(
        kOutboundTypeNames,
        expected,
        reason: 'OutboundType 与生成物不一致：请修改 tool/src/names.dart 白名单后'
            '运行 dart run tool/gen_models.dart 并重新 build_runner',
      );
    });

    test('InboundType 常量表与生成注册表一致，失配时给出重跑指引', () {
      const expected = <String>{InboundType.tun, InboundType.mixed};
      expect(
        kInboundTypeNames,
        expected,
        reason: 'InboundType 与生成物不一致：请修改 tool/src/names.dart 白名单后'
            '运行 dart run tool/gen_models.dart 并重新 build_runner',
      );
    });
  });
}
