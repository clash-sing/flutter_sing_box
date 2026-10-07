import 'package:flutter_sing_box/src/data/models/clash/clash_dns.dart';
import 'package:material_ui/material_ui.dart';
// 旧拍平模型已删除，gen 生成模型经包级 barrel 导出，直接引入即可
import 'package:flutter_sing_box/flutter_sing_box.dart';
import 'package:yaml/yaml.dart';

/// Converts a Clash-format subscription into a list of [Outbound]s.
class ClashProvider {
  /// Builds a list of [Outbound]s from the Clash-format [yamlMap].
  static (List<Outbound>, DNS?) provide(YamlMap yamlMap) {
    final Map<String, dynamic> clashMap = yamlMap.toMap();
    final clash = Clash.fromJson(clashMap);
    DNS? dns;
    if (clash.dns?.nameserverPolicy != null) {
      dns = DNS()
        ..servers = []
        ..rules = [];
      _fixDns(clash.dns!, dns);
    }

    final List<Outbound> outbounds = [];
    for (var element in clash.proxies) {
      try {
        final outbound = element.toOutbound();
        if (outbound != null) {
          if (dns?.rules case final dnsRules?) {
            // 代理出站均混入 DialerFields；server/domain_resolver 未收敛到
            // 判别基类，server 用同源的 element.server（各分支构造时均透传），
            // domain_resolver 经 DialerFields 模式收窄后写入
            if (outbound case final DialerFields dialer) {
              for (var rule in dnsRules.where((rule) => rule.action == 'evaluate')) {
                if (rule.domainSuffix case final List suffixes when suffixes.isNotEmpty) {
                  for (var domain in suffixes) {
                    if (element.server?.contains(domain) == true) {
                      dialer.domainResolver = rule.server;
                      break;
                    }
                  }
                }
                if (dialer.domainResolver != null) break;
              }
            }
          }
          outbounds.add(outbound);
        } else {
          debugPrint('${element.name} is not support');
        }
      } catch (e) {
        debugPrint('Failed to convert ${element.name} to outbound: $e');
      }
    }
    for (var element in clash.proxyGroups.reversed) {
      final outbound = element.toOutbound();
      if (outbound != null) {
        outbounds.insert(0, outbound);
      } else {
        debugPrint('${element.name} is not support');
      }
    }
    return (outbounds, dns);
  }

  static void _fixDns(ClashDns clashDns, DNS? dns) {
    Map<DNSServer, List<String>> dnsServerToDomain = {};
    int i = 0;
    for (var entry in clashDns.nameserverPolicy!.entries) {
      ++i;
      final uri = Uri.parse(entry.value.first);
      final dnsServer = _policyDnsServer(uri, i);
      if (dnsServerToDomain.containsKey(dnsServer)) {
        dnsServerToDomain[dnsServer]!.add(entry.key);
      } else {
        dnsServerToDomain[dnsServer] = [entry.key];
      }
    }
    for (var entry in dnsServerToDomain.entries) {
      final dnsRuleEvaluate = DNSRule()
        ..action = 'evaluate'
        ..tag = '${entry.key.tag}_rule'
        ..server = entry.key.tag
        ..timeout = '3s'
        ..queryType = ['A', 'AAAA'];
      for (var domain in entry.value) {
        _setDomain(dnsRuleEvaluate, domain);
      }
      final dnsRuleRespond = DNSRule()
        ..action = 'respond'
        ..matchResponse = dnsRuleEvaluate.tag
        ..ipAcceptAny = true
        ..responseRcode = 'NOERROR'
        ..race = true;
      final dnsRuleRoute = DNSRule()
        ..action = 'route'
        ..server = entry.key.tag;
      for (var domain in entry.value) {
        _setDomain(dnsRuleRoute, domain);
      }
      dns?.servers?.add(entry.key);
      dns?.rules?.addAll([dnsRuleEvaluate, dnsRuleRespond, dnsRuleRoute]);
    }
  }

