import 'package:flutter_sing_box/src/core/provider/sing_box_legacy_upgrader.dart';
import 'package:flutter_test/flutter_test.dart';

/// 升级整份配置，按 tag 取出升级后的 DNS 服务器。
Map<String, dynamic> upgradedServer(Map<String, dynamic> config, String tag) {
  final dns = SingBoxLegacyUpgrader.upgrade(config)['dns'] as Map<String, dynamic>;
  return (dns['servers'] as List).cast<Map<String, dynamic>>().firstWhere((s) => s['tag'] == tag);
}

const proxy = {'tag': 'node-a', 'type': 'vmess', 'server': 'a.example.com', 'server_port': 1, 'uuid': 'u1'};

void main() {
  group('空 direct 的判定：值为 null 或内核按零值处理的拨号字段视为不存在', () {
    // 旧写法服务器 detour: direct（显式 detour 的处理）
    Map<String, dynamic> explicitDetour(Map<String, dynamic> direct) => {
      'dns': {
        'servers': [
          {'tag': 'local', 'address': 'local', 'detour': 'direct'},
          {'tag': 'remote', 'address': 'tls://192.0.2.53', 'detour': 'direct'},
        ],
      },
      'outbounds': [proxy, direct],
    };
    // 旧写法服务器没有 detour，默认出站是这个 direct（默认出站的处理）
    Map<String, dynamic> defaultOutbound(Map<String, dynamic> direct) => {
      'dns': {
        'servers': [
          {'tag': 'local', 'address': 'local'},
          {'tag': 'remote', 'address': 'tls://192.0.2.53'},
        ],
      },
      'outbounds': [proxy, direct],
      'route': {'final': 'direct'},
    };

    void expectNoDetour(Map<String, dynamic> direct) {
      for (final build in [explicitDetour, defaultOutbound]) {
        final config = build(direct);
        for (final tag in ['local', 'remote']) {
          final server = upgradedServer(config, tag);
          expect(server.containsKey('detour'), isFalse, reason: '$direct → $server');
        }
      }
    }

    void expectDetourKept(Map<String, dynamic> direct) {
      for (final build in [explicitDetour, defaultOutbound]) {
        final config = build(direct);
        for (final tag in ['local', 'remote']) {
          expect(upgradedServer(config, tag)['detour'], 'direct', reason: '$direct');
        }
      }
    }

    test('bind_interface 为 null：不写 detour，detour: direct 去掉', () {
      expectNoDetour({'type': 'direct', 'tag': 'direct', 'bind_interface': null});
    });

    test('空字符串、空列表、false、0：内核同样判为空 direct，不写 detour', () {
      expectNoDetour({'type': 'direct', 'tag': 'direct', 'bind_interface': ''});
      expectNoDetour({'type': 'direct', 'tag': 'direct', 'network_type': <String>[]});
      expectNoDetour({'type': 'direct', 'tag': 'direct', 'tcp_fast_open': false});
      expectNoDetour({'type': 'direct', 'tag': 'direct', 'routing_mark': 0});
    });

    test('带有效拨号字段的 direct：detour 保留', () {
      expectDetourKept({'type': 'direct', 'tag': 'direct', 'bind_interface': 'eth0'});
      expectDetourKept({'type': 'direct', 'tag': 'direct', 'bind_interface': null, 'routing_mark': 1});
    });

    test('udp_fragment 为 false 不是零值（内核按已设置处理）：detour 保留', () {
      expectDetourKept({'type': 'direct', 'tag': 'direct', 'udp_fragment': false});
    });
  });

  group('显式 type default 的规则与不写 type 的规则相同', () {
    Map<String, dynamic> upgradeRules(List<Map<String, dynamic>> rules) => SingBoxLegacyUpgrader.upgrade({
      'dns': {
        'servers': [
          {'tag': 'local', 'type': 'local'},
          {'tag': 'remote', 'type': 'udp', 'server': '192.0.2.53'},
        ],
        'rules': rules,
      },
      'outbounds': [proxy],
      'route': <String, dynamic>{},
    });

    test('type default 的 any 规则写入默认解析器，并压住后面的具体出站规则', () {
      final config = upgradeRules([
        {'type': 'default', 'outbound': 'any', 'server': 'local'},
        {'outbound': 'node-a', 'server': 'remote'},
      ]);
      expect((config['route'] as Map)['default_domain_resolver'], 'local');
      final nodeA = (config['outbounds'] as List).single as Map<String, dynamic>;
      expect(nodeA.containsKey('domain_resolver'), isFalse, reason: '$nodeA');
      expect((config['dns'] as Map)['rules'], isEmpty);
    });

    test('type default 的具体出站规则写入该出站的 domain_resolver', () {
      final config = upgradeRules([
        {'type': 'default', 'outbound': ['node-a'], 'server': 'remote'},
      ]);
      final nodeA = (config['outbounds'] as List).single as Map<String, dynamic>;
      expect(nodeA['domain_resolver'], 'remote');
    });

    test('type default 且带别的条件：整条删除，不写解析器', () {
      final config = upgradeRules([
        {'type': 'default', 'outbound': 'any', 'domain_suffix': ['example.com'], 'server': 'local'},
      ]);
      expect((config['route'] as Map).containsKey('default_domain_resolver'), isFalse);
      expect((config['dns'] as Map)['rules'], isEmpty);
    });

    test('逻辑规则的子规则是 type default 且带非空 outbound：整条逻辑规则删除', () {
      final config = upgradeRules([
        {
          'type': 'logical',
          'mode': 'and',
          'rules': [
            {'type': 'default', 'outbound': ['node-a']},
            {'domain_suffix': ['example.com']},
          ],
          'server': 'remote',
        },
      ]);
      expect((config['dns'] as Map)['rules'], isEmpty);
      final nodeA = (config['outbounds'] as List).single as Map<String, dynamic>;
      expect(nodeA.containsKey('domain_resolver'), isFalse);
    });
  });

  group('默认出站：route.final 可以指向 endpoint', () {
    Map<String, dynamic> config(Object? finalTag) => {
      'dns': {
        'servers': [
          {'tag': 'remote', 'address': 'tls://192.0.2.53'},
        ],
      },
      'outbounds': [
        {'tag': 'g', 'type': 'selector', 'outbounds': ['node-a', 'direct']},
        proxy,
        {'tag': 'direct', 'type': 'direct'},
      ],
      'endpoints': [
        {'tag': 'wg', 'type': 'wireguard', 'address': ['198.51.100.2/32'], 'private_key': 'k'},
      ],
      'route': {'final': ?finalTag},
    };

    test('route.final 是 endpoints 里的 tag：detour 为这个 endpoint', () {
      expect(upgradedServer(config('wg'), 'remote')['detour'], 'wg');
    });

    test('route.final 在 outbounds 里：detour 为该出站', () {
      expect(upgradedServer(config('node-a'), 'remote')['detour'], 'node-a');
    });

    test('route.final 都不在或缺失：detour 为第一个出站', () {
      expect(upgradedServer(config('missing'), 'remote')['detour'], 'g');
      expect(upgradedServer(config(null), 'remote')['detour'], 'g');
    });
  });
}
