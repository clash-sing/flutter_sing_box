import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart' show debugPrint;
import 'package:flutter/services.dart';
// 旧拍平模型（SingBox 等重名导出）已不再使用，hide 后从 gen 导入
import 'package:flutter_sing_box/flutter_sing_box.dart'
    hide Inbound, Outbound, RuleSet, SingBox;
import 'package:flutter_sing_box/src/data/models/singbox/gen/index.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;

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

  group('回退合并的 DNS 服务器标签', () {
    // 缺 inbounds → SingBox.fromJson 失败 → 走 _fixSingBoxConfig 回退路径
    Map<String, dynamic> fallbackSubscription(List<Map<String, dynamic>> servers) => {
      'dns': {'servers': servers, 'rules': []},
      'outbounds': [
        {'tag': 'g', 'type': 'selector', 'outbounds': ['vm1', 'vm2']},
        {'tag': 'vm1', 'type': 'vmess', 'server': 'a.com', 'server_port': 1, 'uuid': 'u1'},
        {'tag': 'vm2', 'type': 'vmess', 'server': 'b.com', 'server_port': 2, 'uuid': 'u2'},
      ],
    };

    test('订阅与模板同名时保留订阅的服务器，其余模板服务器不动', () async {
      // 订阅复用模板的 remote 标签 + 自己的 local 标签（clash_sing_app#16 样本）
      final singBox = await SingBoxConfigProvider.provide(
        fallbackSubscription([
          {'tag': 'remote', 'type': 'https', 'server': '1.1.1.1'},
          {'tag': 'local', 'type': 'udp', 'server': '8.8.8.8'},
        ]),
      );

      final servers = singBox.dns.servers!;
      final tags = servers.map((server) => server.tag).toList();
      // sing-box 1.14.3 起同名 DNS 服务器直接拒绝整份配置
      expect(tags.toSet().length, tags.length, reason: 'DNS 服务器标签必须唯一: $tags');
      // 同名时订阅优先（与 sing-box 1.14.2 的“后加顶替”行为一致）
      expect(servers.firstWhere((server) => server.tag == 'remote').type, 'https');
      expect(tags, containsAll(['local', 'system', 'alidoh', 'udp-bytedance']));
    });

    test('订阅的 DNS 规则引用了模板里没有的规则集时不并入，其余规则照常并入', () async {
      // 回退路径用模板的 route，订阅自己定义的规则集不会带过来；规则还引用它，
      // 内核报 rule-set not found 拒收整份配置
      final subscription = fallbackSubscription([
        {'tag': 'local', 'type': 'udp', 'server': '203.0.113.8'},
      ]);
      (subscription['dns'] as Map<String, dynamic>)['rules'] = [
        {'rule_set': ['category-ads-all'], 'action': 'predefined', 'rcode': 'NOERROR'},
        {
          'type': 'logical',
          'mode': 'or',
          'rules': [
            {'rule_set': 'category-ads-all'},
          ],
          'server': 'local',
        },
        {'rule_set': ['geosite-cn'], 'server': 'local'},
        {'domain_suffix': ['example.org'], 'server': 'local'},
      ];
      subscription['route'] = {
        'rule_set': [
          {'tag': 'category-ads-all', 'type': 'remote', 'format': 'binary', 'url': 'https://example.com/ads.srs'},
        ],
      };

      final singBox = await SingBoxConfigProvider.provide(subscription);

      final ruleSetTags = singBox.route.ruleSet!.map((ruleSet) => ruleSet.tag).toSet();
      expect(ruleSetTags, contains('geosite-cn'), reason: '模板自带 geosite-cn');
      final rules = singBox.dns.rules!.map((rule) => jsonEncode(rule.toJson())).toList();
      expect(rules.where((rule) => rule.contains('category-ads-all')), isEmpty);
      expect(rules.take(2), [
        jsonEncode({'rule_set': ['geosite-cn'], 'server': 'local'}),
        jsonEncode({'domain_suffix': ['example.org'], 'server': 'local'}),
      ]);
    });
  });

  group('旧写法的 DNS（sing-box 1.12 之前的格式）', () {
    // 面板默认模板常见的写法：DNS 服务器用 address，规则里有 outbound 条件，
    // 还有 rcode:// 服务器
    Map<String, dynamic> legacyDns() => {
      'servers': [
        {'tag': 'remote', 'address': 'https://203.0.113.1/dns-query', 'detour': 'g'},
        {'tag': 'local', 'address': 'https://198.51.100.5/dns-query', 'detour': 'direct'},
        {'tag': 'block', 'address': 'rcode://success'},
      ],
      'rules': [
        {'outbound': ['any'], 'server': 'local'},
        {'clash_mode': 'global', 'server': 'remote'},
      ],
    };
    List<Map<String, dynamic>> outbounds() => [
      {'tag': 'g', 'type': 'selector', 'outbounds': ['vm1', 'vm2']},
      {'tag': 'vm1', 'type': 'vmess', 'server': 'a.example.com', 'server_port': 1, 'uuid': 'u1'},
      {'tag': 'vm2', 'type': 'vmess', 'server': 'b.example.com', 'server_port': 2, 'uuid': 'u2'},
      {'tag': 'direct', 'type': 'direct'},
    ];

    void expectNoLegacyServers(SingBox singBox) {
      final servers = singBox.dns.servers!;
      // 旧写法没有 type，会落进 UnknownDnsServer 原样透传，内核 1.14 整份拒收
      expect(servers.whereType<UnknownDnsServer>(), isEmpty,
          reason: '仍有旧写法的服务器: ${servers.map((s) => s.toJson()).toList()}');
      expect(servers.map((s) => s.tag), isNot(contains('block')));
    }

    test('回退路径（tun 入站没有 tag）：订阅的 DNS 服务器升级成新写法再合并', () async {
      final singBox = await SingBoxConfigProvider.provide({
        'dns': legacyDns(),
        'inbounds': [
          {'type': 'tun', 'address': ['172.19.0.1/30'], 'auto_route': true},
        ],
        'outbounds': outbounds(),
        'route': {'rules': []},
      });

      expectNoLegacyServers(singBox);
      final remote = singBox.dns.servers!.firstWhere((s) => s.tag == 'remote');
      expect(remote.toJson(), {'type': 'https', 'tag': 'remote', 'server': '203.0.113.1', 'detour': 'g'});
    });

    test('回退路径：outbound 条件的规则不会变成匹配一切的规则', () async {
      final singBox = await SingBoxConfigProvider.provide({
        'dns': legacyDns(),
        'outbounds': outbounds(),
      });

      // 生成的 DNSRule 没有 outbound 字段，不升级的话这条规则读进来只剩
      // {"server": "local"}，排在最前面，所有查询都走 local
      final rules = singBox.dns.rules!.map((rule) => rule.toJson()).toList();
      expect(rules, isNot(contains(equals({'server': 'local'}))));
      expect(rules.first, {'clash_mode': 'global', 'server': 'remote'});
    });

    test('主路径（整份配置能直接解析）：DNS 服务器同样升级', () async {
      final config = _deepCopy(templateMap)
        ..['dns'] = legacyDns()
        ..['outbounds'] = outbounds();
      // 去掉模板自带的默认解析器，让迁移项写入的值可见
      (config['route'] as Map<String, dynamic>).remove('default_domain_resolver');
      final singBox = await SingBoxConfigProvider.provide(config);

      expectNoLegacyServers(singBox);
      expect(singBox.route.defaultDomainResolver, 'local');
    });

    test('面板样本：local 服务器的 detour 不再指向空 direct 出站', () async {
      for (final name in ['sb-xboard-default', 'sb-wyx-old']) {
        final sample = jsonDecode(
          File('tool/subcheck/verify/subs/samples/$name.json').readAsStringSync(),
        ) as Map<String, dynamic>;
        final singBox = await SingBoxConfigProvider.provide(sample);

        final local = singBox.dns.servers!.firstWhere((s) => s.tag == 'local').toJson();
        expect(local.containsKey('detour'), isFalse, reason: '$name: $local');
        final remote = singBox.dns.servers!.firstWhere((s) => s.tag == 'remote').toJson();
        expect(remote['detour'], '节点选择', reason: name);
      }
    });

    test('没有 tag 的旧写法服务器：导入不抛异常，补上的 tag 唯一', () async {
      final singBox = await SingBoxConfigProvider.provide({
        'dns': {
          'servers': [
            {'address': '192.0.2.53'},
            {'address': 'local'},
          ],
          'rules': [],
        },
        'outbounds': outbounds(),
      });

      final servers = singBox.dns.servers!.map((s) => s.toJson()).toList();
      expect(servers.where((s) => s['type'] == 'udp' && s['server'] == '192.0.2.53'), hasLength(1));
      expect(servers.where((s) => s['type'] == 'local'), isNotEmpty);
      final tags = servers.map((s) => s['tag']).toList();
      expect(tags.toSet().length, tags.length, reason: '$tags');
    });

    test('outbound 规则的 rewrite_ttl 等字段以对象形式保留到产物', () async {
      final config = _deepCopy(templateMap)
        ..['dns'] = {
          'servers': legacyDns()['servers'],
          'rules': [
            {'outbound': ['vm1'], 'server': 'remote', 'disable_cache': true},
            {'outbound': ['any'], 'server': 'local', 'rewrite_ttl': 60, 'client_subnet': '192.0.2.0/24'},
          ],
        }
        ..['outbounds'] = outbounds();
      (config['route'] as Map<String, dynamic>).remove('default_domain_resolver');
      final singBox = await SingBoxConfigProvider.provide(config);

      expect(
        singBox.route.toJson()['default_domain_resolver'],
        {'server': 'local', 'rewrite_ttl': 60, 'client_subnet': '192.0.2.0/24'},
      );
      final vm1 = singBox.outbounds.firstWhere((o) => o.tag == 'vm1').toJson();
      expect(vm1['domain_resolver'], {'server': 'remote', 'disable_cache': true});
    });
  });

  group('回退路径的默认域名解析器', () {
    // tun 入站缺 tag → SingBox.fromJson 失败 → 走 _fixSingBoxConfig 回退路径
    Map<String, dynamic> fallbackConfig(String resolverServer, {bool withRoute = true}) => {
      'dns': {
        'servers': [
          {'tag': 'remote', 'address': 'https://203.0.113.1/dns-query', 'detour': 'g'},
          {'tag': 'local', 'address': 'https://198.51.100.5/dns-query', 'detour': 'direct'},
        ],
        'rules': [
          {'outbound': ['any'], 'server': resolverServer},
        ],
      },
      'inbounds': [
        {'type': 'tun', 'address': ['172.19.0.1/30'], 'auto_route': true},
      ],
      'outbounds': [
        {'tag': 'g', 'type': 'selector', 'outbounds': ['vm1', 'vm2']},
        {'tag': 'vm1', 'type': 'vmess', 'server': 'a.example.com', 'server_port': 1, 'uuid': 'u1'},
        {'tag': 'vm2', 'type': 'vmess', 'server': 'b.example.com', 'server_port': 2, 'uuid': 'u2'},
        {'tag': 'direct', 'type': 'direct'},
      ],
      if (withRoute) 'route': {'rules': []},
    };
    Object? templateResolver() => (templateMap['route'] as Map)['default_domain_resolver'];

    test('订阅迁移出的解析器指向存在的服务器：覆盖模板的值', () async {
      final singBox = await SingBoxConfigProvider.provide(fallbackConfig('local'));
      expect(singBox.route.defaultDomainResolver, 'local');
      expect(templateResolver(), isNot('local'));
    });

    test('指向不存在的服务器：保留模板的值', () async {
      final singBox = await SingBoxConfigProvider.provide(fallbackConfig('missing'));
      expect(singBox.route.defaultDomainResolver, templateResolver());
    });

    test('订阅没有 route：迁移项不写解析器，回退用模板的值', () async {
      final singBox = await SingBoxConfigProvider.provide(fallbackConfig('local', withRoute: false));
      expect(singBox.route.defaultDomainResolver, templateResolver());
    });
  });

  group('规则集本地兜底', () {
    late Directory tmp;
    late Directory ruleSetDir;
    const pathProviderChannel = MethodChannel('plugins.flutter.io/path_provider');

    setUp(() async {
      tmp = await Directory.systemTemp.createTemp('sing_box_provider_rule_set_');
      ruleSetDir = Directory(p.join(tmp.path, 'rule-sets'));
      await ruleSetDir.create(recursive: true);
      for (final name in RuleSetAssets.fileNames) {
        await File(p.join(ruleSetDir.path, name)).writeAsBytes([1]);
      }
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(pathProviderChannel, (call) async => tmp.path);
    });

    tearDown(() async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(pathProviderChannel, null);
      if (await tmp.exists()) await tmp.delete(recursive: true);
    });

    test('Base64 订阅导入生成的配置带 initial_path', () async {
      final sub = _encodeSub([
        'ss://aes-128-gcm:pass1@1.2.3.4:8388#ss1',
        'ss://aes-128-gcm:pass2@5.6.7.8:8388#ss2',
      ]);

      final singBox = await SingBoxConfigProvider.provide(sub);

      final ruleSets = singBox.route.ruleSet!;
      for (final tag in ['geoip-cn', 'geosite-cn']) {
        final ruleSet = ruleSets.firstWhere((e) => e.tag == tag);
        expect(ruleSet.initialPath, p.join(ruleSetDir.path, '$tag.srs'));
      }
    });
  });
}

/// 将若干分享链接行编码为 base64 订阅体。
String _encodeSub(List<String> lines) =>
    base64.encode(utf8.encode(lines.join('\n')));

/// 深拷贝：jsonEncode/Decode 走一遭，避免用例间共享 templateMap 的嵌套引用。
Map<String, dynamic> _deepCopy(Map<String, dynamic> source) =>
    jsonDecode(jsonEncode(source)) as Map<String, dynamic>;
