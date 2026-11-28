import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:isolate';

import 'package:flutter/services.dart';
import 'package:flutter_sing_box/flutter_sing_box.dart' hide Inbound, Outbound, RuleSet, SingBox;
import 'package:flutter_sing_box/src/core/provider/sing_box_legacy_upgrader.dart';
import 'package:flutter_sing_box/src/data/models/singbox/gen/index.dart';
import 'package:flutter_test/flutter_test.dart';

/// 升级整份配置，按 tag 取出升级后的 DNS 服务器。
Map<String, dynamic> upgradedServer(Map<String, dynamic> config, String tag) {
  final dns = SingBoxLegacyUpgrader.upgrade(config)['dns'] as Map<String, dynamic>;
  return (dns['servers'] as List).cast<Map<String, dynamic>>().firstWhere((s) => s['tag'] == tag);
}

const proxy = {'tag': 'node-a', 'type': 'vmess', 'server': 'a.example.com', 'server_port': 1, 'uuid': 'u1'};
const emptyDirect = {'tag': 'direct', 'type': 'direct'};
const nodeB = {'tag': 'node-b', 'type': 'vmess', 'server': 'b.example.com', 'server_port': 2, 'uuid': 'u2'};

/// 旧写法服务器 doh 的 detour 指向 direct；[others] 是 dns.servers 里的其它服务器。
Map<String, dynamic> dohConfig({
  String address = 'https://dns.example.com/dns-query',
  Map<String, dynamic> direct = emptyDirect,
  List<Map<String, dynamic>> others = const [
    {'tag': 'a', 'address': '192.0.2.53'},
    {'tag': 'b', 'address': '198.51.100.53'},
  ],
  List<Map<String, dynamic>> rules = const [],
  Map<String, dynamic>? route,
  Map<String, dynamic> extra = const {},
}) => {
  'dns': {
    'servers': [
      {'tag': 'doh', 'address': address, 'detour': 'direct', ...extra},
      ...others,
    ],
    'rules': rules,
  },
  'outbounds': [proxy, direct],
  'route': ?route,
};

/// 测试环境里经 rootBundle 加载内置模板与 schema。
void mockAssets() {
  setUpAll(() async {
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
    await SingBoxSchemaValidator.instance(
      assetLoader: (_) => File('assets/schemas/singbox_schema.json').readAsString(),
    );
  });
}

/// 能直接被 SingBox.fromJson 读进来的订阅（走主路径）：入站带 tag，有 route 规则。
Map<String, dynamic> mainPathSubscription({
  required List<Map<String, dynamic>> servers,
  required Map<String, dynamic> direct,
  List<Map<String, dynamic>> rules = const [],
}) => {
  'dns': {'servers': servers, 'rules': rules},
  'inbounds': [
    {'type': 'mixed', 'tag': 'mixed-in', 'listen': '127.0.0.1', 'listen_port': 2080},
  ],
  'outbounds': [
    {'tag': 'g', 'type': 'selector', 'outbounds': ['node-a', 'node-b', 'direct']},
    proxy,
    nodeB,
    direct,
  ],
  'route': {
    'rules': [
      {'domain_suffix': ['example.com'], 'outbound': 'direct'},
    ],
    'final': 'g',
  },
};

/// 订阅确实走了主路径：入站与 route 规则是订阅自己的，不是模板的。
void expectMainPath(SingBox singBox) {
  expect(singBox.inbounds.map((i) => i.tag), ['mixed-in']);
  expect(singBox.route.toJson()['rules'], [
    {'domain_suffix': ['example.com'], 'outbound': 'direct'},
  ]);
}

Map<String, dynamic> serverJson(SingBox singBox, String tag) =>
    singBox.dns.servers!.firstWhere((s) => s.tag == tag).toJson();

Map<String, dynamic> outboundJson(SingBox singBox, String tag) =>
    singBox.outbounds.firstWhere((o) => o.tag == tag).toJson();