  /// 由 nameserver-policy 项构造 DNS 服务器：按 URI scheme 分发到判别子类；
  /// 未建模 scheme（rcode:// 等）走 [UnknownDnsServer] 原样透传，
  /// 等价旧拍平 Server 的动态 type 写法。
  static DNSServer _policyDnsServer(Uri uri, int i) {
    final tag = 'policy_dns_$i';
    final tls = OutboundTLSOptions()
      ..enabled = true
      ..insecure = true;
    switch (uri.scheme) {
      case 'https':
        return HttpsDNSServer(tag: tag)
          ..server = uri.host
          ..serverPort = uri.port
          ..path = uri.path
          ..domainResolver = 'alidoh'
          ..tls = tls;
      case 'h3':
        return H3DNSServer(tag: tag)
          ..server = uri.host
          ..serverPort = uri.port
          ..path = uri.path
          ..domainResolver = 'alidoh'
          ..tls = tls;
      case 'quic':
        return QuicDNSServer(tag: tag)
          ..server = uri.host
          ..serverPort = uri.port
          ..domainResolver = 'alidoh'
          ..tls = tls;
      case 'tls':
        return TlsDNSServer(tag: tag)
          ..server = uri.host
          ..serverPort = uri.port
          ..domainResolver = 'alidoh'
          ..tls = tls;
      case 'tcp':
        return TcpDNSServer(tag: tag)
          ..server = uri.host
          ..serverPort = uri.port
          ..domainResolver = 'alidoh';
      case 'udp':
        return UdpDNSServer(tag: tag)
          ..server = uri.host
          ..serverPort = uri.port
          ..domainResolver = 'alidoh';
      default:
        return UnknownDnsServer({
          'tag': tag,
          'type': uri.scheme,
          'server': uri.host,
          'server_port': uri.port,
          'path': uri.path,
          'domain_resolver': 'alidoh',
          'tls': {'enabled': true, 'insecure': true},
        });
    }
  }

  static void _setDomain(DNSRule dnsRule, String domain) {
    if (domain.startsWith('+.')) {
      dnsRule.domainSuffix = [..._strList(dnsRule.domainSuffix), domain.replaceFirst('+.', '')];
      return;
    }
    if (domain.startsWith('*.')) {
      dnsRule.domainSuffix = [..._strList(dnsRule.domainSuffix), domain.replaceFirst('*.', '')];
      return;
    }
    if (domain.startsWith('.')) {
      dnsRule.domainSuffix = [..._strList(dnsRule.domainSuffix), domain.replaceFirst('.', '')];
      return;
    }
    if (domain.startsWith('^')) {
      dnsRule.domainRegex = [..._strList(dnsRule.domainRegex), domain];
      return;
    }
    final domainRegex = RegExp(r'^(?:[a-zA-Z0-9-]+\.)+[a-zA-Z]{2,}$');
    if (domainRegex.hasMatch(domain)) {
      dnsRule.domain = [..._strList(dnsRule.domain), domain];
      return;
    } else {
      dnsRule.domainKeyword = [..._strList(dnsRule.domainKeyword), domain];
      return;
    }
  }

  /// 生成模型的域名匹配字段为拍平 Object?（可空并集），按 `List<String>` 视图读取。
  static List<String> _strList(Object? value) =>
      value is List ? value.whereType<String>().toList() : [];
}

/// 端口跳跃语法转 sing-box server_ports 列表。
///
/// 输入语法（mihomo 的 `ports` 字段与 hysteria2/hysteria 分享链接的
/// `mport` 参数一致）：`-` 表范围、`/` 或 `,` 分隔多段、纯数字表单端口，
/// 如 `114-514/810-1919,65530`。
/// sing-box 的 server_ports 每个元素必须是 `start:end`：多段须拆成
/// 多个数组元素（内核不认 `,`/`/`），纯数字单端口会被内核拒绝
/// （"bad port range"），须展开为 `port:port`。
List<String>? toSingBoxServerPorts(String? ports) {
  if (ports == null || ports.isEmpty) return null;
  final segments = ports.split(RegExp('[/,]')).map((e) => e.trim()).where((e) => e.isNotEmpty);
  final result = [
    for (final segment in segments)
      segment.contains('-') ? segment.replaceAll('-', ':') : '$segment:$segment',
  ];
  return result.isEmpty ? null : result;
}

