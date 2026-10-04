import 'dart:convert';
import 'dart:io';

import 'package:flutter_sing_box/flutter_sing_box.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late final SingBoxSchemaValidator validator;
  late final Map<String, dynamic> templateConfig;

  setUpAll(() {
    // 真实 schema 约 470KB，解析开销大，全部用例共享一次构建
    final schemaMap = jsonDecode(
      File('assets/schemas/singbox_schema.json').readAsStringSync(),
    ) as Map<String, dynamic>;
    validator = SingBoxSchemaValidator.fromMap(schemaMap);
    templateConfig = jsonDecode(
      File('assets/configs/singbox_config_template.json').readAsStringSync(),
    ) as Map<String, dynamic>;
  });

  group('SingBoxSchemaValidator', () {
    test('instance() 注入文件 loader 构建成功，行为与 fromMap 一致', () async {
      SingBoxSchemaValidator.resetCache();
      final validator = await SingBoxSchemaValidator.instance(
        // 忽略传入的 asset 路径，直接读本地 schema 文件（纯 dart 测试无 asset bundle）
        assetLoader: (assetPath) {
          expect(assetPath, contains('singbox_schema.json'));
          return File('assets/schemas/singbox_schema.json').readAsString();
        },
      );

      final errors = validator.validateSync(templateConfig);

      expect(errors, isEmpty, reason: _format(errors));
    });

    test('完整加载真实 schema 并接受合法模板配置（outbounds 为空也通过：只查结构不查语义）', () {
      final errors = validator.validateSync(templateConfig);

      expect(errors, isEmpty, reason: _format(errors));
    });

    test('inbound type 非法时报错，且错误定位到 inbounds/0', () {
      final broken =
          jsonDecode(jsonEncode(templateConfig)) as Map<String, dynamic>;
      (broken['inbounds'] as List).first['type'] = 'not-a-real-type';

      final errors = validator.validateSync(broken);

      expect(errors, isNotEmpty, reason: _format(errors));
      expect(
        errors.any((e) => e.path.length >= 2 && e.path[1] == '0'),
        isTrue,
        reason: _format(errors),
      );
    });
  });
}

/// 把错误列表拼成可读文本，供断言失败时输出
String _format(List<ValidationError> errors) =>
    errors.map((e) => e.toErrorString()).join('\n');
