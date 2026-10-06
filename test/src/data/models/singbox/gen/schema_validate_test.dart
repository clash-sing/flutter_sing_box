// schema 反向校验闭环测试：生成物 toJson 的输出必须仍被官方 schema 接受。
// 这是「schema -> tool 生成物 -> JSON」闭环的回归闸门——生成器若把字段名/
// 类型/判别处理错，round-trip 输出会与 schema 失配，在此被拦截。
//
// 注意：fixture 本身先在此校验合法（round-trip 测试的口径前提），生成物
// 输出的校验才可归因于生成物而非 fixture。
import 'dart:convert';
import 'dart:io';

import 'package:flutter_sing_box/src/data/models/singbox/gen/index.dart';
import 'package:flutter_sing_box/src/data/models/singbox/schema_validator.dart';
import 'package:flutter_test/flutter_test.dart';

Map<String, dynamic> deepCopy(Map<String, dynamic> source) =>
    jsonDecode(jsonEncode(source)) as Map<String, dynamic>;

void main() {
  late final Map<String, dynamic> userConfig;
  late final SingBoxSchemaValidator validator;

  setUpAll(() async {
    userConfig = jsonDecode(
      File('test/src/data/models/singbox/gen/fixtures/user_config.json')
          .readAsStringSync(),
    ) as Map<String, dynamic>;
    // 纯 dart 测试无 asset bundle，注入文件读取；忽略传入的 asset 路径
    validator = await SingBoxSchemaValidator.instance(
      assetLoader: (assetPath) =>
          File('assets/schemas/singbox_schema.json').readAsString(),
    );
  });

  String reasonOf(List<ValidationError> errors) =>
      errors.take(5).map((e) => e.toErrorString()).join('\n');

  group('schema 反向校验闭环', () {
    test('fixture 本身通过官方 schema 校验（round-trip 测试的口径前提）', () {
      final errors = validator.validateSync(deepCopy(userConfig));
      expect(errors, isEmpty, reason: reasonOf(errors));
    });

    test('round-trip 输出通过官方 schema 校验', () {
      final out = SingBox.fromJson(deepCopy(userConfig)).toJson();
      final errors = validator.validateSync(out);
      expect(errors, isEmpty, reason: reasonOf(errors));
    });

    test('构建典型配置（direct+selector+urltest+hysteria2 出站 + tun/mixed 入站 + DNS + Route）通过校验', () {
      // 用生成类手工构建 sing_box_config_provider 等价的典型配置，
      // 同时预演阶段二的构建侧用法
      final sb = SingBox(
        log: LogOptions()
          ..level = 'info'
          ..timestamp = true,
        dns: DNS()
          ..servers = [
            LocalDNSServer(tag: 'local'),
            UdpDNSServer(tag: 'remote')
              ..server = '8.8.8.8'
              ..serverPort = 53,
          ]
          ..final_ = 'remote',
        inbounds: [
          TunInbound(tag: 'tun-in')
            ..address = ['172.19.0.1/30']
            ..autoRoute = true,
          MixedInbound(tag: 'mixed-in')
            ..listen = '127.0.0.1'
            ..listenPort = 8890,
        ],
        outbounds: [
          SelectorOutbound(tag: 'proxy')
            ..outbounds = ['auto', 'direct']
            ..default_ = 'auto',
          UrltestOutbound(tag: 'auto')
            ..outbounds = ['h2-node', 'direct']
            ..url = 'https://www.gstatic.com/generate_204'
            ..interval = '3m'
            ..tolerance = 50,
          Hysteria2Outbound(tag: 'h2-node')
            ..server = 'a.cn'
            ..serverPort = 443
            ..password = 'pw'
            ..tls = (OutboundTLSOptions()
              ..enabled = true
              ..serverName = 'a.cn'),
          DirectOutbound(tag: 'direct'),
        ],
        route: RouteOptions()
          ..rules = [
            Rule()
              ..protocol = 'dns'
              ..action = 'hijack-dns',
            Rule()
              ..ipIsPrivate = true
              ..action = 'route'
              ..outbound = 'direct',
          ]
          ..final_ = 'proxy'
          ..autoDetectInterface = true,
      );

      final errors = validator.validateSync(sb.toJson());
      expect(errors, isEmpty, reason: reasonOf(errors));
    });
  });
}
