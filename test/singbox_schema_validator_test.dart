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

  group('diagnoseCombinatorError 二次诊断', () {
    // 模板配置 outbounds 为空，此处塞入带 Clash 残留 network 字段的 anytls
    // 节点——正是线上订阅报 41 处 matched 0 的实战场景
    Map<String, dynamic> brokenWithAnytls() {
      final broken =
          jsonDecode(jsonEncode(templateConfig)) as Map<String, dynamic>;
      (broken['outbounds'] as List).add({
        'tag': 'test-anytls',
        'type': 'anytls',
        'server': 'example.com',
        'server_port': 443,
        'password': 'x',
        'tls': {'enabled': true},
        'network': ['tcp', 'udp'],
      });
      return broken;
    }

    test('已知 type 但字段非法：展开该分支复核出的字段级错误', () {
      final broken = brokenWithAnytls();

      final errors = validator.validateSync(broken);
      final oneOfError = errors.firstWhere(
        (e) => e.error == ValidationErrorType.oneOfNotMet,
      );

      final lines = validator.diagnoseCombinatorError(broken, oneOfError);
      final text = lines.join('\n');

      expect(text, contains('type="anytls"'));
      expect(text, contains('network'));
      // 子错误路径拼接回原位置，而非分支内的相对路径
      expect(text, contains('["outbounds"]["0"]["network"]'));
    });

    test('未知 type：提示不在本版 schema 支持的类型中', () {
      final broken =
          jsonDecode(jsonEncode(templateConfig)) as Map<String, dynamic>;
      (broken['outbounds'] as List).add({
        'tag': 'test-unknown',
        'type': 'not-a-real-protocol',
        'server': 'example.com',
        'server_port': 443,
      });

      final errors = validator.validateSync(broken);
      final oneOfError = errors.firstWhere(
        (e) => e.error == ValidationErrorType.oneOfNotMet,
      );

      final text = validator
          .diagnoseCombinatorError(broken, oneOfError)
          .join('\n');

      expect(text, contains('not-a-real-protocol'));
      expect(text, contains('不在本版 schema 支持'));
    });

    test('非 oneOf/anyOf 错误：返回空诊断', () {
      final broken =
          jsonDecode(jsonEncode(templateConfig)) as Map<String, dynamic>;
      broken['not_a_real_field'] = 1;

      final errors = validator.validateSync(broken);

      expect(errors, isNotEmpty, reason: _format(errors));
      for (final error in errors) {
        expect(
          validator.diagnoseCombinatorError(broken, error),
          isEmpty,
          reason: error.toErrorString(),
        );
      }
    });
  });

  group('diagnoseCombinatorError 嵌套展开与逐分支兜底', () {
    // 合成 schema：依赖真实 470KB schema 结构的断言会随上游版本漂移，
    // 逻辑行为用最小合成 schema 锁定；实战场景另见下方真实 schema 集成用例
    final syntheticSchema = {
      r'$id': 'https://example.test/root',
      r'$defs': {
        'item': {
          'oneOf': [
            {
              'type': 'object',
              'properties': {
                'type': {'const': 'a'},
                // 与真实 schema 的 certificate_sha256 同形：无 type 判别的 anyOf
                'v': {
                  'anyOf': [
                    {'type': 'string'},
                    {'type': 'integer'},
                  ],
                },
              },
              'required': ['type', 'v'],
              'additionalProperties': false,
            },
            {
              'type': 'object',
              'properties': {
                'type': {'const': 'b'},
              },
              'required': ['type'],
              'additionalProperties': false,
            },
          ],
        },
      },
      'type': 'object',
      'properties': {
        'items': {
          'type': 'array',
          'items': {r'$ref': r'#/$defs/item'},
        },
      },
    };

    late final SingBoxSchemaValidator syntheticValidator;

    setUpAll(() {
      syntheticValidator = SingBoxSchemaValidator.fromMap(syntheticSchema);
    });

    test('分支内嵌套 anyOf 错误递归展开，逐分支兜底给出字段级原因', () {
      final config = {
        'items': [
          {'type': 'a', 'v': true},
        ],
      };
      final errors = syntheticValidator.validateSync(config);
      final oneOfError = errors.firstWhere(
        (e) => e.error == ValidationErrorType.oneOfNotMet,
      );

      final text = syntheticValidator
          .diagnoseCombinatorError(config, oneOfError)
          .join('\n');

      // 嵌套错误路径拼回原位置，而非分支内相对路径
      expect(text, contains('["items"]["0"]["v"]'));
      // 无 type 判别字段的 anyOf 走逐分支兜底，而非「无法选择分支」躺平
      expect(text, contains('逐分支复核'));
      // 每个分支给出具体失败原因（实际值与期望类型）
      expect(text, contains('`true`'));
      expect(text, contains('`string`'));
      expect(text, contains('`integer`'));
    });

    // 回归保护：本次改动调整了「未知 type」的判定条件（仅当分支带 type
    // const 时才报支持类型列表），此用例锁定该行为不被误伤
    test('分支有 type 判别时，未知 type 仍提示支持类型列表', () {
      final config = {
        'items': [
          {'type': 'zzz', 'v': 'x'},
        ],
      };
      final errors = syntheticValidator.validateSync(config);
      final oneOfError = errors.firstWhere(
        (e) => e.error == ValidationErrorType.oneOfNotMet,
      );

      final text = syntheticValidator
          .diagnoseCombinatorError(config, oneOfError)
          .join('\n');

      expect(text, contains('zzz'));
      expect(text, contains('不在本版 schema 支持'));
      expect(text, isNot(contains('逐分支复核')));
    });

    test('嵌套深度超上限时安全截断，不抛异常', () {
      // 5 层单分支 oneOf 链，最内层叶字段非法；展开深度上限应拦住递归
      Map<String, dynamic> leafBranch() => {
        'type': 'object',
        'properties': {
          'type': {'const': 'n'},
          'leaf': {
            'anyOf': [
              {'type': 'string'},
              {'type': 'integer'},
            ],
          },
        },
        'required': ['type', 'leaf'],
        'additionalProperties': false,
      };
      final defs = <String, dynamic>{};
      for (var i = 1; i <= 5; i++) {
        defs['d$i'] = {
          'oneOf': [
            if (i < 5)
              {
                'type': 'object',
                'properties': {
                  'type': {'const': 'n'},
                  'next': {r'$ref': '#/\$defs/d${i + 1}'},
                },
                'required': ['type', 'next'],
                'additionalProperties': false,
              }
            else
              leafBranch(),
          ],
        };
      }
      final deepConfig = {
        'root': {
          'type': 'n',
          'next': {
            'type': 'n',
            'next': {
              'type': 'n',
              'next': {
                'type': 'n',
                'next': {'type': 'n', 'leaf': true},
              },
            },
          },
        },
      };
      final deep = SingBoxSchemaValidator.fromMap({
        r'$id': 'https://example.test/deep',
        r'$defs': defs,
        'type': 'object',
        'properties': {
          'root': {r'$ref': r'#/$defs/d1'},
        },
      });

      final errors = deep.validateSync(deepConfig);
      final oneOfError = errors.firstWhere(
        (e) => e.error == ValidationErrorType.oneOfNotMet,
      );

      final lines = deep.diagnoseCombinatorError(deepConfig, oneOfError);

      expect(lines, isNotEmpty);
      // 「，展开:」标记出现次数不超过深度上限，防止深嵌套递归刷屏
      final expandCount = lines.where((l) => l.contains('，展开:')).length;
      expect(expandCount, lessThanOrEqualTo(3));
    });

    // 集成用例：真实 schema 实战场景——tls.certificate_sha256 填了非法
    // 类型（该字段为 string/byte 数组二选一的 anyOf，无 type 判别）
    test('真实 schema：anytls 的 tls.certificate_sha256 类型错误展开原因', () {
      final broken =
          jsonDecode(jsonEncode(templateConfig)) as Map<String, dynamic>;
      (broken['outbounds'] as List).add({
        'tag': 'test-anytls',
        'type': 'anytls',
        'server': 'example.com',
        'server_port': 443,
        'password': 'x',
        'tls': {'enabled': true, 'certificate_sha256': 12345},
      });

      final errors = validator.validateSync(broken);
      final oneOfError = errors.firstWhere(
        (e) => e.error == ValidationErrorType.oneOfNotMet,
      );

      final text = validator
          .diagnoseCombinatorError(broken, oneOfError)
          .join('\n');

      expect(text, contains('["outbounds"]["0"]["tls"]["certificate_sha256"]'));
      expect(text, contains('逐分支复核'));
      expect(text, contains('`12345`'));
    });
  });
}

/// 把错误列表拼成可读文本，供断言失败时输出
String _format(List<ValidationError> errors) =>
    errors.map((e) => e.toErrorString()).join('\n');
