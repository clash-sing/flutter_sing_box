import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart' show debugPrint;
// 旧拍平模型（SingBox 等重名导出）已不再使用，hide 后从 gen 导入
import 'package:flutter_sing_box/flutter_sing_box.dart'
    hide Inbound, Outbound, RuleSet, SingBox;
import 'package:flutter_sing_box/src/data/models/singbox/gen/index.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late final Map<String, dynamic> templateMap;

  setUpAll(() async {
    // _fixSingBoxConfig 经 rootBundle 加载内置模板；纯 dart 测试环境走
    // 'flutter/assets' 通道 mock，按 asset key 直接读插件仓库内真实文件
    // （key 形如 packages/flutter_sing_box/assets/...，映射回仓库相对路径）
    TestWidgetsFlutterBinding.ensureInitialized();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMessageHandler('flutter/assets', (ByteData? message) async {
      final key = utf8.decode(message!.buffer.asUint8List());
      final file = File(key.replaceFirst(RegExp(r'^packages/[^/]+/'), ''));
      if (!file.existsSync()) return null;
      final bytes = utf8.encode(file.readAsStringSync());
      return ByteData.view(Uint8List.fromList(bytes).buffer);
    });
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
      // 生成模型的 type 为判别字段（构造后不可变），改为先改 map 再反序列化，
      // 未知类型经 UnknownInbound 原样透传，校验仍会失败
      final brokenMap = _deepCopy(templateMap);
      (brokenMap['inbounds'] as List).first['type'] = 'not-a-real-type';
      final broken = SingBox.fromJson(brokenMap);

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
        final broken = _deepCopy(templateMap);
        (broken['outbounds'] as List).add({
          'tag': 'test-anytls',
          'type': 'anytls',
          'server': 'example.com',
          'server_port': 443,
          'password': 'x',
          'tls': {'enabled': true},
          // 拨号字段 routing_mark 带 schema 下界外的值（生成模型 Object? 拍平透传，
          // 旧用例的非法字段 network 会被生成模型丢弃，故换此字段保留字段级诊断意图）
          'routing_mark': -1,
        });

        await SingBoxConfigProvider.validateOrLog(
          SingBox.fromJson(broken),
        );

        final log = captured.join('\n');
        // 汇总错误本体仍在
        expect(log, contains('matched 0'));
        // 诊断行展开到字段级，指出非法字段 routing_mark
        expect(log, contains('type="anytls"'));
        expect(log, contains('routing_mark'));
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
        final broken = _deepCopy(templateMap);
        (broken['inbounds'] as List).first['type'] = 'not-a-real-type';

        final singBox = await SingBoxConfigProvider.provide(jsonEncode(broken));

        // 放行：对象返回且非法值原样保留（UnknownInbound 透传原始 type）
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

  group('SingBoxConfigProvider.provide 出站类型放行', () {
    test('Base64 订阅的 shadowsocks 节点保留（旧白名单曾静默丢弃）', () async {
      final sub = _encodeSub([
        'ss://aes-128-gcm:pass1@1.2.3.4:8388#ss1',
        'ss://aes-128-gcm:pass2@5.6.7.8:8388#ss2',
      ]);

      final singBox = await SingBoxConfigProvider.provide(sub);

      final tags = singBox.outbounds.map((o) => o.tag).toSet();
      expect(tags, containsAll(['ss1', 'ss2']));
      final ssNodes = singBox.outbounds.whereType<ShadowsocksOutbound>().toList();
      expect(ssNodes, hasLength(2));
      expect(ssNodes.map((e) => e.method), everyElement('aes-128-gcm'));
    });

    test('未建模类型与已废弃 block 静默丢弃，已建模类型保留', () async {
      // route 段结构非法 → SingBox.fromJson 抛异常 → 走 _fixSingBoxConfig
      // （白名单过滤只作用于该汇合路径，直解成功不经过）
      final broken = _deepCopy(templateMap);
      broken['route'] = 'not-a-map';
      broken['outbounds'] = [
        {'tag': 'g', 'type': 'selector', 'outbounds': ['vm1', 'vm2']},
        {
          'tag': 'vm1',
          'type': 'vmess',
          'server': 'a.com',
          'server_port': 1,
          'uuid': 'u1',
        },
        {
          'tag': 'vm2',
          'type': 'vmess',
          'server': 'b.com',
          'server_port': 2,
          'uuid': 'u2',
        },
        {
          'tag': 'wg',
          'type': 'wireguard',
          'server': 'c.com',
          'server_port': 3,
          'private_key': 'k',
        },
        {'tag': 'bk', 'type': 'block'},
      ];

      final singBox = await SingBoxConfigProvider.provide(jsonEncode(broken));

      final tags = singBox.outbounds.map((o) => o.tag).toSet();
      expect(tags, containsAll(['g', 'vm1', 'vm2']));
      expect(tags, isNot(contains('wg')), reason: '未建模类型不得透传进配置');
      expect(tags, isNot(contains('bk')), reason: '已废弃的 block 不得进新配置');
    });
  });
}

/// 将若干分享链接行编码为 base64 订阅体。
String _encodeSub(List<String> lines) =>
    base64.encode(utf8.encode(lines.join('\n')));

/// 深拷贝：jsonEncode/Decode 走一遭，避免用例间共享 templateMap 的嵌套引用。
Map<String, dynamic> _deepCopy(Map<String, dynamic> source) =>
    jsonDecode(jsonEncode(source)) as Map<String, dynamic>;
