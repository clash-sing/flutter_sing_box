// 旧拍平模型已删除，gen 生成模型经包级 barrel 导出，直接引入即可
import 'package:flutter_sing_box/flutter_sing_box.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ClashProxy.toOutbound - vless reality', () {
    test('reality-opts 映射且 enabled 必须为 true（sing-box 必需字段）', () {
      final proxy = ClashProxy.fromJson({
        'name': 'rv',
        'type': 'vless',
        'server': 's.com',
        'port': 443,
        'uuid': 'u1',
        'flow': 'xtls-rprx-vision',
        'tls': true,
        'sni': 'www.apple.com',
        'client-fingerprint': 'chrome',
        'reality-opts': {'public-key': 'pbk1', 'short-id': 'sid1'},
      });
      final o = proxy.toOutbound() as VlessOutbound?;
      expect(o, isNotNull);
      expect(o!.tls?.enabled, isTrue);
      expect(o.tls?.reality?.enabled, isTrue);
      expect(o.tls?.reality?.publicKey, 'pbk1');
      expect(o.tls?.reality?.shortId, 'sid1');
      expect(o.tls?.utls?.fingerprint, 'chrome');
      expect(o.tls?.serverName, 'www.apple.com');
      expect(o.flow, 'xtls-rprx-vision');
    });

    test('只写 reality-opts 未写 tls: true 时仍启用 TLS', () {
      final proxy = ClashProxy.fromJson({
        'name': 'rv2',
        'type': 'vless',
        'server': 's.com',
        'port': 443,
        'uuid': 'u2',
        'sni': 'www.apple.com',
        'reality-opts': {'public-key': 'pbk2'},
      });
      final o = proxy.toOutbound() as VlessOutbound?;
      expect(o!.tls?.enabled, isTrue);
      expect(o.tls?.reality?.enabled, isTrue);
      expect(o.tls?.reality?.publicKey, 'pbk2');
      // short-id 可选：未提供时保持 null
      expect(o.tls?.reality?.shortId, isNull);
    });

    test('无 reality-opts 且无 tls 时 TLS 不启用（既有行为不回归）', () {
      final proxy = ClashProxy.fromJson({
        'name': 'plain',
        'type': 'vless',
        'server': 's.com',
        'port': 80,
        'uuid': 'u3',
      });
      final o = proxy.toOutbound() as VlessOutbound?;
      expect(o!.tls?.enabled, isFalse);
      expect(o.tls?.reality, isNull);
    });
  });

  group('ClashProxy.toOutbound - hysteria2 ports 端口跳跃', () {
    test('wiki 完整示例：斜杠与逗号分隔的多段范围加单端口', () {
      final proxy = ClashProxy.fromJson({
        'name': 'hy2',
        'type': 'hysteria2',
        'server': 's.com',
        'port': 443,
        'password': 'pwd',
        'ports': '114-514/810-1919,65530',
      });
      final o = proxy.toOutbound() as Hysteria2Outbound?;
      expect(o!.serverPorts, ['114:514', '810:1919', '65530:65530']);
    });

    test('仅逗号分隔的多段', () {
      final proxy = ClashProxy.fromJson({
        'name': 'hy2c',
        'type': 'hysteria2',
        'server': 's.com',
        'port': 443,
        'password': 'pwd',
        'ports': '114-514,810-1919',
      });
      final o = proxy.toOutbound() as Hysteria2Outbound?;
      expect(o!.serverPorts, ['114:514', '810:1919']);
    });

    test('单个端口范围（既有行为不回归）', () {
      final proxy = ClashProxy.fromJson({
        'name': 'hy2r',
        'type': 'hysteria2',
        'server': 's.com',
        'port': 443,
        'password': 'pwd',
        'ports': '114-514',
      });
      final o = proxy.toOutbound() as Hysteria2Outbound?;
      expect(o!.serverPorts, ['114:514']);
    });

    test('单个端口号转为 start:end（sing-box 拒绝纯数字）', () {
      final proxy = ClashProxy.fromJson({
        'name': 'hy2s',
        'type': 'hysteria2',
        'server': 's.com',
        'port': 443,
        'password': 'pwd',
        'ports': '65530',
      });
      final o = proxy.toOutbound() as Hysteria2Outbound?;
      expect(o!.serverPorts, ['65530:65530']);
    });

    test('空段被忽略', () {
      final proxy = ClashProxy.fromJson({
        'name': 'hy2e',
        'type': 'hysteria2',
        'server': 's.com',
        'port': 443,
        'password': 'pwd',
        'ports': '114-514,,65530/',
      });
      final o = proxy.toOutbound() as Hysteria2Outbound?;
      expect(o!.serverPorts, ['114:514', '65530:65530']);
    });

    test('未配置 ports 时 server_ports 为 null（既有行为不回归）', () {
      final proxy = ClashProxy.fromJson({
        'name': 'hy2n',
        'type': 'hysteria2',
        'server': 's.com',
        'port': 443,
        'password': 'pwd',
      });
      final o = proxy.toOutbound() as Hysteria2Outbound?;
      expect(o!.serverPorts, isNull);
    });

    test('hysteria 分支沿用同一转换', () {
      final proxy = ClashProxy.fromJson({
        'name': 'hy1',
        'type': 'hysteria',
        'server': 's.com',
        'port': 443,
        'ports': '114-514/810-1919,65530',
      });
      final o = proxy.toOutbound() as HysteriaOutbound?;
      expect(o!.serverPorts, ['114:514', '810:1919', '65530:65530']);
    });
  });

  group('ClashProxy.toOutbound - hysteria 默认 alpn', () {
    test('hysteria 无 alpn 默认 hysteria（v1 协议要求，对齐 mihomo）', () {
      final proxy = ClashProxy.fromJson({
        'name': 'hy1a',
        'type': 'hysteria',
        'server': 's.com',
        'port': 443,
      });
      final o = proxy.toOutbound() as HysteriaOutbound?;
      expect(o!.tls?.alpn, ['hysteria']);
    });

    test('hysteria2 无 alpn 默认 h3（既有行为不回归）', () {
      final proxy = ClashProxy.fromJson({
        'name': 'hy2a',
        'type': 'hysteria2',
        'server': 's.com',
        'port': 443,
        'password': 'pwd',
      });
      final o = proxy.toOutbound() as Hysteria2Outbound?;
      expect(o!.tls?.alpn, ['h3']);
    });
  });

  group('ClashProxy.toOutbound - SNI 解析（sni/servername/server 回退）', () {
    test('vmess：servername 生效（mihomo TLS 字段）', () {
      final proxy = ClashProxy.fromJson({
        'name': 'vm',
        'type': 'vmess',
        'server': '1.2.3.4',
        'port': 443,
        'uuid': 'u1',
        'tls': true,
        'servername': 'cdn.example.com',
      });
      final o = proxy.toOutbound() as VmessOutbound?;
      expect(o!.tls?.serverName, 'cdn.example.com');
      expect(o.tls?.disableSni, isFalse);
    });

    test('vless：servername 生效', () {
      final proxy = ClashProxy.fromJson({
        'name': 'vl',
        'type': 'vless',
        'server': '1.2.3.4',
        'port': 443,
        'uuid': 'u2',
        'tls': true,
        'servername': 'cdn.example.com',
      });
      final o = proxy.toOutbound() as VlessOutbound?;
      expect(o!.tls?.serverName, 'cdn.example.com');
      expect(o.tls?.disableSni, isFalse);
    });

    test('trojan：servername 兼容（老 Clash 生态写法）', () {
      final proxy = ClashProxy.fromJson({
        'name': 'tj',
        'type': 'trojan',
        'server': '1.2.3.4',
        'port': 443,
        'password': 'pwd',
        'servername': 'cdn.example.com',
      });
      final o = proxy.toOutbound() as TrojanOutbound?;
      expect(o!.tls?.serverName, 'cdn.example.com');
      expect(o.tls?.disableSni, isFalse);
    });

    test('sni 与 servername 并存时 sni 优先（mihomo 一般协议字段）', () {
      final proxy = ClashProxy.fromJson({
        'name': 'both',
        'type': 'vmess',
        'server': '1.2.3.4',
        'port': 443,
        'uuid': 'u3',
        'tls': true,
        'sni': 'from-sni.com',
        'servername': 'from-servername.com',
      });
      final o = proxy.toOutbound() as VmessOutbound?;
      expect(o!.tls?.serverName, 'from-sni.com');
    });

    test('vmess 无 SNI 时回退 server', () {
      final proxy = ClashProxy.fromJson({
        'name': 'vmn',
        'type': 'vmess',
        'server': 'vm.com',
        'port': 443,
        'uuid': 'u4',
        'tls': true,
      });
      final o = proxy.toOutbound() as VmessOutbound?;
      expect(o!.tls?.serverName, 'vm.com');
      expect(o.tls?.disableSni, isFalse);
    });

    test('trojan 无 SNI 时回退 server', () {
      final proxy = ClashProxy.fromJson({
        'name': 'tjn',
        'type': 'trojan',
        'server': 'tj.com',
        'port': 443,
        'password': 'pwd',
      });
      final o = proxy.toOutbound() as TrojanOutbound?;
      expect(o!.tls?.serverName, 'tj.com');
      expect(o.tls?.disableSni, isFalse);
    });

    test('hysteria2 无 SNI 时回退 server', () {
      final proxy = ClashProxy.fromJson({
        'name': 'hy2s',
        'type': 'hysteria2',
        'server': 'hy2.com',
        'port': 443,
        'password': 'pwd',
      });
      final o = proxy.toOutbound() as Hysteria2Outbound?;
      expect(o!.tls?.serverName, 'hy2.com');
      expect(o.tls?.disableSni, isFalse);
    });

    test('tuic：显式 disable-sni 保留，无 SNI 时 serverName 回退 server', () {
      final disabled = ClashProxy.fromJson({
        'name': 'tc1',
        'type': 'tuic',
        'server': 'tc.com',
        'port': 443,
        'uuid': 'u5',
        'password': 'pwd',
        'disable-sni': true,
      });
      expect((disabled.toOutbound() as TuicOutbound?)!.tls?.disableSni, isTrue);

      final fallback = ClashProxy.fromJson({
        'name': 'tc2',
        'type': 'tuic',
        'server': 'tc.com',
        'port': 443,
        'uuid': 'u6',
        'password': 'pwd',
      });
      final o = fallback.toOutbound() as TuicOutbound?;
      expect(o!.tls?.serverName, 'tc.com');
      expect(o.tls?.disableSni, isFalse);
    });

    test('sni 显式空串时不发送 SNI', () {
      final proxy = ClashProxy.fromJson({
        'name': 'empty',
        'type': 'trojan',
        'server': 'e.com',
        'port': 443,
        'password': 'pwd',
        'sni': '',
      });
      final o = proxy.toOutbound() as TrojanOutbound?;
      expect(o!.tls?.serverName, '');
      expect(o.tls?.disableSni, isTrue);
    });
  });

  group('ClashProxy.toOutbound - network → transport 映射', () {
    /// vmess 节点模板：可覆盖 network 与各 *-opts
    Map<String, dynamic> vmessNode(Map<String, dynamic> overrides) => {
      'name': 'n',
      'type': 'vmess',
      'server': 's.com',
      'port': 443,
      'uuid': 'u',
      ...overrides,
    };

    test('network 省略 → 裸 TCP，transport 不写（原误映射 http）', () {
      final o = ClashProxy.fromJson(vmessNode({})).toOutbound() as VmessOutbound?;
      expect(o!.transport, isNull);
    });

    test("network: 'tcp' → transport 不写", () {
      final o = ClashProxy.fromJson(vmessNode({'network': 'tcp'})).toOutbound()
          as VmessOutbound?;
      expect(o!.transport, isNull);
    });

    test("network: 'h2' → type http + host 数组直传 + path 取首个非空", () {
      final o = ClashProxy.fromJson(vmessNode({
        'network': 'h2',
        'h2-opts': {'host': ['h1.com', 'h2.com'], 'path': ['/p1', '/p2']},
      })).toOutbound() as VmessOutbound?;
      expect(o!.transport?.type, 'http');
      expect(o.transport?.host, ['h1.com', 'h2.com']);
      expect(o.transport?.path, '/p1');
    });

    test("network: 'h2' 未写 tls → 强制启用 TLS（h2 依赖 TLS 协商）", () {
      final o = ClashProxy.fromJson(vmessNode({'network': 'h2'})).toOutbound()
          as VmessOutbound?;
      expect(o!.tls?.enabled, isTrue);
    });

    test("network: 'h2' 显式 tls: false → 仍强制启用", () {
      final o = ClashProxy.fromJson(vmessNode({'network': 'h2', 'tls': false}))
          .toOutbound() as VmessOutbound?;
      expect(o!.tls?.enabled, isTrue);
    });

    test("network: 'ws' → type ws + path + Host 头归一列表", () {
      final o = ClashProxy.fromJson(vmessNode({
        'network': 'ws',
        'ws-opts': {
          'path': '/ws',
          'headers': {'Host': 'cdn.com'},
        },
      })).toOutbound() as VmessOutbound?;
      expect(o!.transport?.type, 'ws');
      expect(o.transport?.path, '/ws');
      expect(o.transport?.headers?.entries['Host'], ['cdn.com']);
    });

    test('ws path 内嵌 ?ed=2048 → 拆出 max_early_data + 默认头 + 干净 path', () {
      final o = ClashProxy.fromJson(vmessNode({
        'network': 'ws',
        'ws-opts': {'path': '/ws?ed=2048'},
      })).toOutbound() as VmessOutbound?;
      expect(o!.transport?.path, '/ws');
      expect(o.transport?.maxEarlyData, 2048);
      expect(o.transport?.earlyDataHeaderName, 'Sec-WebSocket-Protocol');
    });

    test('ws path 内嵌 ed 覆盖显式 max-early-data（同配置两形态归一）', () {
      final o = ClashProxy.fromJson(vmessNode({
        'network': 'ws',
        'ws-opts': {'path': '/a?ed=1024', 'max-early-data': 4096},
      })).toOutbound() as VmessOutbound?;
      expect(o!.transport?.path, '/a');
      expect(o.transport?.maxEarlyData, 1024);
    });

    test('ws 显式 max-early-data 未写头 → 补默认 Sec-WebSocket-Protocol', () {
      final o = ClashProxy.fromJson(vmessNode({
        'network': 'ws',
        'ws-opts': {'path': '/w', 'max-early-data': 2048},
      })).toOutbound() as VmessOutbound?;
      expect(o!.transport?.maxEarlyData, 2048);
      expect(o.transport?.earlyDataHeaderName, 'Sec-WebSocket-Protocol');
    });

    test('ws 显式 early-data-header-name 时保留用户值', () {
      final o = ClashProxy.fromJson(vmessNode({
        'network': 'ws',
        'ws-opts': {
          'path': '/w',
          'max-early-data': 2048,
          'early-data-header-name': 'X-Ed',
        },
      })).toOutbound() as VmessOutbound?;
      expect(o!.transport?.earlyDataHeaderName, 'X-Ed');
    });

    test('ws path 无 ed 参数时原样保留（含其他 query）', () {
      final o = ClashProxy.fromJson(vmessNode({
        'network': 'ws',
        'ws-opts': {'path': '/w?foo=1'},
      })).toOutbound() as VmessOutbound?;
      expect(o!.transport?.path, '/w?foo=1');
      expect(o.transport?.maxEarlyData, isNull);
    });

    test('ws + v2ray-http-upgrade: true → httpupgrade 独立类型', () {
      final o = ClashProxy.fromJson(vmessNode({
        'network': 'ws',
        'ws-opts': {
          'path': '/up',
          'v2ray-http-upgrade': true,
          'headers': {'Host': 'h.com'},
        },
      })).toOutbound() as VmessOutbound?;
      expect(o!.transport?.type, 'httpupgrade');
      expect(o.transport?.path, '/up');
      expect(o.transport?.host, 'h.com');
    });

    test("network: 'grpc' → service_name", () {
      final o = ClashProxy.fromJson(vmessNode({
        'network': 'grpc',
        'grpc-opts': {'grpc-service-name': 'svc'},
      })).toOutbound() as VmessOutbound?;
      expect(o!.transport?.type, 'grpc');
      expect(o.transport?.serviceName, 'svc');
    });

    test("network: 'http' → method + path 取首值 + Host → host + 其余头保留", () {
      final o = ClashProxy.fromJson(vmessNode({
        'network': 'http',
        'http-opts': {
          'method': 'GET',
          'path': ['/a', '/b'],
          'headers': {
            'Host': ['hh.com'],
            'X-Foo': ['v'],
          },
        },
      })).toOutbound() as VmessOutbound?;
      expect(o!.transport?.type, 'http');
      expect(o.transport?.method, 'GET');
      expect(o.transport?.path, '/a');
      expect(o.transport?.host, ['hh.com']);
      expect(o.transport?.headers?.entries['X-Foo'], ['v']);
      expect(o.transport?.headers?.entries.containsKey('Host'), isFalse);
    });

    test('mkcp / kcp / mekya / xhttp → 节点跳过（sing-box 无对应传输）', () {
      for (final net in ['mkcp', 'kcp', 'mekya', 'xhttp']) {
        final proxy = ClashProxy.fromJson(vmessNode({'network': net}));
        expect(proxy.toOutbound(), isNull, reason: 'network: $net');
      }
    });

    test('未知 network 值按 tcp 处理（mihomo 语义），节点保留', () {
      final o = ClashProxy.fromJson(vmessNode({'network': 'quic'})).toOutbound()
          as VmessOutbound?;
      expect(o, isNotNull);
      expect(o!.transport, isNull);
    });

    test('trojan ws 共用同一转换', () {
      final proxy = ClashProxy.fromJson({
        'name': 'tj',
        'type': 'trojan',
        'server': 's.com',
        'port': 443,
        'password': 'pwd',
        'network': 'ws',
        'ws-opts': {'path': '/tw'},
      });
      final o = proxy.toOutbound() as TrojanOutbound?;
      expect(o!.transport?.type, 'ws');
      expect(o.transport?.path, '/tw');
    });
  });
}
