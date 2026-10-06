// test/tool/schema_ir_test.dart —— schema 解析为 IR 的规则测试（全部走迷你 fixture）
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../../tool/src/schema_ir.dart';

Ir buildFixtureIr() {
  final raw = File('test/tool/fixtures/mini_schema.json').readAsStringSync();
  return buildIr(
    jsonDecode(raw) as Map<String, dynamic>,
    outboundWhitelist: {'hysteria2', 'snell', 'urltest'},
    inboundWhitelist: {},
  );
}

void main() {
  test('判别类生成：白名单内类型各成一个 ClassSpec', () {
    final ir = buildFixtureIr();
    final names = ir.classes.map((c) => c.className).toList();
    expect(names, containsAll(['Hysteria2Outbound', 'SnellOutbound', 'UrltestOutbound']));
    expect(names, isNot(contains('WireguardOutbound'))); // 白名单外跳过
  });

  test('嵌套 oneOf 展开 + 同判别合并：snell 单类，字段并集 required 交集', () {
    final ir = buildFixtureIr();
    final snell = ir.classes.singleWhere((c) => c.className == 'SnellOutbound');
    final fieldNames = snell.ownFields.map((f) => f.jsonName).toList();
    expect(fieldNames, containsAll(['tag', 'version', 'psk', 'obfs_mode', 'mode']));
    final version = snell.ownFields.singleWhere((f) => f.jsonName == 'version');
    expect(version.dartType, 'int'); // const 标量 -> int
    expect(version.required, isTrue); // 两分支 required 交集
    final obfs = snell.ownFields.singleWhere((f) => f.jsonName == 'obfs_mode');
    expect(obfs.required, isFalse); // 并集后非公共字段
  });

  test(r'$ref 递归可达：OutboundTLSOptions 被收集', () {
    final ir = buildFixtureIr();
    final tls = ir.classes.singleWhere((c) => c.className == 'OutboundTLSOptions');
    expect(tls.kind, 'plain');
    expect(tls.ownFields.map((f) => f.dartName), containsAll(['enabled', 'serverName']));
  });

  test('Duration 映射为 String，anyOf 二义映射为 Object', () {
    final ir = buildFixtureIr();
    // connect_timeout 已被 DialerFields 吸收（规则 9），Duration 映射在 mixin 中断言
    final dialer = ir.mixins['DialerFields']!;
    final timeout = dialer.singleWhere((f) => f.jsonName == 'connect_timeout');
    expect(timeout.dartType, 'String?');
    final mark = dialer.singleWhere((f) => f.jsonName == 'routing_mark');
    expect(mark.dartType, 'Object?'); // mixin 字段一律可空
  });

  test('共享块提取：DialerFields 吸收分支内重复拨号字段', () {
    final ir = buildFixtureIr();
    final h2 = ir.classes.singleWhere((c) => c.className == 'Hysteria2Outbound');
    expect(h2.mixins, contains('DialerFields'));
    // detour/connect_timeout 已进 mixin，本类字段不再含
    expect(h2.ownFields.map((f) => f.jsonName), isNot(contains('detour')));
  });

  test('required 决定可空性', () {
    final ir = buildFixtureIr();
    final h2 = ir.classes.singleWhere((c) => c.className == 'Hysteria2Outbound');
    expect(h2.ownFields.singleWhere((f) => f.jsonName == 'server').dartType, 'String');
    expect(h2.ownFields.singleWhere((f) => f.jsonName == 'tls').dartType, 'OutboundTLSOptions?');
  });

  test('白名单类型在 schema 中缺失时报错', () {
    final raw = File('test/tool/fixtures/mini_schema.json').readAsStringSync();
    expect(
      () => buildIr(jsonDecode(raw) as Map<String, dynamic>,
          outboundWhitelist: {'hysteria2', 'trojan'}, inboundWhitelist: {}),
      throwsA(isA<SchemaConflictException>().having(
          (e) => e.message, 'message', contains('trojan'))),
    );
  });

  test('无判别 oneOf 拍平（Rule 形状）', () {
    final ir = buildFixtureIr();
    // 两分支均无 type const、allOf 包裹字段 -> 拍平为单个 plain 类
    final rule = ir.classes.singleWhere((c) => c.className == 'Rule');
    expect(rule.kind, 'plain');
    expect(rule.typeName, isNull);
    expect(rule.ownFields.map((f) => f.jsonName),
        containsAll(['outbound', 'network', 'protocol', 'action']));
  });
}
