import 'package:flutter/material.dart';
import 'package:flutter_sing_box/flutter_sing_box.dart';
import 'package:flutter_sing_box/src/models/clash/clash_type.dart';

 //   String urlString = 'https://example.com:8080/path/to/page?param1=value1&param2=value2#section1';
 //    // 解析 URL
 //    Uri uri = Uri.parse(urlString);
 //    // 获取各个部分
 //    print('Scheme: ${uri.scheme}');           // https
 //    print('Host: ${uri.host}');               // example.com
 //    print('Port: ${uri.port}');               // 8080
 //    print('Path: ${uri.path}');               // /path/to/page
 //    print('Query: ${uri.query}');             // param1=value1&param2=value2
 //    print('Fragment: ${uri.fragment}');       // section1
 //    print('Origin: ${uri.origin}');           // https://example.com:8080

 class Base64Parser {
  static String parse(String base64) {
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
        switch (uri.scheme) {
          case ClashProxyType.hysteria2:
          case ClashProxyType.hysteria:
            break;
          case ClashProxyType.anytls:
          case ClashProxyType.trojan:
            break;
          default:
            break;
        }
        debugPrint(uri.toString());
      }
    }
    return base64;
  }
  static Outbound? _parseHysteria2(Uri uri) {
    try {
      Map<String, String> queryParams = uri.queryParameters;
      return Outbound(
        type: OutboundType.hysteria2,
        tag: uri.fragment,
        server: uri.host,
        serverPort: uri.port,
        serverPorts: [queryParams['mport']!.replaceAll('-', ':')],
        password: uri.userInfo,
        tls: Tls(
          alpn: queryParams['alpn']?.isNotEmpty == true ? [queryParams['alpn']!] : ['h3'],
          enabled: true,
          insecure: queryParams['insecure'] == '1' ? true : false,
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
        tag: uri.fragment,
        server: uri.host,
        serverPort: uri.port,
        serverPorts: [queryParams['mport']!.replaceAll('-', ':')],
        authStr: queryParams['auth'],
        tls: Tls(
          alpn: queryParams['alpn']?.isNotEmpty == true ? [queryParams['alpn']!] : ['h3'],
          enabled: true,
          insecure: queryParams['allowInsecure'] == '1' ? true : false,
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
}