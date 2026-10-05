import 'package:flutter_sing_box/src/data/models/clash/clash_dns.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_sing_box/flutter_sing_box.dart';
import 'package:yaml/yaml.dart';

/// Converts a Clash-format subscription into a list of [Outbound]s.
class ClashProvider {
  /// Builds a list of [Outbound]s from the Clash-format [yamlMap].
  static (List<Outbound>, Dns?) provide(YamlMap yamlMap) {
    final Map<String, dynamic> clashMap = yamlMap.toMap();
    final clash = Clash.fromJson(clashMap);
    Dns? dns;
    if (clash.dns?.nameserverPolicy != null) {
      dns = Dns(servers: [], rules: []);
      _fixDns(clash.dns!, dns);
    }

    final List<Outbound> outbounds = [];
    for (var element in clash.proxies) {
      try {
        final outbound = element.toOutbound();
        if (outbound != null) {
          if (dns?.rules != null) {
            for (var rule in dns?.rules.where((rule) => rule.action == 'evaluate').toList() ?? []) {
              if (rule.domainSuffix?.isNotEmpty == true) {
                for (var domain in rule.domainSuffix!) {
                  if (outbound.server?.contains(domain) == true) {
                    outbound.domainResolver = rule.server;
                    break;
                  }
                }
              }
              if (outbound.domainResolver != null) break;
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

  static void _fixDns(ClashDns clashDns, Dns? dns) {
    Map<Server, List<String>> dnsServerToDomain = {};
    int i = 0;
    for (var entry in clashDns.nameserverPolicy!.entries) {
      ++i;
      final uri = Uri.parse(entry.value.first);
      Server dnsServer = Server(
        tag: 'policy_dns_$i',
        type: uri.scheme,
        server: uri.host,
        serverPort: uri.port,
        path: uri.path,
        domainResolver: 'alidoh',
        tls: Tls(enabled: true, insecure: true),
      );
      if (dnsServerToDomain.containsKey(dnsServer)) {
        dnsServerToDomain[dnsServer]!.add(entry.key);
      } else {
        dnsServerToDomain[dnsServer] = [entry.key];
      }
    }
    for (var entry in dnsServerToDomain.entries) {
      final dnsRuleEvaluate = DnsRule(
        action: 'evaluate',
        tag: '${entry.key.tag}_rule',
        server: entry.key.tag,
        timeout: '3s',
        queryType: ['A', 'AAAA'],
      );
      for (var domain in entry.value) {
        _setDomain(dnsRuleEvaluate, domain);
      }
      final dnsRuleRespond = DnsRule(
        action: 'respond',
        matchResponse: dnsRuleEvaluate.tag,
        ipAcceptAny: true,
        responseRcode: 'NOERROR',
        race: true,
      );
      final dnsRuleRoute = DnsRule(action: 'route', server: entry.key.tag);
      for (var domain in entry.value) {
        _setDomain(dnsRuleRoute, domain);
      }
      dns?.servers.add(entry.key);
      dns?.rules.addAll([dnsRuleEvaluate, dnsRuleRespond, dnsRuleRoute]);
    }
  }

  static void _setDomain(DnsRule dnsRule, String domain) {
    if (domain.startsWith('+.')) {
      dnsRule.domainSuffix ??= [];
      dnsRule.domainSuffix!.add(domain.replaceFirst('+.', ''));
      return;
    }
    if (domain.startsWith('*.')) {
      dnsRule.domainSuffix ??= [];
      dnsRule.domainSuffix!.add(domain.replaceFirst('*.', ''));
      return;
    }
    if (domain.startsWith('.')) {
      dnsRule.domainSuffix ??= [];
      dnsRule.domainSuffix!.add(domain.replaceFirst('.', ''));
      return;
    }
    if (domain.startsWith('^')) {
      dnsRule.domainRegex ??= [];
      dnsRule.domainRegex!.add(domain);
      return;
    }
    final domainRegex = RegExp(r'^(?:[a-zA-Z0-9-]+\.)+[a-zA-Z]{2,}$');
    if (domainRegex.hasMatch(domain)) {
      dnsRule.domain ??= [];
      dnsRule.domain!.add(domain);
      return;
    } else {
      dnsRule.domainKeyword ??= [];
      dnsRule.domainKeyword!.add(domain);
      return;
    }
  }
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
    final outbound = switch (type) {
      ClashProxyType.hysteria2 => Outbound(
        type: OutboundType.hysteria2,
        tag: name,
        server: server,
        serverPort: port,
        serverPorts: toSingBoxServerPorts(ports),
        password: password,
        bbrProfile: bbrProfile,
        upMbps: up,
        downMbps: down,
        tls: Tls(
          alpn: alpn ?? ['h3'],
          enabled: true,
          insecure: skipCertVerify,
          disableSni: sni.isEmpty,
          serverName: sni,
          utls: clientFingerprint?.isNotEmpty == true
              ? Utls(enabled: true, fingerprint: clientFingerprint!)
              : null,
        ),
        obfs: obfs?.isNotEmpty == true
            ? Obfs(
                type: obfs!,
                password: obfsPassword,
                minPacketSize: obfsMinPacketSize,
                maxPacketSize: obfsMaxPacketSize,
              )
            : null,
        realm: realmOpts?.enable == true
            ? Realm(
                serverUrl: realmOpts!.serverUrl,
                token: realmOpts!.token,
                realmId: realmOpts!.realmId,
                stunServers: realmOpts!.stunServers,
              )
            : null,
      ),
      ClashProxyType.hysteria => Outbound(
        type: OutboundType.hysteria,
        tag: name,
        server: server,
        serverPort: port,
        serverPorts: toSingBoxServerPorts(ports),
        authStr: authStr,
        upMbps: up,
        downMbps: down,
        disableMtuDiscovery: disableMtuDiscovery ?? true,
        obfs: obfs,
        tls: Tls(
          alpn: alpn ?? ['hysteria'],
          enabled: true,
          insecure: skipCertVerify,
          disableSni: sni.isEmpty,
          serverName: sni,
          utls: clientFingerprint?.isNotEmpty == true
              ? Utls(enabled: true, fingerprint: clientFingerprint!)
              : null,
        ),
      ),
      ClashProxyType.anytls => Outbound(
        type: OutboundType.anytls,
        tag: name,
        server: server,
        serverPort: port,
        password: password,
        idleSessionCheckInterval: idleSessionCheckInterval != null
            ? '${idleSessionCheckInterval}s'
            : null,
        idleSessionTimeout: idleSessionTimeout != null ? '${idleSessionTimeout}s' : null,
        minIdleSession: minIdleSession,
        clientMetadata: clientMetadata,
        tls: Tls(
          alpn: alpn,
          enabled: true,
          insecure: skipCertVerify,
          disableSni: sni.isEmpty,
          serverName: sni,
          utls: clientFingerprint?.isNotEmpty == true
              ? Utls(enabled: true, fingerprint: clientFingerprint!)
              : null,
        ),
      ),
      ClashProxyType.trojan => Outbound(
        type: OutboundType.trojan,
        tag: name,
        network: _toSingBoxNetwork,
        server: server,
        serverPort: port,
        password: password,
        tls: Tls(
          alpn: alpn,
          enabled: true,
          insecure: skipCertVerify,
          disableSni: sni.isEmpty,
          serverName: sni,
          utls: clientFingerprint?.isNotEmpty == true
              ? Utls(enabled: true, fingerprint: clientFingerprint!)
              : null,
        ),
        transport: _toSingBoxTransport,
      ),
      ClashProxyType.tuic => Outbound(
        type: OutboundType.tuic,
        tag: name,
        server: server,
        serverPort: port,
        uuid: uuid,
        password: password,
        bbrProfile: bbrProfile,
        zeroRttHandshake: reduceRtt,
        congestionControl: congestionController,
        udpRelayMode: udpRelayMode,
        heartbeat: heartbeatInterval != null ? '${(heartbeatInterval! / 1000)}s' : null,
        tls: Tls(
          alpn: alpn ?? ['h3'],
          enabled: true,
          insecure: skipCertVerify,
          // tuic 支持显式 disable-sni 字段，未写时默认 false（与其他分支的显式布尔一致）
          disableSni: disableSni ?? false,
          serverName: sni,
        ),
      ),
      ClashProxyType.vmess => Outbound(
        type: OutboundType.vmess,
        tag: name,
        network: _toSingBoxNetwork,
        server: server,
        serverPort: port,
        uuid: uuid,
        security: cipher,
        alterId: alterId,
        globalPadding: globalPadding,
        authenticatedLength: authenticatedLength,
        packetEncoding: packetEncoding,
        tls: Tls(
          alpn: alpn,
          enabled: tls,
          insecure: skipCertVerify,
          disableSni: sni.isEmpty,
          serverName: sni,
          utls: clientFingerprint?.isNotEmpty == true
              ? Utls(enabled: true, fingerprint: clientFingerprint!)
              : null,
        ),
        transport: _toSingBoxTransport,
      ),
      ClashProxyType.vless => Outbound(
        type: OutboundType.vless,
        tag: name,
        network: _toSingBoxNetwork,
        server: server,
        serverPort: port,
        uuid: uuid,
        flow: flow,
        packetEncoding: packetEncoding,
        tls: Tls(
          alpn: alpn,
          // reality 隐含 TLS：YAML 未写 tls: true 时也要启用
          enabled: (tls ?? false) || realityOpts != null,
          insecure: skipCertVerify,
          disableSni: sni.isEmpty,
          serverName: sni,
          reality: realityOpts?.publicKey != null
              ? Reality(
                  enabled: true,
                  publicKey: realityOpts!.publicKey,
                  shortId: realityOpts?.shortId,
                )
              : null,
          utls: clientFingerprint?.isNotEmpty == true
              ? Utls(enabled: true, fingerprint: clientFingerprint!)
              : null,
        ),
        transport: _toSingBoxTransport,
      ),
      ClashProxyType.shadowsocks => Outbound(
        type: OutboundType.shadowsocks,
        tag: name,
        network: _toSingBoxNetwork,
        server: server,
        serverPort: port,
        password: password,
        method: cipher,
        plugin: _toSingBoxPlugin,
        pluginOpts: _toSingBoxPluginOpts,
        udpOverTcp: udpOverTcp != null
            ? UdpOverTcp(enabled: udpOverTcp, version: udpOverTcpVersion ?? 1)
            : null,
      ),
      _ => null,
    };
    return outbound;
  }

  Object? get _toSingBoxNetwork => udp == true ? ['tcp', 'udp'] : 'tcp';
  Transport? get _toSingBoxTransport => network == 'tcp'
      ? Transport(type: 'http')
      : (network?.isNotEmpty == true ? Transport(type: network!) : null);

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
    final outbound = switch (type) {
      ClashGroupType.select => Outbound(type: OutboundType.selector, tag: name, outbounds: proxies),
      ClashGroupType.urlTest => Outbound(
        type: OutboundType.urltest,
        tag: name,
        outbounds: proxies,
        url: url,
        interval: _singBoxInterval(),
        tolerance: 50,
        interruptExistConnections: true,
      ),
      _ => null,
    };
    return outbound;
  }
}
