// test/tool/dart_emitter_test.dart —— Dart 输出器测试（迷你 fixture 全链路：IR -> 源码文本）
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../../tool/src/schema_ir.dart';
import '../../tool/src/dart_emitter.dart';

Ir fixtureIr() => buildIr(
  jsonDecode(File('test/tool/fixtures/mini_schema.json').readAsStringSync())
      as Map<String, dynamic>,
  outboundWhitelist: {'hysteria2', 'snell', 'urltest'},
  inboundWhitelist: {},
);

void main() {
  late Map<String, String> files;

  setUpAll(() => files = emitDart(fixtureIr()));

  test('产出文件清单完整', () {
    expect(
      files.keys,
      containsAll([
        'sing_box.dart',
        'outbound/outbound.dart',
        'outbound/hysteria2_outbound.dart',
        'outbound/snell_outbound.dart',
        'outbound/unknown_outbound.dart',
        'shared/dialer_fields.dart',
        'rule.dart',
        'log_options.dart',
        'index.dart',
        // DNSServer 第三判别族（IR 中 kind='plain' + typeName 非 null 的类）
        'dns_server/dns_server.dart',
        'dns_server/local_dns_server.dart',
        'dns_server/unknown_dns_server.dart',
      ]),
    );
    // index 只导出库根：判别族子类是 part 文件（part 不可被 export），随库根一并导出
    final index = files['index.dart']!;
    expect(index, contains("export 'outbound/outbound.dart';"));
    expect(
      index,
      isNot(contains("export 'outbound/hysteria2_outbound.dart';")),
    );
  });

  test('sealed 基类含判别工厂与类型注册表', () {
    final outbound = files['outbound/outbound.dart']!;
    expect(outbound, contains('sealed class Outbound'));
    expect(outbound, contains('factory Outbound.fromJson'));
    expect(
      outbound,
      contains("'hysteria2' => Hysteria2Outbound.fromJson(json)"),
    );
    expect(outbound, contains('_ => UnknownOutbound.fromJson(json)'));
    expect(outbound, contains('kOutboundTypeNames'));
    // sealed 子类必须同库：库根声明全部 part，生成物 part 收口在库根的 .g.dart
    expect(outbound, contains("part 'hysteria2_outbound.dart';"));
    expect(outbound, contains("part 'unknown_outbound.dart';"));
    expect(outbound, contains("part 'outbound.g.dart';"));
    // 基类声明抽象 toJson：List<Outbound> 等字段才能被 json_serializable 序列化
    expect(outbound, contains('Map<String, dynamic> toJson();'));
  });

  test('子类结构：typeName / type getter / mixin', () {
    final h2 = files['outbound/hysteria2_outbound.dart']!;
    expect(h2, contains("static const typeName = 'hysteria2'"));
    expect(h2, contains('String get type => typeName'));
    expect(h2, contains('extends Outbound with DialerFields'));
    // 同库 part 文件（sealed 同库限制）；toJson 覆写回写 type 判别键保 round-trip
    expect(h2, contains("part of 'outbound.dart';"));
    expect(
      h2,
      contains("{'type': typeName, ..._\$Hysteria2OutboundToJson(this)}"),
    );
  });

  test('mixin 无 JsonSerializable 注解且字段可空', () {
    final dialer = files['shared/dialer_fields.dart']!;
    expect(dialer, contains('mixin DialerFields'));
    expect(dialer, isNot(contains('@JsonSerializable')));
    expect(dialer, contains('Object? routingMark'));
    // 裁决修正：原「子类结构」第 4 断言移入此处（connect_timeout/routing_mark 在 mixin）
    expect(dialer, contains("@JsonKey(name: 'routing_mark')"));
  });

  test('DNSServer 判别族与 Outbound 同构', () {
    final base = files['dns_server/dns_server.dart']!;
    expect(base, contains('sealed class DNSServer'));
    expect(base, contains('factory DNSServer.fromJson'));
    expect(base, contains("'local' => LocalDNSServer.fromJson(json)"));
    expect(base, contains('_ => UnknownDnsServer.fromJson(json)'));
    final local = files['dns_server/local_dns_server.dart']!;
    expect(local, contains("static const typeName = 'local'"));
    expect(local, contains('extends DNSServer'));
  });

  test('SingBox 透传 unknownSections', () {
    final sb = files['sing_box.dart']!;
    expect(sb, contains('unknownSections'));
    expect(sb, contains('_knownKeys'));
    expect(sb, contains('includeFromJson: false'));
  });

  test('snell 合并类含 version 必填与 v4/v6 字段', () {
    final snell = files['outbound/snell_outbound.dart']!;
    expect(snell, contains('int version'));
    expect(snell, contains('String? obfsMode'));
    expect(snell, contains('String? mode'));
  });

  test('Rule 拍平类字段并集', () {
    expect(files['rule.dart'], contains('String? outbound'));
    expect(files['rule.dart'], contains('String? protocol'));
    expect(files['rule.dart'], contains('String? action'));
  });

  test('全部文件带勿手改头注释', () {
    for (final content in files.values) {
      expect(content, startsWith('// 本文件由 tool/gen_models.dart 生成，勿手改。'));
    }
  });
}
