import 'dart:convert';

import 'package:material_ui/material_ui.dart';
import 'package:flutter_sing_box/flutter_sing_box.dart';

/// Decodes a Base64-encoded subscription into a list of [Outbound]s.
class Base64Provider {
  /// Parses the Base64-encoded [data] into a list of [Outbound]s.
  ///
  /// Throws an [Exception] if [data] is not a valid Base64 string.
  static List<Outbound> provide(String data) {
    final base64String = data.replaceAll(RegExp(r'\s+'), '');
    // 检查长度是否为4的倍数
    if (base64String.length % 4 != 0) {
      throw Exception("Invalid base64 string");
    }
    RegExp base64RegExp = RegExp(r'^[A-Za-z0-9+/]*={0,2}$');
    final isBase64 = base64RegExp.hasMatch(base64String);
    if (!isBase64) {
      throw Exception("Invalid base64 string");
    }
    String decodedString = utf8.decode(base64.decode(base64String));
    final List<Outbound> outbounds = [];
    final List<String> lines = decodedString.split('\n');
    for (var line in lines) {
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
          case ClashProxyType.shadowsocks:
            outbound = _parseShadowsocks(uri);
            break;
          default:
            break;
        }
        if (outbound != null) {
          outbounds.add(outbound);
        }
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
        serverPorts: queryParams['mport']?.isNotEmpty == true
            ? [queryParams['mport']!.replaceAll('-', ':')]
            : null,
        password: uri.userInfo,
        obfs: queryParams['obfs']?.isNotEmpty == true
            ? Obfs(type: queryParams['obfs']!, password: queryParams['obfs-password'])
            : null,
        tls: Tls(
          alpn: queryParams['alpn']?.isNotEmpty == true ? [queryParams['alpn']!] : ['h3'],
          enabled: true,
          insecure: queryParams['insecure'] == '1' || queryParams['allowInsecure'] == '1',
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
        network: queryParams['protocol'] == 'udp' ? ['tcp', 'udp'] : 'tcp',
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

  static Outbound? _parseShadowsocks(Uri uri) {
    try {
      final pair = _decodeSsUserinfo(uri.userInfo);
      if (pair == null) return null;
      final (method, password) = pair;

      Map<String, String> queryParams = uri.queryParameters;
      final plugin = queryParams['plugin'];
      final pluginName = plugin?.split(';').first;
      final pluginOpts = plugin != null && plugin.contains(';')
          ? plugin.substring(plugin.indexOf(';') + 1)
          : null;

      return Outbound(
        type: OutboundType.shadowsocks,
        tag: Uri.decodeComponent(uri.fragment),
        server: uri.host,
        serverPort: uri.port,
        method: method,
        password: password,
        plugin: pluginName,
        pluginOpts: pluginOpts,
      );
    } catch (e) {
      return null;
    }
  }

  /// 解析 ss:// 的 userinfo，返回 (method, password)。
  /// 形态①：base64url(method:password) —— 需归一化字母表并补 padding；
  /// 形态②：明文 method:password —— 按第一个冒号切分（密码可能含冒号，
  ///         尤其是 SS2022 的 "server-key:user-key" 形式，绝不能 split 全切）。
  static (String, String)? _decodeSsUserinfo(String raw) {
    // uri.userInfo 返回未解码的原始串，先统一 percent-decode：
    // 明文形式必须解码；base64 形式顺便免疫被过度编码的 %3D padding
    String userinfo;
    try {
      userinfo = Uri.decodeComponent(raw);
    } on FormatException {
      return null;
    }
    if (userinfo.contains(':')) {
      final i = userinfo.indexOf(':');
      if (i <= 0 || i == userinfo.length - 1) return null;
      return (userinfo.substring(0, i), userinfo.substring(i + 1));
    }
    // base64url → 标准 base64（Dart 的 base64.decode 只认 +/ 字母表）
    final s = userinfo.replaceAll('-', '+').replaceAll('_', '/');
    final padded = s + '=' * ((4 - s.length % 4) % 4);
    try {
      final decoded = utf8.decode(base64.decode(padded));
      final i = decoded.indexOf(':');
      if (i <= 0) return null;
      return (decoded.substring(0, i), decoded.substring(i + 1));
    } on FormatException {
      return null;
    }
  }
}
