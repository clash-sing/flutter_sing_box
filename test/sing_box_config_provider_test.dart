import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart' show debugPrint;
import 'package:flutter_sing_box/flutter_sing_box.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late final Map<String, dynamic> templateMap;

  setUpAll(() async {
    SingBoxSchemaValidator.resetCache();
    // 预热实例缓存：注入文件读取，避免纯 dart 测试走 rootBundle
    await SingBoxSchemaValidator.instance(
      assetLoader: (_) =>
          File('assets/schemas/singbox_schema.json').readAsString(),
    );
    templateMap = jsonDecode(
      File('assets/configs/singbox_config_template.json').readAsStringSync(),
    ) as Map<String, dynamic>;
  });

  group('SingBoxConfigProvider.validateOrLog', () {
    test('校验器故障时不冒泡（fail-open，绝不阻断导入）', () async {
      final singBox = SingBox.fromJson(templateMap);

      // 不抛异常即通过：校验器自身故障必须被吞掉
      await SingBoxConfigProvider.validateOrLog(
        singBox,
        validatorSource: () => throw Exception('asset 加载失败'),
      );
    });

    test('发现校验错误也放行（只记日志不抛异常）', () async {
      final broken = SingBox.fromJson(templateMap);
      broken.inbounds.first.type = 'not-a-real-type';

      // 不抛异常即通过：结构非法的配置只记日志，导入流程继续
      await SingBoxConfigProvider.validateOrLog(broken);
    });

    test('oneOf 汇总错误附带二次诊断行（type 判别 + 字段级原因）', () async {
      final captured = <String>[];
      final original = debugPrint;
      debugPrint = (String? message, {int? wrapWidth}) {
        if (message != null) captured.add(message);
      };
      try {
        final broken = Map<String, dynamic>.from(templateMap);
        (broken['outbounds'] as List).add({
          'tag': 'test-anytls',
          'type': 'anytls',
          'server': 'example.com',
          'server_port': 443,
          'password': 'x',
          'tls': {'enabled': true},
          'network': ['tcp', 'udp'],
        });

        await SingBoxConfigProvider.validateOrLog(
          SingBox.fromJson(broken),
        );

        final log = captured.join('\n');
        // 汇总错误本体仍在
        expect(log, contains('matched 0'));
        // 诊断行展开到字段级，指出非法字段 network
        expect(log, contains('type="anytls"'));
        expect(log, contains('network'));
      } finally {
        debugPrint = original;
      }
    });
  });

  group('SingBoxConfigProvider.provide 集成', () {
    test('导入时执行 schema 校验，发现问题只记日志且配置原样返回', () async {
      final captured = <String>[];
      final original = debugPrint;
      debugPrint = (String? message, {int? wrapWidth}) {
        if (message != null) captured.add(message);
      };
      try {
        final broken = Map<String, dynamic>.from(templateMap);
        (broken['inbounds'] as List).first['type'] = 'not-a-real-type';

        final singBox = await SingBoxConfigProvider.provide(jsonEncode(broken));

        // 放行：对象返回且非法值原样保留
        expect(singBox.inbounds.first.type, 'not-a-real-type');
        // 校验确实发生：日志中出现校验失败记录
        expect(
          captured.any((m) => m.contains('未通过 sing-box schema 校验')),
          isTrue,
          reason: captured.join('\n'),
        );
      } finally {
        debugPrint = original;
      }
    });
  });
}
