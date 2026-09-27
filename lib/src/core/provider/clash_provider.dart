import 'package:material_ui/material_ui.dart';
import 'package:flutter_sing_box/flutter_sing_box.dart';
import 'package:yaml/yaml.dart';

/// Converts a Clash-format subscription into a list of [Outbound]s.
class ClashProvider {
  /// Builds a list of [Outbound]s from the Clash-format [yamlMap].
  static List<Outbound> provide(YamlMap yamlMap) {
    final Map<String, dynamic> clashMap = yamlMap.toMap();
    // remove mieru proxy, sing-box 不支持 mieru
    (clashMap['proxies'] as List<dynamic>).removeWhere(
      (element) => element['type'].toString().toLowerCase() == 'mieru',
    );
    final clash = Clash.fromJson(clashMap);
    final List<Outbound> outbounds = [];
    for (var element in clash.proxies) {
      try {
        final outbound = element.toOutbound();
        if (outbound != null) {
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
    return outbounds;
  }
}

/// Extensions for converting a [ClashProxy] into an [Outbound].
/// TODO: 待实现 snell
extension ClashProxyExt on ClashProxy {
  /// Converts this Clash proxy into a sing-box [Outbound], or `null`
  /// if the proxy type is unsupported.
  Outbound? toOutbound() {
    final outbound = switch (type) {
      ClashProxyType.hysteria2 => Outbound(
        type: OutboundType.hysteria2,
        tag: name,
        server: server,
        serverPort: port,
        serverPorts: ports?.isNotEmpty == true ? [ports!.replaceAll('-', ':')] : null,
        password: password,
        bbrProfile: bbrProfile,
        upMbps: up,
        downMbps: down,
        tls: Tls(
          alpn: alpn ?? ['h3'],
          enabled: true,
          insecure: skipCertVerify,
          disableSni: !(sni?.isNotEmpty == true),
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
        serverPorts: ports?.isNotEmpty == true ? [ports!.replaceAll('-', ':')] : null,
        authStr: authStr,
        upMbps: up,
        downMbps: down,
        disableMtuDiscovery: disableMtuDiscovery ?? true,
        obfs: obfs?.isNotEmpty == true ? Obfs(type: obfs!) : null,
        tls: Tls(
          alpn: alpn ?? ['h3'],
          enabled: true,
          insecure: skipCertVerify,
          disableSni: !(sni?.isNotEmpty == true),
          serverName: sni,
          utls: clientFingerprint?.isNotEmpty == true
              ? Utls(enabled: true, fingerprint: clientFingerprint!)
              : null,
        ),
      ),
      ClashProxyType.anytls => Outbound(
        type: OutboundType.anytls,
        tag: name,
        network: _toSingBoxNetwork,
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
          disableSni: !(sni?.isNotEmpty == true),
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
          disableSni: !(sni?.isNotEmpty == true),
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
          disableSni: disableSni,
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
          disableSni: !(sni?.isNotEmpty == true),
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
          disableSni: !(sni?.isNotEmpty == true),
          serverName: sni,
          reality: realityOpts?.publicKey != null
              ? Reality(enabled: true, publicKey: realityOpts!.publicKey, shortId: realityOpts?.shortId)
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
