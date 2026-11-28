import 'dart:convert';

import 'package:flutter_sing_box/src/core/provider/sing_box_legacy_upgrader.dart';
import 'package:flutter_test/flutter_test.dart';

/// 只升级 dns.servers 的便捷入口：返回升级后的服务器列表。
List<dynamic> upgradeServers(List<Map<String, dynamic>> servers) {
  final upgraded = SingBoxLegacyUpgrader.upgrade({
    'dns': {'servers': servers},
  });
  return (upgraded['dns'] as Map<String, dynamic>)['servers'] as List<dynamic>;
}

Map<String, dynamic> upgradeOne(Map<String, dynamic> server) =>
    upgradeServers([server]).single as Map<String, dynamic>;

/// 升级整份配置（带 outbounds、route 等），返回升级后的服务器列表。
List<dynamic> upgradeConfig(Map<String, dynamic> config) =>
    (SingBoxLegacyUpgrader.upgrade(config)['dns'] as Map<String, dynamic>)['servers'] as List<dynamic>;

void main() {
  group('DNS 服务器旧写法（address）→ 新写法（type + server）', () {
    test('https：拆出 server，默认路径 /dns-query 与默认端口 443 不写，detour 保留', () {
      expect(
        upgradeOne({'tag': 'remote', 'address': 'https://203.0.113.1/dns-query', 'detour': 'proxy'}),
        {'tag': 'remote', 'type': 'https', 'server': '203.0.113.1', 'detour': 'proxy'},
      );
    });

    test('https：非默认端口与路径写进 server_port / path', () {
      expect(
        upgradeOne({'tag': 'd', 'address': 'https://dns.example.com:8443/custom'}),
        {'tag': 'd', 'type': 'https', 'server': 'dns.example.com', 'server_port': 8443, 'path': '/custom'},
      );
    });

    test('h3：同 https 的规则', () {
      expect(
        upgradeOne({'tag': 'd', 'address': 'h3://203.0.113.1/dns-query'}),
        {'tag': 'd', 'type': 'h3', 'server': '203.0.113.1'},
      );
    });

    test('tls / quic：默认端口 853 不写，其它端口写进 server_port', () {
      expect(
        upgradeOne({'tag': 'd', 'address': 'tls://203.0.113.1'}),
        {'tag': 'd', 'type': 'tls', 'server': '203.0.113.1'},
      );
      expect(
        upgradeOne({'tag': 'd', 'address': 'quic://dns.example.com:8853'}),
        {'tag': 'd', 'type': 'quic', 'server': 'dns.example.com', 'server_port': 8853},
      );
    });

    test('tcp / udp：默认端口 53 不写', () {
      expect(
        upgradeOne({'tag': 'd', 'address': 'tcp://203.0.113.1'}),
        {'tag': 'd', 'type': 'tcp', 'server': '203.0.113.1'},
      );
      expect(
        upgradeOne({'tag': 'd', 'address': 'udp://203.0.113.8:5353'}),
        {'tag': 'd', 'type': 'udp', 'server': '203.0.113.8', 'server_port': 5353},
      );
    });

    test('不带协议头的地址按 udp 处理（IPv4、带端口、IPv6）', () {
      expect(
        upgradeOne({'tag': 'd', 'address': '203.0.113.8'}),
        {'tag': 'd', 'type': 'udp', 'server': '203.0.113.8'},
      );
      expect(
        upgradeOne({'tag': 'd', 'address': '203.0.113.8:5353'}),
        {'tag': 'd', 'type': 'udp', 'server': '203.0.113.8', 'server_port': 5353},
      );
      expect(
        upgradeOne({'tag': 'd', 'address': '2001:db8::1'}),
        {'tag': 'd', 'type': 'udp', 'server': '2001:db8::1'},
      );
      expect(
        upgradeOne({'tag': 'd', 'address': '[2001:db8::1]:5353'}),
        {'tag': 'd', 'type': 'udp', 'server': '2001:db8::1', 'server_port': 5353},
      );
    });

    test('https 的 IPv6 地址去掉方括号', () {
      expect(
        upgradeOne({'tag': 'd', 'address': 'https://[2001:db8::1]/dns-query'}),
        {'tag': 'd', 'type': 'https', 'server': '2001:db8::1'},
      );
    });

    test('local', () {
      expect(upgradeOne({'tag': 'sys', 'address': 'local'}), {'tag': 'sys', 'type': 'local'});
    });

    test('dhcp：auto 不写 interface，指定网卡写进 interface', () {
      expect(upgradeOne({'tag': 'd', 'address': 'dhcp://auto'}), {'tag': 'd', 'type': 'dhcp'});
      expect(
        upgradeOne({'tag': 'd', 'address': 'dhcp://en0'}),
        {'tag': 'd', 'type': 'dhcp', 'interface': 'en0'},
      );
    });

    test('fakeip：地址段取自旧的 dns.fakeip，dns.fakeip 本身去掉', () {
      final upgraded = SingBoxLegacyUpgrader.upgrade({
        'dns': {
          'servers': [
            {'tag': 'fake', 'address': 'fakeip'},
          ],
          'fakeip': {'enabled': true, 'inet4_range': '198.18.0.0/15', 'inet6_range': 'fc00::/18'},
        },
      });
      final dns = upgraded['dns'] as Map<String, dynamic>;
      expect(dns.containsKey('fakeip'), isFalse);
      expect(dns['servers'], [
        {'tag': 'fake', 'type': 'fakeip', 'inet4_range': '198.18.0.0/15', 'inet6_range': 'fc00::/18'},
      ]);
    });

    test('address_resolver / address_strategy / address_fallback_delay 改成拨号字段', () {
      expect(
        upgradeOne({
          'tag': 'd',
          'address': 'https://dns.example.com/dns-query',
          'address_resolver': 'local',
          'address_strategy': 'ipv4_only',
          'address_fallback_delay': '300ms',
        }),
        {
          'tag': 'd',
          'type': 'https',
          'server': 'dns.example.com',
          'domain_resolver': {'server': 'local', 'strategy': 'ipv4_only'},
          'fallback_delay': '300ms',
        },
      );
      expect(
        upgradeOne({'tag': 'd', 'address': 'tls://dns.example.com', 'address_resolver': 'local'}),
        {'tag': 'd', 'type': 'tls', 'server': 'dns.example.com', 'domain_resolver': 'local'},
      );
    });

    test('服务器级的 strategy、client_subnet 无法按服务器等价迁移，去掉', () {
      expect(
        upgradeOne({
          'tag': 'd',
          'address': '203.0.113.8',
          'strategy': 'ipv4_only',
          'client_subnet': '192.0.2.0/24',
        }),
        {'tag': 'd', 'type': 'udp', 'server': '203.0.113.8'},
      );
    });

    test('新写法与认不出的旧写法原样保留，不抛异常', () {
      final servers = [
        {'tag': 'new', 'type': 'https', 'server': '203.0.113.1'},
        {'tag': 'odd', 'address': 'foo://bar'},
      ];
      expect(upgradeServers(servers), servers);
    });
  });

  group('rcode:// 服务器 → DNS 规则的 predefined 动作', () {
    test('服务器去掉；指向它的规则改成 predefined，其它规则不动', () {
      final upgraded = SingBoxLegacyUpgrader.upgrade({
        'dns': {
          'servers': [
            {'tag': 'remote', 'address': 'https://203.0.113.1/dns-query'},
            {'tag': 'block', 'address': 'rcode://success'},
            {'tag': 'deny', 'address': 'rcode://refused'},
          ],
          'rules': [
            {'domain_suffix': ['ads.example.com'], 'server': 'block'},
            {'domain_suffix': ['bad.example.com'], 'action': 'route', 'server': 'deny'},
            {
              'type': 'logical',
              'mode': 'or',
              'rules': [
                {'domain': ['a.example.com']},
              ],
              'server': 'block',
            },
            {'domain_suffix': ['example.org'], 'server': 'remote'},
          ],
        },
      });
      final dns = upgraded['dns'] as Map<String, dynamic>;
      expect((dns['servers'] as List).map((s) => s['tag']), ['remote']);
      expect(dns['rules'], [
        {'domain_suffix': ['ads.example.com'], 'action': 'predefined', 'rcode': 'NOERROR'},
        {'domain_suffix': ['bad.example.com'], 'action': 'predefined', 'rcode': 'REFUSED'},
        {
          'type': 'logical',
          'mode': 'or',
          'rules': [
            {'domain': ['a.example.com']},
          ],
          'action': 'predefined',
          'rcode': 'NOERROR',
        },
        {'domain_suffix': ['example.org'], 'server': 'remote'},
      ]);
    });

    test('六种 rcode 名称对应新写法的字符串', () {
      const names = {
        'success': 'NOERROR',
        'format_error': 'FORMERR',
        'server_failure': 'SERVFAIL',
        'name_error': 'NXDOMAIN',
        'not_implemented': 'NOTIMP',
        'refused': 'REFUSED',
      };
      for (final entry in names.entries) {
        final upgraded = SingBoxLegacyUpgrader.upgrade({
          'dns': {
            'servers': [
              {'tag': 'r', 'address': 'rcode://${entry.key}'},
            ],
            'rules': [
              {'server': 'r'},
            ],
          },
        });
        final rule = ((upgraded['dns'] as Map)['rules'] as List).single;
        expect(rule, {'action': 'predefined', 'rcode': entry.value}, reason: entry.key);
      }
    });
  });

  group('DNS 规则的 outbound 条件 → domain_resolver', () {
    test('outbound: any 的规则去掉，它的 server 成为 route.default_domain_resolver', () {
      final upgraded = SingBoxLegacyUpgrader.upgrade({
        'dns': {
          'servers': [
            {'tag': 'local', 'type': 'udp', 'server': '198.51.100.5'},
          ],
          'rules': [
            {'outbound': ['any'], 'server': 'local'},
            {'clash_mode': 'global', 'server': 'remote'},
          ],
        },
        'route': {'rules': []},
      });
      expect((upgraded['dns'] as Map)['rules'], [
        {'clash_mode': 'global', 'server': 'remote'},
      ]);
      expect((upgraded['route'] as Map)['default_domain_resolver'], 'local');
    });

    test('outbound 写成字符串也认；已有 default_domain_resolver 时不覆盖', () {
      final upgraded = SingBoxLegacyUpgrader.upgrade({
        'dns': {
          'rules': [
            {'outbound': 'any', 'server': 'local'},
          ],
        },
        'route': {'default_domain_resolver': 'system'},
      });
      expect((upgraded['dns'] as Map)['rules'], isEmpty);
      expect((upgraded['route'] as Map)['default_domain_resolver'], 'system');
    });

    test('指定出站的 outbound 条件：规则去掉，对应出站没写 domain_resolver 时补上', () {
      final upgraded = SingBoxLegacyUpgrader.upgrade({
        'dns': {
          'rules': [
            {'outbound': ['node-a'], 'server': 'local'},
          ],
        },
        'outbounds': [
          {'tag': 'node-a', 'type': 'trojan', 'server': 'a.example.com', 'server_port': 443},
          {'tag': 'node-b', 'type': 'trojan', 'server': 'b.example.com', 'server_port': 443, 'domain_resolver': 'other'},
        ],
      });
      expect((upgraded['dns'] as Map)['rules'], isEmpty);
      final outbounds = upgraded['outbounds'] as List;
      expect(outbounds[0]['domain_resolver'], 'local');
      expect(outbounds[1]['domain_resolver'], 'other');
    });

    test('没有 outbound 条件的规则不动', () {
      final rules = [
        {'domain_suffix': ['example.org'], 'server': 'remote'},
        {'query_type': ['HTTPS'], 'action': 'predefined', 'rcode': 'NOERROR'},
      ];
      final upgraded = SingBoxLegacyUpgrader.upgrade({
        'dns': {'rules': rules},
      });
      expect((upgraded['dns'] as Map)['rules'], rules);
    });
  });

  group('升级层的边界', () {
    test('不改调用方传进来的 Map', () {
      final input = {
        'dns': {
          'servers': [
            {'tag': 'remote', 'address': 'https://203.0.113.1/dns-query'},
          ],
          'rules': [
            {'outbound': ['any'], 'server': 'remote'},
          ],
        },
        'route': <String, dynamic>{},
      };
      final before = jsonEncode(input);
      SingBoxLegacyUpgrader.upgrade(input);
      expect(jsonEncode(input), before);
    });

    test('没有 dns 段、字段类型不对时原样返回', () {
      final noDns = {
        'outbounds': [
          {'tag': 'direct', 'type': 'direct'},
        ],
      };
      expect(SingBoxLegacyUpgrader.upgrade(noDns), noDns);
      final oddDns = {
        'dns': {'servers': 'not-a-list', 'rules': 1},
      };
      expect(SingBoxLegacyUpgrader.upgrade(oddDns), oddDns);
    });
  });

  group('服务器的 detour 指向空 direct 出站', () {
    test('detour 指向只有 type 与 tag 的 direct：升级后不带 detour（local 与远程类型）', () {
      final servers = upgradeConfig({
        'dns': {
          'servers': [
            {'tag': 'local', 'address': 'https://198.51.100.5/dns-query', 'detour': 'direct'},
            {'tag': 'sys', 'address': 'local', 'detour': 'direct'},
          ],
        },
        'outbounds': [
          {'tag': 'proxy', 'type': 'selector', 'outbounds': ['node-a']},
          {'tag': 'direct', 'type': 'direct'},
        ],
      });
      expect(servers, [
        {'tag': 'local', 'type': 'https', 'server': '198.51.100.5'},
        {'tag': 'sys', 'type': 'local'},
      ]);
    });

    test('detour 指向带拨号字段的 direct：保留', () {
      final servers = upgradeConfig({
        'dns': {
          'servers': [
            {'tag': 'local', 'address': '192.0.2.53', 'detour': 'direct'},
          ],
        },
        'outbounds': [
          {'tag': 'direct', 'type': 'direct', 'bind_interface': 'en0'},
        ],
      });
      expect(servers.single['detour'], 'direct');
    });

    test('direct 的时长字段写零值、domain_strategy 写 as_is：内核仍按空 direct 处理，去掉 detour', () {
      // 内核里这些是非指针字段，"0s"、"0"、"0h0m0s" 换算成 0，as_is 是 domain_strategy 的零值
      for (final field in <String, Object>{
        'connect_timeout': '0s',
        'tcp_keep_alive': '0',
        'tcp_keep_alive_interval': '0h0m0s',
        'fallback_delay': '0ms',
        'domain_strategy': 'as_is',
      }.entries) {
        final servers = upgradeConfig({
          'dns': {
            'servers': [
              {'tag': 'local', 'address': '192.0.2.53', 'detour': 'direct'},
            ],
          },
          'outbounds': [
            {'tag': 'direct', 'type': 'direct', field.key: field.value},
          ],
        });
        expect(servers.single.containsKey('detour'), isFalse, reason: '${field.key}: ${field.value}');
      }
    });

    test('direct 的时长字段写非零值：保留 detour；domain_strategy 写别的策略：模型不保留该字段，去掉 detour', () {
      for (final field in <String, Object>{
        'connect_timeout': '5s',
        'fallback_delay': '300ms',
        'domain_strategy': 'prefer_ipv4',
      }.entries) {
        final servers = upgradeConfig({
          'dns': {
            'servers': [
              {'tag': 'local', 'address': '192.0.2.53', 'detour': 'direct'},
            ],
          },
          'outbounds': [
            {'tag': 'direct', 'type': 'direct', field.key: field.value},
          ],
        });
        expect(
          servers.single['detour'],
          field.key == 'domain_strategy' ? isNull : 'direct',
          reason: '${field.key}: ${field.value}',
        );
      }
    });

    test('detour 指向代理出站、或订阅里找不到该出站：保留', () {
      final servers = upgradeConfig({
        'dns': {
          'servers': [
            {'tag': 'remote', 'address': 'tls://192.0.2.53', 'detour': 'proxy'},
            {'tag': 'other', 'address': 'tcp://192.0.2.54', 'detour': 'missing'},
          ],
        },
        'outbounds': [
          {'tag': 'proxy', 'type': 'selector', 'outbounds': ['node-a']},
          {'tag': 'direct', 'type': 'direct'},
        ],
      });
      expect(servers.map((s) => s['detour']), ['proxy', 'missing']);
    });

    test('已写 type 的新写法服务器不动', () {
      final server = {'tag': 'local', 'type': 'udp', 'server': '192.0.2.53', 'detour': 'direct'};
      final servers = upgradeConfig({
        'dns': {
          'servers': [server],
        },
        'outbounds': [
          {'tag': 'direct', 'type': 'direct'},
        ],
      });
      expect(servers, [server]);
    });
  });

  group('没有 detour 的服务器改用 1.13 的默认出站', () {
    Map<String, dynamic> config(List<Map<String, dynamic>> outbounds, {Object? route}) => {
      'dns': {
        'servers': [
          {'tag': 'remote', 'address': 'https://192.0.2.53/dns-query'},
          {'tag': 'sys', 'address': 'local'},
          {'tag': 'empty', 'address': '192.0.2.54', 'detour': ''},
        ],
      },
      'outbounds': outbounds,
      'route': ?route,
    };
    final proxyFirst = [
      {'tag': 'proxy', 'type': 'selector', 'outbounds': ['node-a', 'node-b']},
      {'tag': 'node-a', 'type': 'trojan', 'server': 'a.example.com', 'server_port': 443},
      {'tag': 'direct', 'type': 'direct'},
    ];

    test('route.final 指向存在的出站：detour 为该出站', () {
      final servers = upgradeConfig(config(proxyFirst, route: {'final': 'node-a'}));
      expect(servers.map((s) => s['detour']), ['node-a', 'node-a', 'node-a']);
    });

    test('没有 route.final 或它指向不存在的出站：detour 为第一个出站', () {
      expect(
        upgradeConfig(config(proxyFirst)).map((s) => s['detour']),
        ['proxy', 'proxy', 'proxy'],
      );
      expect(
        upgradeConfig(config(proxyFirst, route: {'final': 'missing'})).map((s) => s['detour']),
        ['proxy', 'proxy', 'proxy'],
      );
    });

    test('默认出站是空 direct：不写 detour；带拨号字段的 direct：写 detour', () {
      final emptyDirect = upgradeConfig(config(proxyFirst, route: {'final': 'direct'}));
      expect(emptyDirect.where((s) => (s as Map).containsKey('detour')), isEmpty);
      final boundDirect = upgradeConfig(config([
        {'tag': 'direct', 'type': 'direct', 'bind_interface': 'en0'},
        ...proxyFirst,
      ]));
      expect(boundDirect.map((s) => s['detour']), ['direct', 'direct', 'direct']);
    });

    test('确定不了默认出站（没有 outbounds、第一个出站没有 tag）：不写 detour', () {
      final noOutbounds = upgradeConfig(config([]));
      expect(noOutbounds.where((s) => (s as Map).containsKey('detour')), isEmpty);
      final untagged = upgradeConfig(config([
        {'type': 'trojan', 'server': 'a.example.com', 'server_port': 443},
        ...proxyFirst,
      ]));
      expect(untagged.where((s) => (s as Map).containsKey('detour')), isEmpty);
    });

    test('dhcp、fakeip 不加 detour', () {
      final servers = upgradeConfig({
        'dns': {
          'servers': [
            {'tag': 'd', 'address': 'dhcp://auto'},
            {'tag': 'fake', 'address': 'fakeip'},
          ],
        },
        'outbounds': proxyFirst,
      });
      expect(servers, [
        {'tag': 'd', 'type': 'dhcp'},
        {'tag': 'fake', 'type': 'fakeip'},
      ]);
    });
  });

  group('没有 tag 的旧写法服务器补上 tag', () {
    test('按升级后列表里的下标命名（远程类型与 local）', () {
      final servers = upgradeServers([
        {'address': '192.0.2.53'},
        {'tag': null, 'address': 'local'},
      ]);
      expect(servers, [
        {'tag': '0', 'type': 'udp', 'server': '192.0.2.53'},
        {'tag': '1', 'type': 'local'},
      ]);
    });

    test('下标与已有 tag 冲突时换一个不冲突的值；有 tag 的不变', () {
      final servers = upgradeServers([
        {'tag': '1', 'address': '192.0.2.1'},
        {'address': '192.0.2.53'},
        {'tag': '1-1', 'type': 'udp', 'server': '192.0.2.2'},
      ]);
      final tags = servers.map((s) => s['tag']).toList();
      expect(tags[0], '1');
      expect(tags[2], '1-1');
      expect(tags[1], isA<String>());
      expect(tags.toSet().length, tags.length, reason: '$tags');
    });

    test('新写法的无标签服务器不动', () {
      final server = {'type': 'udp', 'server': '192.0.2.53'};
      expect(upgradeServers([server]), [server]);
    });
  });

  group('any 规则之后的具体出站规则不再写 domain_resolver', () {
    List<Map<String, dynamic>> outbounds() => [
      {'tag': 'node-a', 'type': 'trojan', 'server': 'a.example.com', 'server_port': 443},
      {'tag': 'node-b', 'type': 'trojan', 'server': 'b.example.com', 'server_port': 443},
    ];

    test('any 在前：后面的具体出站规则不生效', () {
      final upgraded = SingBoxLegacyUpgrader.upgrade({
        'dns': {
          'rules': [
            {'outbound': 'any', 'server': 'first'},
            {'outbound': ['node-a'], 'server': 'second'},
          ],
        },
        'outbounds': outbounds(),
        'route': <String, dynamic>{},
      });
      expect((upgraded['route'] as Map)['default_domain_resolver'], 'first');
      expect((upgraded['outbounds'] as List).where((o) => (o as Map).containsKey('domain_resolver')), isEmpty);
      expect((upgraded['dns'] as Map)['rules'], isEmpty);
    });

    test('any 在后：前面的具体出站规则照常写', () {
      final upgraded = SingBoxLegacyUpgrader.upgrade({
        'dns': {
          'rules': [
            {'outbound': ['node-a'], 'server': 'second'},
            {'outbound': 'any', 'server': 'first'},
            {'outbound': ['node-b'], 'server': 'third'},
          ],
        },
        'outbounds': outbounds(),
        'route': <String, dynamic>{},
      });
      expect((upgraded['route'] as Map)['default_domain_resolver'], 'first');
      final result = upgraded['outbounds'] as List;
      expect(result[0]['domain_resolver'], 'second');
      expect((result[1] as Map).containsKey('domain_resolver'), isFalse);
    });
  });

  group('带其他条件或空 outbound 的 DNS 规则', () {
    test('outbound 之外还有别的条件：规则去掉，不写任何 domain_resolver', () {
      final upgraded = SingBoxLegacyUpgrader.upgrade({
        'dns': {
          'rules': [
            {'outbound': 'any', 'domain_suffix': ['example.com'], 'server': 'local'},
            {'outbound': ['node-a'], 'domain_suffix': ['example.com'], 'server': 'local'},
            {'domain_suffix': ['example.org'], 'server': 'remote'},
          ],
        },
        'outbounds': [
          {'tag': 'node-a', 'type': 'trojan', 'server': 'a.example.com', 'server_port': 443},
        ],
        'route': <String, dynamic>{},
      });
      expect((upgraded['dns'] as Map)['rules'], [
        {'domain_suffix': ['example.org'], 'server': 'remote'},
      ]);
      expect((upgraded['route'] as Map).containsKey('default_domain_resolver'), isFalse);
      expect(((upgraded['outbounds'] as List).single as Map).containsKey('domain_resolver'), isFalse);
    });

    test('outbound 是空列表或 null：只去掉 outbound 键，规则保留', () {
      final upgraded = SingBoxLegacyUpgrader.upgrade({
        'dns': {
          'rules': [
            {'outbound': [], 'domain_suffix': ['example.com'], 'server': 'local'},
            {'outbound': null, 'domain_suffix': ['example.net'], 'server': 'local'},
          ],
        },
        'route': <String, dynamic>{},
      });
      expect((upgraded['dns'] as Map)['rules'], [
        {'domain_suffix': ['example.com'], 'server': 'local'},
        {'domain_suffix': ['example.net'], 'server': 'local'},
      ]);
      expect((upgraded['route'] as Map).containsKey('default_domain_resolver'), isFalse);
    });

    test('逻辑规则的子规则（任意深度）带 outbound 条件：整条去掉，不写解析器', () {
      final upgraded = SingBoxLegacyUpgrader.upgrade({
        'dns': {
          'rules': [
            {
              'type': 'logical',
              'mode': 'and',
              'rules': [
                {'outbound': 'any'},
                {'domain_suffix': ['example.com']},
              ],
              'server': 'local',
            },
            {
              'type': 'logical',
              'mode': 'or',
              'rules': [
                {
                  'type': 'logical',
                  'mode': 'and',
                  'rules': [
                    {'outbound': ['node-a']},
                  ],
                },
                {'domain_suffix': ['example.net']},
              ],
              'server': 'local',
            },
            {
              'type': 'logical',
              'mode': 'or',
              'rules': [
                {'outbound': [], 'domain_suffix': ['example.org']},
              ],
              'server': 'remote',
            },
          ],
        },
        'route': <String, dynamic>{},
      });
      expect((upgraded['dns'] as Map)['rules'], [
        {
          'type': 'logical',
          'mode': 'or',
          'rules': [
            {'domain_suffix': ['example.org']},
          ],
          'server': 'remote',
        },
      ]);
      expect((upgraded['route'] as Map).containsKey('default_domain_resolver'), isFalse);
    });

    test('纯 outbound 规则照旧迁移', () {
      final upgraded = SingBoxLegacyUpgrader.upgrade({
        'dns': {
          'rules': [
            {'outbound': ['any'], 'action': 'route', 'server': 'local'},
          ],
        },
        'route': <String, dynamic>{},
      });
      expect((upgraded['dns'] as Map)['rules'], isEmpty);
      expect((upgraded['route'] as Map)['default_domain_resolver'], 'local');
    });
  });

  group('outbound 规则的 rewrite_ttl / client_subnet / disable_cache 保留', () {
    test('带这几个字段时 domain_resolver 写成对象，不带时仍写字符串', () {
      final upgraded = SingBoxLegacyUpgrader.upgrade({
        'dns': {
          'rules': [
            {'outbound': ['node-a'], 'server': 'local', 'disable_cache': true},
            {'outbound': ['node-b'], 'server': 'local'},
            {'outbound': 'any', 'server': 'local', 'rewrite_ttl': 60, 'client_subnet': '192.0.2.0/24'},
          ],
        },
        'outbounds': [
          {'tag': 'node-a', 'type': 'trojan', 'server': 'a.example.com', 'server_port': 443},
          {'tag': 'node-b', 'type': 'trojan', 'server': 'b.example.com', 'server_port': 443},
        ],
        'route': <String, dynamic>{},
      });
      final outbounds = upgraded['outbounds'] as List;
      expect(outbounds[0]['domain_resolver'], {'server': 'local', 'disable_cache': true});
      expect(outbounds[1]['domain_resolver'], 'local');
      expect(
        (upgraded['route'] as Map)['default_domain_resolver'],
        {'server': 'local', 'rewrite_ttl': 60, 'client_subnet': '192.0.2.0/24'},
      );
    });
  });

  group('rcode 服务器的识别', () {
    Map<String, dynamic> upgradeRcode(String address, {Object? tag = 'r'}) => SingBoxLegacyUpgrader.upgrade({
      'dns': {
        'servers': [
          {'tag': 'remote', 'address': '192.0.2.53'},
          {'tag': ?tag, 'address': address},
        ],
        'rules': [
          {'domain_suffix': ['example.com'], 'server': 'r'},
        ],
      },
    })['dns'] as Map<String, dynamic>;

    test('协议头大写、主机名后带 / 或查询串：同样识别', () {
      for (final address in ['RCODE://refused', 'rcode://refused/', 'rcode://refused?x=1', 'Rcode://refused#x']) {
        final dns = upgradeRcode(address);
        expect((dns['servers'] as List).map((s) => s['tag']), ['remote'], reason: address);
        expect(dns['rules'], [
          {'domain_suffix': ['example.com'], 'action': 'predefined', 'rcode': 'REFUSED'},
        ], reason: address);
      }
    });

    test('没有 tag 的 rcode 服务器同样去掉', () {
      final dns = upgradeRcode('rcode://success', tag: null);
      expect((dns['servers'] as List).map((s) => s['tag']), ['remote']);
    });

    test('认不出的 rcode 主机名原样保留', () {
      final dns = upgradeRcode('rcode://unknown');
      expect((dns['servers'] as List).last, {'tag': 'r', 'address': 'rcode://unknown'});
    });
  });

  group('改写为 predefined 时去掉 route 动作专用字段', () {
    test('顶层规则与逻辑规则只剩匹配条件与 action、rcode', () {
      final upgraded = SingBoxLegacyUpgrader.upgrade({
        'dns': {
          'servers': [
            {'tag': 'block', 'address': 'rcode://success'},
          ],
          'rules': [
            {
              'domain_suffix': ['ads.example.com'],
              'server': 'block',
              'rewrite_ttl': 60,
              'disable_cache': true,
              'client_subnet': '192.0.2.0/24',
            },
            {
              'type': 'logical',
              'mode': 'or',
              'rules': [
                {'domain': ['a.example.com']},
              ],
              'action': 'route',
              'server': 'block',
              'disable_cache': true,
            },
          ],
        },
      });
      expect((upgraded['dns'] as Map)['rules'], [
        {'domain_suffix': ['ads.example.com'], 'action': 'predefined', 'rcode': 'NOERROR'},
        {
          'type': 'logical',
          'mode': 'or',
          'rules': [
            {'domain': ['a.example.com']},
          ],
          'action': 'predefined',
          'rcode': 'NOERROR',
        },
      ]);
    });
  });

  group('type 为空字符串或 legacy 的旧写法服务器', () {
    test('按旧写法升级（含 rcode 服务器）', () {
      final upgraded = SingBoxLegacyUpgrader.upgrade({
        'dns': {
          'servers': [
            {'type': '', 'tag': 'dns', 'address': '192.0.2.53'},
            {'type': 'legacy', 'tag': 'doh', 'address': 'https://192.0.2.54/dns-query'},
            {'type': '', 'tag': 'block', 'address': 'rcode://success'},
          ],
          'rules': [
            {'domain_suffix': ['ads.example.com'], 'server': 'block'},
          ],
        },
      });
      final dns = upgraded['dns'] as Map;
      expect(dns['servers'], [
        {'tag': 'dns', 'type': 'udp', 'server': '192.0.2.53'},
        {'tag': 'doh', 'type': 'https', 'server': '192.0.2.54'},
      ]);
      expect(dns['rules'], [
        {'domain_suffix': ['ads.example.com'], 'action': 'predefined', 'rcode': 'NOERROR'},
      ]);
    });

    test('其它 type 的服务器原样保留', () {
      final server = {'type': 'udp', 'tag': 'dns', 'address': '192.0.2.53', 'server': '192.0.2.53'};
      expect(upgradeServers([server]), [server]);
    });
  });
}