/// Extensions for converting a [ClashProxy] into an [Outbound].
/// TODO: 待实现 snell
extension ClashProxyExt on ClashProxy {
  /// Converts this Clash proxy into a sing-box [Outbound], or `null`
  /// if the proxy type is unsupported.
  Outbound? toOutbound() {
    // SNI：vmess/vless 在 Clash YAML 中为 servername，其余协议为 sni（mihomo TLS 字段定义）；
    // 二者互为兼容别名，缺省回退 server（对齐 mihomo 行为；server 为 IP 时内核不发送 SNI）
    final String sni = this.sni ?? servername ?? server ?? '';
    // 生成子类构造仅收 tag，其余字段语义对应旧拍平构造参数，构造后级联赋值
    Outbound? outbound;
    switch (type) {
      case ClashProxyType.hysteria2:
        outbound = Hysteria2Outbound(tag: name)
          ..server = server
          ..serverPort = port
          ..serverPorts = toSingBoxServerPorts(ports)
          ..password = password
          ..bbrProfile = bbrProfile
          ..upMbps = up
          ..downMbps = down
          ..tls = _toSingBoxTls(
            alpn: alpn ?? ['h3'],
            enabled: true,
            insecure: skipCertVerify,
            disableSni: sni.isEmpty,
            serverName: sni,
            utls: _toSingBoxUtls,
          )
          // obfs 为 schema oneOf 结构，生成物拍平为 Object?，以 map 表达
          ..obfs = obfs?.isNotEmpty == true
              ? {
                  'type': obfs!,
                  'password': ?obfsPassword,
                  'min_packet_size': ?obfsMinPacketSize,
                  'max_packet_size': ?obfsMaxPacketSize,
                }
              : null
          ..realm = realmOpts?.enable == true
              ? (Hysteria2Realm()
                ..serverUrl = realmOpts!.serverUrl
                ..token = realmOpts!.token
                ..realmId = realmOpts!.realmId
                ..stunServers = realmOpts!.stunServers)
              : null;
      case ClashProxyType.hysteria:
        outbound = HysteriaOutbound(tag: name)
          ..server = server
          ..serverPort = port
          ..serverPorts = toSingBoxServerPorts(ports)
          ..authStr = authStr
          ..upMbps = up
          ..downMbps = down
          // 旧模型的 disable_mtu_discovery 已从现版 schema 移除，不再输出
          ..obfs = obfs
          ..tls = _toSingBoxTls(
            alpn: alpn ?? ['hysteria'],
            enabled: true,
            insecure: skipCertVerify,
            disableSni: sni.isEmpty,
            serverName: sni,
            utls: _toSingBoxUtls,
          );
      case ClashProxyType.anytls:
        outbound = AnytlsOutbound(tag: name)
          ..server = server
          ..serverPort = port
          ..password = password
          ..idleSessionCheckInterval = idleSessionCheckInterval != null
              ? '${idleSessionCheckInterval}s'
              : null
          ..idleSessionTimeout = idleSessionTimeout != null ? '${idleSessionTimeout}s' : null
          ..minIdleSession = minIdleSession
          ..clientMetadata = clientMetadata
          ..tls = _toSingBoxTls(
            alpn: alpn,
            enabled: true,
            insecure: skipCertVerify,
            disableSni: sni.isEmpty,
            serverName: sni,
            utls: _toSingBoxUtls,
          );
      case ClashProxyType.trojan:
        outbound = TrojanOutbound(tag: name)
          ..network = _toSingBoxNetwork
          ..server = server
          ..serverPort = port
          ..password = password
          ..tls = _toSingBoxTls(
            alpn: alpn,
            enabled: true,
            insecure: skipCertVerify,
            disableSni: sni.isEmpty,
            serverName: sni,
            utls: _toSingBoxUtls,
          )
          ..transport = _toSingBoxTransport;
      case ClashProxyType.tuic:
        outbound = TuicOutbound(tag: name)
          ..server = server
          ..serverPort = port
          ..uuid = uuid
          ..password = password
          // 旧模型对 tuic 输出的 bbr_profile 不在现版 schema 中，不再输出
          ..zeroRttHandshake = reduceRtt
          ..congestionControl = congestionController
          ..udpRelayMode = udpRelayMode
          ..heartbeat = heartbeatInterval != null ? '${(heartbeatInterval! / 1000)}s' : null
          ..tls = _toSingBoxTls(
            alpn: alpn ?? ['h3'],
            enabled: true,
            insecure: skipCertVerify,
            // tuic 支持显式 disable-sni 字段，未写时默认 false（与其他分支的显式布尔一致）
            disableSni: disableSni ?? false,
            serverName: sni,
          );
      case ClashProxyType.vmess:
        outbound = VmessOutbound(tag: name)
          ..network = _toSingBoxNetwork
          ..server = server
          ..serverPort = port
          ..uuid = uuid
          ..security = cipher
          ..alterId = alterId
          ..globalPadding = globalPadding
          ..authenticatedLength = authenticatedLength
          ..packetEncoding = packetEncoding
          ..tls = _toSingBoxTls(
            alpn: alpn,
            enabled: tls,
            insecure: skipCertVerify,
            disableSni: sni.isEmpty,
            serverName: sni,
            utls: _toSingBoxUtls,
          )
          ..transport = _toSingBoxTransport;
      case ClashProxyType.vless:
        outbound = VlessOutbound(tag: name)
          ..network = _toSingBoxNetwork
          ..server = server
          ..serverPort = port
          ..uuid = uuid
          ..flow = flow
          ..packetEncoding = packetEncoding
          ..tls = _toSingBoxTls(
            alpn: alpn,
            // reality 隐含 TLS：YAML 未写 tls: true 时也要启用
            enabled: (tls ?? false) || realityOpts != null,
            insecure: skipCertVerify,
            disableSni: sni.isEmpty,
            serverName: sni,
            reality: realityOpts?.publicKey != null
                ? (OutboundRealityOptions()
                  ..enabled = true
                  ..publicKey = realityOpts!.publicKey
                  ..shortId = realityOpts?.shortId)
                : null,
            utls: _toSingBoxUtls,
          )
          ..transport = _toSingBoxTransport;
      case ClashProxyType.shadowsocks:
        outbound = ShadowsocksOutbound(tag: name)
          ..network = _toSingBoxNetwork
          ..server = server
          ..serverPort = port
          ..password = password
          ..method = cipher
          ..plugin = _toSingBoxPlugin
          ..pluginOpts = _toSingBoxPluginOpts
          // 旧 UdpOverTcp 对象的等价 map 形态（生成物拍平为 Object?）
          ..udpOverTcp = udpOverTcp != null
              ? {'enabled': udpOverTcp, 'version': udpOverTcpVersion ?? 1}
              : null;
      default:
        break;
    }
    return outbound;
  }