/// 在另一个 isolate 里升级 [config]，超过 [limit] 时结束那个 isolate 并返回 false。
Future<bool> upgradesWithin(Map<String, dynamic> config, Duration limit) async {
  final done = ReceivePort();
  final isolate = await Isolate.spawn((args) {
    final (config, port) = args;
    SingBoxLegacyUpgrader.upgrade(config);
    port.send(true);
  }, (config, done.sendPort));
  try {
    await done.first.timeout(limit);
    return true;
  } on TimeoutException {
    return false;
  } finally {
    isolate.kill(priority: Isolate.immediate);
    done.close();
  }
}

void main() {
  mockAssets();

  group('去掉指向空 direct 的 detour 后，域名形式的服务器补上 domain_resolver', () {
    test('route.default_domain_resolver 优先于 outbound 规则与唯一的其它服务器', () {
      final server = upgradedServer(
        dohConfig(
          others: [
            {'tag': 'a', 'address': '192.0.2.53'},
          ],
          rules: [
            {'outbound': 'direct', 'server': 'a'},
          ],
          route: {'default_domain_resolver': 'r-default'},
        ),
        'doh',
      );
      expect(server.containsKey('detour'), isFalse);
      expect(server['domain_resolver'], 'r-default');
    });

    test('没有默认解析器时用给这个 direct 的 outbound 规则（含选项的对象形式）', () {
      final server = upgradedServer(
        dohConfig(
          rules: [
            {'outbound': ['direct'], 'server': 'a', 'disable_cache': true},
            {'outbound': 'any', 'server': 'b'},
          ],
          route: {},
        ),
        'doh',
      );
      expect(server['domain_resolver'], {'server': 'a', 'disable_cache': true});
    });

    test('any 规则在前：用 any 规则的服务器（后面给 direct 的规则不生效）', () {
      final server = upgradedServer(
        dohConfig(
          rules: [
            {'outbound': 'any', 'server': 'b'},
            {'outbound': 'direct', 'server': 'a'},
          ],
          route: {},
        ),
        'doh',
      );
      expect(server['domain_resolver'], 'b');
    });

    test('订阅没有 route 段：any 规则的服务器同样补到这台服务器上', () {
      final server = upgradedServer(
        dohConfig(
          rules: [
            {'outbound': 'any', 'server': 'b'},
          ],
        ),
        'doh',
      );
      expect(server['domain_resolver'], 'b');
    });

    test('没有规则与默认解析器：dns.servers 只有一台其它服务器时用它', () {
      final server = upgradedServer(
        dohConfig(
          address: 'tls://dns.example.com',
          others: [
            {'tag': 'a', 'address': '192.0.2.53'},
          ],
        ),
        'doh',
      );
      expect(server.containsKey('detour'), isFalse);
      expect(server['domain_resolver'], 'a');
    });

    test('取不到任何来源（其它服务器不止一台）：不写', () {
      final server = upgradedServer(dohConfig(), 'doh');
      expect(server.containsKey('detour'), isFalse);
      expect(server.containsKey('domain_resolver'), isFalse);
    });

    test('来源指向这台服务器自己：跳过，取下一个来源；没有下一个时不写', () {
      expect(
        upgradedServer(
          dohConfig(
            others: [
              {'tag': 'a', 'address': '192.0.2.53'},
            ],
            route: {'default_domain_resolver': {'server': 'doh'}},
          ),
          'doh',
        )['domain_resolver'],
        'a',
      );
      expect(
        upgradedServer(dohConfig(others: [], route: {'default_domain_resolver': 'doh'}), 'doh')
            .containsKey('domain_resolver'),
        isFalse,
      );
    });

    test('写了 address_resolver：照旧用它', () {
      final server = upgradedServer(
        dohConfig(
          extra: {'address_resolver': 'b'},
          route: {'default_domain_resolver': 'a'},
        ),
        'doh',
      );
      expect(server['domain_resolver'], 'b');
    });

    test('主机是 IPv4 / IPv6 字面量：不补', () {
      for (final address in [
        'https://192.0.2.1/dns-query',
        'https://[2001:db8::1]/dns-query',
        'tls://2001:db8::2',
        '192.0.2.2',
      ]) {
        final server = upgradedServer(
          dohConfig(address: address, route: {'default_domain_resolver': 'a'}),
          'doh',
        );
        expect(server.containsKey('detour'), isFalse, reason: address);
        expect(server.containsKey('domain_resolver'), isFalse, reason: address);
      }
    });

    test('detour 没有去掉（指向带拨号字段的 direct 或代理）：不补', () {
      final kept = upgradedServer(
        dohConfig(
          direct: {'tag': 'direct', 'type': 'direct', 'bind_interface': 'en0'},
          route: {'default_domain_resolver': 'a'},
        ),
        'doh',
      );
      expect(kept['detour'], 'direct');
      expect(kept.containsKey('domain_resolver'), isFalse);

      final config = dohConfig(route: {'default_domain_resolver': 'a'});
      ((config['dns'] as Map)['servers'] as List).first['detour'] = 'node-a';
      final viaProxy = upgradedServer(config, 'doh');
      expect(viaProxy['detour'], 'node-a');
      expect(viaProxy.containsKey('domain_resolver'), isFalse);
    });

    test('没写 detour、默认出站是空 direct：不补', () {
      final config = dohConfig(route: {'final': 'direct', 'default_domain_resolver': 'a'});
      ((config['dns'] as Map)['servers'] as List).first.remove('detour');
      final server = upgradedServer(config, 'doh');
      expect(server.containsKey('detour'), isFalse);
      expect(server.containsKey('domain_resolver'), isFalse);
    });

    test('经 provide：主路径与回退路径的产物里 doh 带 domain_resolver，IP 主机的服务器不带', () async {
      final servers = [
        {'tag': 'doh', 'address': 'https://dns.example.com/dns-query', 'detour': 'direct'},
        {'tag': 'bootstrap', 'address': '192.0.2.53', 'detour': 'direct'},
      ];
      final main = await SingBoxConfigProvider.provide(
        mainPathSubscription(servers: servers, direct: emptyDirect),
      );
      expectMainPath(main);
      expect(serverJson(main, 'doh'), {
        'type': 'https',
        'tag': 'doh',
        'server': 'dns.example.com',
        'domain_resolver': 'bootstrap',
      });
      expect(serverJson(main, 'bootstrap'), {'type': 'udp', 'tag': 'bootstrap', 'server': '192.0.2.53'});

      // tun 入站缺 tag → SingBox.fromJson 失败 → 回退路径；补写的 domain_resolver 原样保留
      final fallback = await SingBoxConfigProvider.provide({
        'dns': {'servers': servers, 'rules': []},
        'inbounds': [
          {'type': 'tun', 'address': ['172.19.0.1/30'], 'auto_route': true},
        ],
        'outbounds': [
          {'tag': 'g', 'type': 'selector', 'outbounds': ['node-a', 'node-b']},
          proxy,
          nodeB,
          emptyDirect,
        ],
        'route': {'rules': []},
      });
      expect(fallback.dns.servers!.map((s) => s.tag), contains('alidoh'), reason: '回退路径并入了模板的服务器');
      final doh = serverJson(fallback, 'doh');
      expect(doh.containsKey('detour'), isFalse);
      expect(doh['domain_resolver'], 'bootstrap');
      expect(serverJson(fallback, 'bootstrap').containsKey('domain_resolver'), isFalse);
    });
  });

  group('空 direct 按生成模型序列化后的出站判定', () {
    Map<String, dynamic> explicitDetour(Map<String, dynamic> direct) => {
      'dns': {
        'servers': [
          {'tag': 'remote', 'address': 'tls://192.0.2.53', 'detour': 'direct'},
        ],
      },
      'outbounds': [proxy, direct],
    };
    Map<String, dynamic> defaultOutbound(Map<String, dynamic> direct) => {
      'dns': {
        'servers': [
          {'tag': 'remote', 'address': 'tls://192.0.2.53'},
        ],
      },
      'outbounds': [proxy, direct],
      'route': {'final': 'direct'},
    };

    test('domain_strategy 写非零策略、带模型没有的键：模型读入后只剩 type 与 tag，去掉 detour', () {
      for (final direct in [
        {'tag': 'direct', 'type': 'direct', 'domain_strategy': 'prefer_ipv4'},
        {'tag': 'direct', 'type': 'direct', 'unknown_key': 1},
      ]) {
        for (final build in [explicitDetour, defaultOutbound]) {
          final server = upgradedServer(build(direct), 'remote');
          expect(server.containsKey('detour'), isFalse, reason: '$direct → $server');
        }
      }
    });

    test('模型保留的非零拨号字段：保留 detour', () {
      for (final direct in [
        {'tag': 'direct', 'type': 'direct', 'bind_interface': 'en0'},
        {'tag': 'direct', 'type': 'direct', 'connect_timeout': '5s', 'domain_strategy': 'prefer_ipv4'},
      ]) {
        for (final build in [explicitDetour, defaultOutbound]) {
          expect(upgradedServer(build(direct), 'remote')['detour'], 'direct', reason: '$direct');
        }
      }
    });

    test('模型读不进这个出站：按原始字段判定，升级照常进行', () {
      // bind_interface 不是字符串，生成的模型读不进来
      final dropped = upgradedServer(explicitDetour({'tag': 'direct', 'type': 'direct', 'bind_interface': 0}), 'remote');
      expect(dropped['type'], 'tls');
      expect(dropped.containsKey('detour'), isFalse);
      final kept = upgradedServer(explicitDetour({'tag': 'direct', 'type': 'direct', 'bind_interface': 1}), 'remote');
      expect(kept['type'], 'tls');
      expect(kept['detour'], 'direct');
    });

    test('经 provide 的主路径：产物里 direct 只有 type 与 tag，服务器没有 detour', () async {
      final servers = [
        {'tag': 'remote', 'address': 'tls://192.0.2.53', 'detour': 'direct'},
      ];
      final singBox = await SingBoxConfigProvider.provide(mainPathSubscription(
        servers: servers,
        direct: {'tag': 'direct', 'type': 'direct', 'domain_strategy': 'prefer_ipv4'},
      ));
      expectMainPath(singBox);
      expect(outboundJson(singBox, 'direct'), {'type': 'direct', 'tag': 'direct'});
      expect(serverJson(singBox, 'remote').containsKey('detour'), isFalse);

      final control = await SingBoxConfigProvider.provide(mainPathSubscription(
        servers: servers,
        direct: {'tag': 'direct', 'type': 'direct', 'bind_interface': 'en0'},
      ));
      expectMainPath(control);
      expect(serverJson(control, 'remote')['detour'], 'direct');
    });

    test('经 provide：模型读不进 direct 时，产物的 detour 不指向空 direct', () async {
      final singBox = await SingBoxConfigProvider.provide(mainPathSubscription(
        servers: [
          {'tag': 'remote', 'address': 'tls://192.0.2.53', 'detour': 'direct'},
        ],
        direct: {'tag': 'direct', 'type': 'direct', 'bind_interface': 0},
      ));
      final detour = serverJson(singBox, 'remote')['detour'];
      if (detour != null) {
        final target = outboundJson(singBox, detour as String);
        expect(SingBoxLegacyUpgrader.isEmptyDirect(target), isFalse, reason: '$target');
      }
    });
  });

  group('时长零值的判定', () {
    Map<String, dynamic> config(String value) => {
      'dns': {
        'servers': [
          {'tag': 'remote', 'address': 'tls://192.0.2.53', 'detour': 'direct'},
        ],
      },
      'outbounds': [
        proxy,
        {'tag': 'direct', 'type': 'direct', 'connect_timeout': value},
      ],
    };

    // 只认每段都是「零 + 单位」的常见写法；带正负号、d 单位、小数截断成 0
    // （如 "0.9ns"）等罕见写法不认，按已设置处理，detour 保留，交给内核报错
    test('每段都是零的常见写法：去掉 detour', () {
      for (final value in ['0', '0s', '0ms', '0h0m0s', '0.0s', '.0s', '00s', '0µs0μs0us']) {
        expect(upgradedServer(config(value), 'remote').containsKey('detour'), isFalse, reason: '时长 $value 等于 0，应去掉 detour');
      }
    });

    test('非零与非法的写法：保留 detour', () {
      for (final value in ['5s', '1ns', '0.5s', '1d', '0.000000001s', '', 's', '.s', '0x', '0sx', '+', '0s0', '--0s', '0 s']) {
        expect(upgradedServer(config(value), 'remote')['detour'], 'direct', reason: '时长 $value 不等于 0 或解析不了，应保留 detour');
      }
    });

    test('一长串 0 加一个不匹配的字符：判定耗时与长度线性', () async {
      final value = '${'0' * 5000}x';
      expect(await upgradesWithin(config(value), const Duration(seconds: 1)), isTrue, reason: '升级超过 1 秒没有完成');
      expect(upgradedServer(config(value), 'remote')['detour'], 'direct');
    });
  });

  group('routing_mark 写成字符串零值', () {
    Map<String, dynamic> config(Object mark) => {
      'dns': {
        'servers': [
          {'tag': 'remote', 'address': 'tls://192.0.2.53', 'detour': 'direct'},
        ],
      },
      'outbounds': [
        proxy,
        {'tag': 'direct', 'type': 'direct', 'routing_mark': mark},
      ],
    };

    test('按 ParseUint(s, 0, 32) 解析为 0：去掉 detour', () {
      for (final mark in <Object>[0, '0', '0x0', '0X00', '00', '0b0', '0o0', '0_0', '0x_0']) {
        expect(upgradedServer(config(mark), 'remote').containsKey('detour'), isFalse, reason: 'routing_mark $mark 解析为 0，应去掉 detour');
      }
    });

    test('非零或解析不了：保留 detour', () {
      for (final mark in <Object>[1, '0x1', '1', '', '0x', '+0', '-0', '_0', '0_', '0__0', 'abc', '0x0g']) {
        expect(upgradedServer(config(mark), 'remote')['detour'], 'direct', reason: 'routing_mark $mark 不为 0 或解析不了，应保留 detour');
      }
    });
  });

  group('outbound 规则带 strategy 时照旧迁移', () {
    Map<String, dynamic> upgradeRules(List<Map<String, dynamic>> rules) => SingBoxLegacyUpgrader.upgrade({
      'dns': {
        'servers': [
          {'tag': 'bootstrap', 'type': 'udp', 'server': '192.0.2.53'},
        ],
        'rules': rules,
      },
      'outbounds': [proxy],
      'route': <String, dynamic>{},
    });

    test('any 规则：默认解析器写成带 strategy 的对象', () {
      final config = upgradeRules([
        {'outbound': 'any', 'server': 'bootstrap', 'strategy': 'ipv4_only'},
      ]);
      expect((config['route'] as Map)['default_domain_resolver'], {'server': 'bootstrap', 'strategy': 'ipv4_only'});
      expect((config['dns'] as Map)['rules'], isEmpty);
    });

    test('具体出站规则：该出站的 domain_resolver 写成带 strategy 的对象', () {
      final config = upgradeRules([
        {'outbound': ['node-a'], 'server': 'bootstrap', 'strategy': 'prefer_ipv6', 'disable_cache': true},
      ]);
      final nodeA = (config['outbounds'] as List).single as Map<String, dynamic>;
      expect(nodeA['domain_resolver'], {'server': 'bootstrap', 'strategy': 'prefer_ipv6', 'disable_cache': true});
    });

    test('带别的条件仍整条删除；不带选项时仍是字符串', () {
      final config = upgradeRules([
        {'outbound': 'node-a', 'server': 'bootstrap', 'strategy': 'ipv4_only', 'domain': ['example.com']},
        {'outbound': 'any', 'server': 'bootstrap'},
      ]);
      expect((config['route'] as Map)['default_domain_resolver'], 'bootstrap');
      final nodeA = (config['outbounds'] as List).single as Map<String, dynamic>;
      expect(nodeA.containsKey('domain_resolver'), isFalse);
    });
  });
}
