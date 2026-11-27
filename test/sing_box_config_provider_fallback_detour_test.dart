import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_sing_box/flutter_sing_box.dart' hide Inbound, Outbound, RuleSet, SingBox;
import 'package:flutter_sing_box/src/data/models/singbox/gen/index.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  setUpAll(() async {
    // _fixSingBoxConfig 经 rootBundle 加载内置模板：按 asset key 读仓库内的真实文件
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

  group('回退删组后 DNS 服务器的 detour 仍指向存在的出站', () {
    // tun 入站缺 tag → SingBox.fromJson 失败 → 走 _fixSingBoxConfig 回退路径。
    // 只有一个节点：「自动选择」只剩一个成员被删，「节点选择」随之只剩一个成员被删，
    // 「其他」还有 direct 与 node-a 两个成员，保留下来
    Map<String, dynamic> subscription({
      required List<Map<String, dynamic>> servers,
      Map<String, dynamic> route = const {'rules': []},
      List<Map<String, dynamic>> extraOutbounds = const [],
    }) => {
      'dns': {'servers': servers, 'rules': []},
      'inbounds': [
        {'type': 'tun', 'address': ['172.19.0.1/30'], 'auto_route': true},
      ],
      'outbounds': [
        {'tag': '节点选择', 'type': 'selector', 'outbounds': ['自动选择', 'node-a']},
        {'tag': '自动选择', 'type': 'urltest', 'outbounds': ['node-a']},
        {'tag': '其他', 'type': 'selector', 'outbounds': ['节点选择', 'direct', 'node-a']},
        {'tag': 'node-a', 'type': 'vmess', 'server': 'a.example.com', 'server_port': 1, 'uuid': 'u1'},
        {'tag': 'direct', 'type': 'direct'},
        ...extraOutbounds,
      ],
      'route': route,
    };

    Map<String, dynamic> serverJson(SingBox singBox, String tag) =>
        singBox.dns.servers!.firstWhere((s) => s.tag == tag).toJson();

    void expectDetoursResolve(SingBox singBox) {
      final tags = singBox.outbounds.map((o) => o.tag).toSet();
      for (final server in singBox.dns.servers!) {
        final detour = server.toJson()['detour'];
        if (detour != null) {
          expect(tags, contains(detour), reason: '${server.tag} 的 detour 指向不存在的出站 $detour');
        }
      }
    }

    test('detour 指向被删的组或不存在的出站：改为修正后的 route.final', () async {
      final singBox = await SingBoxConfigProvider.provide(subscription(
        servers: [
          // 订阅原文写的 detour
          {'tag': 'remote', 'address': 'tls://192.0.2.53', 'detour': '节点选择'},
          {'tag': 'lost', 'address': 'tls://192.0.2.54', 'detour': 'missing'},
          // 升级器按 route.final 补写的 detour
          {'tag': 'implicit', 'address': 'tls://192.0.2.55'},
        ],
        route: {'final': '节点选择', 'rules': []},
      ));

      final outboundTags = singBox.outbounds.map((o) => o.tag).toList();
      expect(outboundTags, isNot(contains('节点选择')));
      expect(singBox.route.final_, '其他');
      expectDetoursResolve(singBox);
      expect(serverJson(singBox, 'remote')['detour'], '其他');
      expect(serverJson(singBox, 'lost')['detour'], '其他');
      expect(serverJson(singBox, 'implicit')['detour'], '其他');
    });

    test('detour 指向保留下来的组或节点：不变；没有 detour 的服务器不加', () async {
      final singBox = await SingBoxConfigProvider.provide(subscription(
        servers: [
          {'tag': 'remote', 'address': 'tls://192.0.2.53', 'detour': '其他'},
          {'tag': 'node', 'address': 'tls://192.0.2.54', 'detour': 'node-a'},
          {'tag': 'plain', 'type': 'udp', 'server': '192.0.2.55'},
        ],
      ));

      expectDetoursResolve(singBox);
      expect(serverJson(singBox, 'remote')['detour'], '其他');
      expect(serverJson(singBox, 'node')['detour'], 'node-a');
      expect(serverJson(singBox, 'plain').containsKey('detour'), isFalse);
    });

    test('detour 指向回退时补进来的空 direct：去掉 detour', () async {
      // 订阅没有 direct 出站，升级时找不到 detour 的目标只能原样保留；
      // 回退路径随后补上一个只有 type 与 tag 的 direct，detour 就落在空 direct 上
      final singBox = await SingBoxConfigProvider.provide({
        'dns': {
          'servers': [
            {'tag': 'remote', 'address': 'tls://192.0.2.53', 'detour': 'direct'},
            {'tag': 'plain', 'type': 'udp', 'server': '192.0.2.55', 'detour': 'direct'},
          ],
          'rules': [],
        },
        'inbounds': [
          {'type': 'tun', 'address': ['172.19.0.1/30'], 'auto_route': true},
        ],
        'outbounds': [
          {'tag': 'g', 'type': 'selector', 'outbounds': ['node-a', 'node-b']},
          {'tag': 'node-a', 'type': 'vmess', 'server': 'a.example.com', 'server_port': 1, 'uuid': 'u1'},
          {'tag': 'node-b', 'type': 'vmess', 'server': 'b.example.com', 'server_port': 2, 'uuid': 'u2'},
        ],
        'route': {'rules': []},
      });

      expect(singBox.outbounds.where((o) => o.tag == 'direct'), isNotEmpty, reason: '回退补上了 direct');
      expectDetoursResolve(singBox);
      expect(serverJson(singBox, 'remote').containsKey('detour'), isFalse);
      expect(serverJson(singBox, 'plain').containsKey('detour'), isFalse);
    });

    test('修正后的 route.final 是空 direct：失效的 detour 去掉', () async {
      // 模板的 route.final 是 proxy；订阅里正好有一个 tag 为 proxy 的空 direct，
      // 回退保留它作为 route.final
      final singBox = await SingBoxConfigProvider.provide(subscription(
        servers: [
          {'tag': 'remote', 'address': 'tls://192.0.2.53', 'detour': '节点选择'},
        ],
        extraOutbounds: [
          {'tag': 'proxy', 'type': 'direct'},
        ],
      ));

      expect(singBox.route.final_, 'proxy');
      expectDetoursResolve(singBox);
      expect(serverJson(singBox, 'remote').containsKey('detour'), isFalse);
    });
  });
}
