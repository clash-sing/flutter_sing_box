import 'package:flutter_sing_box/flutter_sing_box.dart';
import 'package:flutter_sing_box/src/models/clash/clash_proxy.dart';

import '../models/clash/clash_group.dart';
import '../models/clash/clash_type.dart';

extension ClashProxyExt on ClashProxy {
  Outbound? toOutbound() {
    final outbound = switch(type) {
      ClashProxyType.hysteria2 =>
          Outbound(
            type: OutboundType.hysteria2,
            tag: name,
            server: server,
            serverPort: port,
            serverPorts: [ports!.replaceAll('-', ':')],
            password: password,
            tls: Tls(
              alpn: alpn ?? ['h3'],
              enabled: true,
              insecure: true,
              disableSni: !(sni?.isNotEmpty == true),
              serverName: sni ?? "",
            ),
          ),
      ClashProxyType.hysteria =>
          Outbound(
            type: OutboundType.hysteria,
            tag: name,
            server: server,
            serverPort: port,
            serverPorts: [ports!.replaceAll('-', ':')],
            authStr: authStr,
            tls: Tls(
              alpn: alpn ?? ['h3'],
              enabled: true,
              insecure: true,
              disableSni: !(sni?.isNotEmpty == true),
              serverName: sni ?? "",
            ),
            upMbps: up,
            downMbps: down,
            disableMtuDiscovery: disableMtuDiscovery ?? true,
          ),
      ClashProxyType.anytls =>
          Outbound(
            type: OutboundType.anytls,
            tag: name,
            server: server,
            serverPort: port,
            password: password,
            tls: Tls(
              enabled: true,
              insecure: true,
              disableSni: !(sni?.isNotEmpty == true),
              serverName: sni ?? "",
            ),
          ),
      ClashProxyType.trojan =>
          Outbound(
            type: OutboundType.trojan,
            tag: name,
            server: server,
            serverPort: port,
            password: password,
            tls: Tls(
              enabled: true,
              insecure: true,
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

extension ClashGroupExt on ClashGroup {
  String _singBoxInterval() {
    if (interval != null) {
      final int min = interval! ~/ 60;
      return '${min}m';
    } else {
      return '10m';
    }
  }
  Outbound? toOutbound() {
    final outbound = switch(type) {
      ClashGroupType.select =>
          Outbound(
            type: OutboundType.selector,
            tag: name,
            outbounds: proxies,
          ),
      ClashGroupType.urlTest =>
          Outbound(
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