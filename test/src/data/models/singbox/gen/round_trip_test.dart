// 生成物 round-trip 保真测试：fromJson -> toJson 输出必须与输入深度相等，
// 未建模内容（白名单外协议 / 未知顶层段）不得丢失或变形。
//
// fixture 先经 schema_validate_test 校验合法（测试口径：合法的用户配置
// 走一遭生成物模型后，既不丢字段、也不过校验）。
import 'dart:convert';
import 'dart:io';

import 'package:flutter_sing_box/src/data/models/singbox/gen/index.dart';
import 'package:flutter_test/flutter_test.dart';

/// 深拷贝：jsonEncode/Decode 走一遭，避免用例间共享引用。
Map<String, dynamic> deepCopy(Map<String, dynamic> source) =>
    jsonDecode(jsonEncode(source)) as Map<String, dynamic>;

void main() {
  late final Map<String, dynamic> userConfig;

  setUpAll(() {
    userConfig = jsonDecode(
      File('test/src/data/models/singbox/gen/fixtures/user_config.json')
          .readAsStringSync(),
    ) as Map<String, dynamic>;
  });

  group('round-trip 保真', () {
    test('白名单外协议（ssh）原样透传进 UnknownOutbound，未建模字段不丢', () {
      final sb = SingBox.fromJson(deepCopy(userConfig));
      final ssh = sb.outbounds.singleWhere((o) => o.type == 'ssh');
      expect(ssh, isA<UnknownOutbound>());

      final out = sb.toJson();
      final sshJson = (out['outbounds'] as List)
          .singleWhere((o) => (o as Map)['tag'] == 'ssh-node') as Map;
      expect(sshJson['server'], 'c.cn');
      expect(sshJson['user'], 'root');
      expect(sshJson['private_key'], 'AAA');
    });

    test('未知顶层段 ntp 原样透传', () {
      final out = SingBox.fromJson(deepCopy(userConfig)).toJson();
      expect(
        out['ntp'],
        {'server': 'time.apple.com', 'server_port': 123},
      );
    });

    test('snell v4 合并类正确解析', () {
      final sn = SingBox.fromJson(deepCopy(userConfig))
          .outbounds
          .singleWhere((o) => o.type == 'snell') as SnellOutbound;
      expect(sn.version, 4);
      expect(sn.psk, 'k');
      expect(sn.obfsMode, 'http');
      // v6 专属字段在 v4 配置下保持空，输出时按 includeIfNull 丢弃
      expect(sn.mode, isNull);
    });

    test('Duration 与 network 双形态字段 round-trip 不变形', () {
      final out = SingBox.fromJson(deepCopy(userConfig)).toJson();
      final h2 = (out['outbounds'] as List)
          .singleWhere((o) => (o as Map)['tag'] == 'h2-node') as Map;
      // network 在本类（Hysteria2Outbound）上为 Object?：字符串形态原样保留
      expect(h2['network'], 'tcp');
      final auto = (out['outbounds'] as List)
          .singleWhere((o) => (o as Map)['tag'] == 'auto') as Map;
      // Duration 字段是带单位的字符串，不得被解析成数字后丢单位
      expect(auto['interval'], '3m');
      expect(auto['tolerance'], 50);
    });

    test('整体 round-trip 深度相等', () {
      expect(
        SingBox.fromJson(deepCopy(userConfig)).toJson(),
        deepCopy(userConfig),
      );
    });

    test('畸形输入：缺 tag 抛类型错误', () {
      expect(
        () => Outbound.fromJson({'type': 'hysteria2'}),
        throwsA(isA<TypeError>()),
      );
    });
  });
}
