import 'package:flutter/material.dart';
import 'package:flutter_sing_box/flutter_sing_box.dart';
import 'package:flutter_sing_box/src/models/clash/clash_type.dart';

import '../const/outbound_transport_type.dart';

 class Base64Parser {
  static List<Outbound> parse(String base64) {
    final List<Outbound> outbounds = [];
    final List<String> lines = base64.split('\n');
    for (var line in  lines) {
      final uri = Uri.tryParse(line);
      if (uri == null) {
        if (line.toUpperCase().startsWith('STATUS')) {
          // user info
          debugPrint(line);
        } else {
          continue;
        }
      } else {
        // parse uri
        Outbound? outbound;
        switch (uri.scheme) {
          case ClashProxyType.hysteria2:
            outbound = _parseHysteria2(uri);
            break;
          case ClashProxyType.hysteria:
            outbound = _parseHysteria(uri);
            break;
          case ClashProxyType.anytls:
            outbound = _parseAnytls(uri);
            break;
          case ClashProxyType.trojan:
            outbound = _parseTrojan(uri);
            break;
          default:
            break;
        }
        if (outbound != null) {
          outbounds.add(outbound);
        }
        debugPrint(outbounds.toString());
      }
    }
    return outbounds;
  }
  static Outbound? _parseHysteria2(Uri uri) {
    try {
      Map<String, String> queryParams = uri.queryParameters;
      return Outbound(
        type: OutboundType.hysteria2,
        tag: Uri.decodeComponent(uri.fragment),
        server: uri.host,
        serverPort: uri.port,
        serverPorts: [queryParams['mport']!.replaceAll('-', ':')],
        password: uri.userInfo,
        tls: Tls(
          alpn: queryParams['alpn']?.isNotEmpty == true ? [queryParams['alpn']!] : ['h3'],
          enabled: true,
          insecure: queryParams['allowInsecure'] == '1',
          disableSni: !(queryParams['sni']?.isNotEmpty == true),
          serverName: queryParams['sni'] ?? '',
        ),
      );
    } catch (e) {
      return null;
    }
  }

  static Outbound? _parseHysteria(Uri uri) {
    try {
      Map<String, String> queryParams = uri.queryParameters;
      return Outbound(
        type: OutboundType.hysteria,
        tag: Uri.decodeComponent(uri.fragment),
        server: uri.host,
        serverPort: uri.port,
        serverPorts: [queryParams['mport']!.replaceAll('-', ':')],
        authStr: queryParams['auth'],
        tls: Tls(
          alpn: queryParams['alpn']?.isNotEmpty == true ? [queryParams['alpn']!] : ['h3'],
          enabled: true,
          insecure: queryParams['allowInsecure'] == '1',
          disableSni: !(queryParams['peer']?.isNotEmpty == true),
          serverName: queryParams['peer'] ?? '',
        ),
        upMbps: int.tryParse(queryParams['upmbps'] ?? '50') ?? 50,
        downMbps: int.tryParse(queryParams['downmbps'] ?? '100') ?? 100,
        disableMtuDiscovery: true,
      );
    } catch (e) {
      return null;
    }
  }

  static Outbound? _parseAnytls(Uri uri) {
    try {
      Map<String, String> queryParams = uri.queryParameters;
      return Outbound(
        type: OutboundType.anytls,
        tag: Uri.decodeComponent(uri.fragment),
        server: uri.host,
        serverPort: uri.port,
        password: uri.userInfo,
        tls: Tls(
          enabled: true,
          insecure: queryParams['allowInsecure'] == '1',
          disableSni: !(queryParams['peer']?.isNotEmpty == true),
          serverName: queryParams['peer'] ?? '',
        ),
      );
    } catch (e) {
      return null;
    }
  }

  static Outbound? _parseTrojan(Uri uri) {
    try {
      Map<String, String> queryParams = uri.queryParameters;
      return Outbound(
        type: OutboundType.trojan,
        tag: Uri.decodeComponent(uri.fragment),
        server: uri.host,
        serverPort: uri.port,
        password: uri.userInfo,
        tls: Tls(
          enabled: true,
          insecure: queryParams['allowInsecure'] == '1',
          disableSni: !(queryParams['peer']?.isNotEmpty == true),
          serverName: queryParams['peer'] ?? '',
        ),
        transport: queryParams['obfs'] == 'websocket'
            ? Transport(type: OutboundTransportType.webSocket)
            : null,
      );
    } catch (e) {
      return null;
    }
  }

 }