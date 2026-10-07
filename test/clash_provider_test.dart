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

  group('ClashProxy.toOutbound - socks5', () {
    test('基本映射：username/password 透传，version 缺省不写，udp 缺省仅 tcp', () {
      final proxy = ClashProxy.fromJson({
        'name': 'sk',
        'type': 'socks5',
        'server': 's.com',
        'port': 1080,
        'username': 'user1',
        'password': 'pass1',
      });
      final o = proxy.toOutbound() as SocksOutbound?;
      expect(o, isNotNull);
      expect(o!.tag, 'sk');
      expect(o.server, 's.com');
      expect(o.serverPort, 1080);
      expect(o.username, 'user1');
      expect(o.password, 'pass1');
      // sing-box version 默认 '5'，Clash 类型恒为 socks5，不显式写
      expect(o.version, isNull);
      // mihomo socks5 的 udp 默认 false → network 仅 tcp
      expect(o.network, 'tcp');
    });

    test('udp: true → network tcp+udp', () {
      final proxy = ClashProxy.fromJson({
        'name': 'sk-u',
        'type': 'socks5',
        'server': 's.com',
        'port': 1080,
        'udp': true,
      });
      final o = proxy.toOutbound() as SocksOutbound?;
      expect(o, isNotNull);
      expect(o!.network, ['tcp', 'udp']);
    });

    test('tls: true → 跳过节点；tls 缺省不跳过（对照证明跳过源于 tls 而非类型不支持）', () {
      final tlsProxy = ClashProxy.fromJson({
        'name': 'sk-tls',
        'type': 'socks5',
        'server': 's.com',
        'port': 1080,
        'tls': true,
      });
      // sing-box socks outbound 无 TLS 能力（dial fields 不含 tls），无法等价表达
      expect(tlsProxy.toOutbound(), isNull);
      final plainProxy = ClashProxy.fromJson({
        'name': 'sk-plain',
        'type': 'socks5',
        'server': 's.com',
        'port': 1080,
      });
      expect(plainProxy.toOutbound(), isNotNull);
    });

    test('无认证时 username/password 为 null 且序列化省略', () {
      final proxy = ClashProxy.fromJson({
        'name': 'sk-anon',
        'type': 'socks5',
        'server': 's.com',
        'port': 1080,
      });
      final o = proxy.toOutbound() as SocksOutbound?;
      expect(o, isNotNull);
      expect(o!.username, isNull);
      expect(o.password, isNull);
      final json = o.toJson();
      expect(json.containsKey('username'), isFalse);
      expect(json.containsKey('password'), isFalse);
    });
  });

  group('ClashProxy.toOutbound - http', () {
    test('基本映射：username/password 透传，tls 缺省不启用（纯 HTTP 代理）', () {
      final proxy = ClashProxy.fromJson({
        'name': 'hp',
        'type': 'http',
        'server': 's.com',
        'port': 8080,
        'username': 'user1',
        'password': 'pass1',
      });
      final o = proxy.toOutbound() as HttpOutbound?;
      expect(o, isNotNull);
      expect(o!.tag, 'hp');
      expect(o.server, 's.com');
      expect(o.serverPort, 8080);
      expect(o.username, 'user1');
      expect(o.password, 'pass1');
      // mihomo http 的 tls 可选：未写 → 纯 HTTP 代理，sing-box http outbound 同样支持
      expect(o.tls?.enabled, isFalse);
    });

    test('tls: true → HTTPS 代理：sni/skip-cert-verify/alpn 映射', () {
      final proxy = ClashProxy.fromJson({
        'name': 'hps',
        'type': 'http',
        'server': 's.com',
        'port': 443,
        'tls': true,
        'sni': 'www.apple.com',
        'skip-cert-verify': true,
        'alpn': ['h2', 'http/1.1'],
      });
      final o = proxy.toOutbound() as HttpOutbound?;
      expect(o, isNotNull);
      expect(o!.tls?.enabled, isTrue);
      expect(o.tls?.serverName, 'www.apple.com');
      expect(o.tls?.insecure, isTrue);
      expect(o.tls?.alpn, ['h2', 'http/1.1']);
    });

    test('无认证时 username/password 为 null 且序列化省略', () {
      final proxy = ClashProxy.fromJson({
        'name': 'hp-anon',
        'type': 'http',
        'server': 's.com',
        'port': 8080,
      });
      final o = proxy.toOutbound() as HttpOutbound?;
      expect(o, isNotNull);
      expect(o!.username, isNull);
      expect(o.password, isNull);
      final json = o.toJson();
      expect(json.containsKey('username'), isFalse);
      expect(json.containsKey('password'), isFalse);
    });
  });

  group('ClashProxy.toOutbound - snell', () {
    /// mihomo wiki 的 snell 完整示例节点（可选字段全开）
    Map<String, dynamic> snellNode(Map<String, dynamic> overrides) => {
      'name': 'snell',
      'type': 'snell',
      'server': 'server',
      'port': 44046,
      'psk': 'yourpsk',
      'version': 4,
      ...overrides,
    };

    test('mihomo 文档示例：psk/version/reuse/obfs-opts/udp 全字段映射', () {
      final proxy = ClashProxy.fromJson(snellNode({
        'udp': true,
        'reuse': true,
        'obfs-opts': {'mode': 'http', 'host': 'bing.com'},
      }));
      final o = proxy.toOutbound() as SnellOutbound?;
      expect(o, isNotNull);
      expect(o!.tag, 'snell');
      expect(o.server, 'server');
      expect(o.serverPort, 44046);
      expect(o.version, 4);
      expect(o.psk, 'yourpsk');
      expect(o.reuse, isTrue);
      expect(o.obfsMode, 'http');
      expect(o.obfsHost, 'bing.com');
      // mihomo 仅 v3/4/5 支持 udp；udp: true → tcp+udp
      expect(o.network, ['tcp', 'udp']);
      final json = o.toJson();
      expect(json['type'], 'snell');
      expect(json['version'], 4);
      expect(json['psk'], 'yourpsk');
      expect(json['obfs_mode'], 'http');
      expect(json['obfs_host'], 'bing.com');
    });

    test('version 字符串 "4" 同样接受（订阅中 int/字符串两种写法都常见）', () {
      final proxy = ClashProxy.fromJson(snellNode({'version': '4'}));
      final o = proxy.toOutbound() as SnellOutbound?;
      expect(o, isNotNull);
      expect(o!.version, 4);
    });

    test('version 5 → 降级映射为 v4（mihomo 同款：v5 服务端兼容 v4 客户端）', () {
      final o = ClashProxy.fromJson(snellNode({
        'version': 5,
        'reuse': true,
        'udp': true,
      })).toOutbound() as SnellOutbound?;
      expect(o, isNotNull);
      // 降级后 reuse/udp 按 v4 语义照常生效（mihomo 降级发生在两者判定之前）
      expect(o!.version, 4);
      expect(o.reuse, isTrue);
      expect(o.network, ['tcp', 'udp']);
    });

    test('obfs-opts.mode: tls 透传（官方文档仅列 none/http，但内核 ParseObfsMode 完整支持 tls）', () {
      final o = ClashProxy.fromJson(snellNode({
        'obfs-opts': {'mode': 'tls', 'host': 'cdn.example.com'},
      })).toOutbound() as SnellOutbound?;
      expect(o, isNotNull);
      expect(o!.obfsMode, 'tls');
      expect(o.obfsHost, 'cdn.example.com');
    });

    test('version 1/2/3 与缺省 → 跳过（sing-box outbound 仅 v4/v6；缺省 mihomo 按 v1 老协议跑）', () {
      for (final v in [null, 1, 2, 3]) {
        // v 为 null 时以 null 覆盖模板默认，模拟配置缺失 version
        final node = snellNode({'version': v});
        final o = ClashProxy.fromJson(node).toOutbound();
        expect(o, isNull, reason: 'version: $v');
      }
    });

    test('udp 缺省 → network 仅 tcp（mihomo 默认 false）', () {
      final o = ClashProxy.fromJson(snellNode({})).toOutbound() as SnellOutbound?;
      expect(o, isNotNull);
      expect(o!.network, 'tcp');
    });

    test('obfs-opts 缺省 → 混淆字段 null 且序列化省略', () {
      final o = ClashProxy.fromJson(snellNode({})).toOutbound() as SnellOutbound?;
      expect(o, isNotNull);
      expect(o!.obfsMode, isNull);
      expect(o.obfsHost, isNull);
      final json = o.toJson();
      expect(json.containsKey('obfs_mode'), isFalse);
      expect(json.containsKey('obfs_host'), isFalse);
    });

    test('ports 无法映射（snell schema 无 server_ports），节点保留且不输出', () {
      final o = ClashProxy.fromJson(snellNode({'ports': '114-514'}))
          .toOutbound() as SnellOutbound?;
      expect(o, isNotNull);
      expect(o!.toJson().containsKey('server_ports'), isFalse);
    });
  });
}