  /// 出站 TLS 配置（字段与旧拍平 Tls 构造一一对应）。
  OutboundTLSOptions _toSingBoxTls({
    Object? alpn,
    required bool? enabled,
    bool? insecure,
    bool? disableSni,
    String? serverName,
    OutboundUTLSOptions? utls,
    OutboundRealityOptions? reality,
  }) =>
      OutboundTLSOptions()
        ..alpn = alpn
        ..enabled = enabled
        ..insecure = insecure
        ..disableSni = disableSni
        ..serverName = serverName
        ..utls = utls
        ..reality = reality;

  /// uTLS 指纹（client-fingerprint 非空时启用）。
  OutboundUTLSOptions? get _toSingBoxUtls =>
      clientFingerprint?.isNotEmpty == true
          ? (OutboundUTLSOptions()
            ..enabled = true
            ..fingerprint = clientFingerprint!)
          : null;

  Object? get _toSingBoxNetwork => udp == true ? ['tcp', 'udp'] : 'tcp';
  V2RayTransport? get _toSingBoxTransport => network == 'tcp'
      ? V2RayTransport(type: 'http')
      : (network?.isNotEmpty == true ? V2RayTransport(type: network!) : null);

  String? get _toSingBoxPlugin {
    if (plugin == 'obfs') {
      return 'obfs-local';
    } else if (plugin == 'v2ray-plugin') {
      return plugin;
    }
    return null;
  }

  String? get _toSingBoxPluginOpts {
    if (pluginOpts == null) return null;
    if (plugin == 'obfs') {
      return 'obfs=http;obfs-host=${pluginOpts!.host ?? ''}';
    } else if (plugin == 'v2ray-plugin') {
      return 'obfs=websocket;obfs-host=${pluginOpts!.host ?? ''}';
    }
    return null;
  }
}

/// Extensions for converting a [ClashGroup] into an [Outbound].
extension ClashGroupExt on ClashGroup {
  String _singBoxInterval() {
    if (interval != null) {
      final int min = interval! ~/ 60;
      return '${min}m';
    } else {
      return '3m';
    }
  }

  /// Converts this Clash group into a sing-box [Outbound], or `null`
  /// if the group type is unsupported.
  Outbound? toOutbound() {
    Outbound? outbound;
    switch (type) {
      case ClashGroupType.select:
        outbound = SelectorOutbound(tag: name)..outbounds = proxies;
      case ClashGroupType.urlTest:
        outbound = UrltestOutbound(tag: name)
          ..outbounds = proxies
          ..url = url
          ..interval = _singBoxInterval()
          ..tolerance = 50
          ..interruptExistConnections = true;
      default:
        break;
    }
    return outbound;
  }
}
