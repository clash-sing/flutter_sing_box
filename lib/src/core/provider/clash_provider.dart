import 'package:flutter/material.dart';
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
      final outbound = element.toOutbound();
      if (outbound != null) {
        outbounds.add(outbound);
      } else {
        debugPrint('${element.name} is not support');
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
        upMbps: up,
        downMbps: down,
        tls: Tls(
          alpn: alpn ?? ['h3'],
          enabled: true,
          insecure: skipCertVerify,
          disableSni: !(sni?.isNotEmpty == true),
          serverName: sni ?? "",
        ),
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
        tls: Tls(
          alpn: alpn ?? ['h3'],
          enabled: true,
          insecure: skipCertVerify,
          disableSni: !(sni?.isNotEmpty == true),
          serverName: sni ?? "",
        ),
      ),
      ClashProxyType.anytls => Outbound(
        type: OutboundType.anytls,
        tag: name,
        server: server,
        serverPort: port,
        password: password,
        tls: Tls(
          enabled: true,
          insecure: skipCertVerify,
          disableSni: !(sni?.isNotEmpty == true),
          serverName: sni ?? "",
        ),
      ),
      ClashProxyType.trojan => Outbound(
        type: OutboundType.trojan,
        tag: name,
        server: server,
        serverPort: port,
        password: password,
        tls: Tls(
          enabled: true,
          insecure: skipCertVerify,
          disableSni: !(sni?.isNotEmpty == true),
          serverName: sni ?? "",
        ),
        transport: network?.isNotEmpty == true ? Transport(type: network!) : null,
      ),
      ClashProxyType.tuic => Outbound(
        type: OutboundType.tuic,
        tag: name,
        server: server,
        serverPort: port,
        uuid: uuid,
        password: password,
        zeroRttHandshake: reduceRtt,
        congestionControl: congestionControl,
        udpRelayMode: udpRelayMode,
        tls: Tls(
          alpn: alpn ?? ['h3'],
          enabled: true,
          insecure: skipCertVerify,
          disableSni: !(sni?.isNotEmpty == true),
          serverName: sni ?? "",
        ),
        transport: network?.isNotEmpty == true ? Transport(type: network!) : null,
      ),
      _ => null,
    };
    return outbound;
  }
}

/// Extensions for converting a [ClashGroup] into an [Outbound].
extension ClashGroupExt on ClashGroup {
  String _singBoxInterval() {
    if (interval != null) {
      final int min = interval! ~/ 60;
      return '${min}m';
    } else {
      return '10m';
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
      ),
      _ => null,
    };
    return outbound;
  }
}
