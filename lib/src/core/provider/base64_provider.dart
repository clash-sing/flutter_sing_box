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
          case 'hy2':
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
          case ClashProxyType.vless:
            outbound = _parseVless(uri);
            break;
          case ClashProxyType.vmess:
            // vmess://base64(JSON) 不是标准 URI（无 @host:port 结构），传原始行整行解码
            outbound = _parseVmess(line);
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
        serverPorts: toSingBoxServerPorts(queryParams['mport']),
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
        serverPorts: toSingBoxServerPorts(queryParams['mport']),
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

  /// 解析 vless:// 分享链接（格式定义见 Xray-core Discussion #716）。
  static Outbound? _parseVless(Uri uri) {
    try {
      final q = uri.queryParameters;
      final sni = q['sni'];
      final fingerprint = q['fp'];
      final utls = fingerprint?.isNotEmpty == true
          ? Utls(enabled: true, fingerprint: fingerprint!)
          : null;

      Tls? tls;
      switch (q['security']) {
        case 'reality':
          tls = Tls(
            enabled: true,
            disableSni: !(sni?.isNotEmpty == true),
            serverName: sni,
            utls: utls,
            reality: Reality(enabled: true, publicKey: q['pbk'], shortId: q['sid'] ?? ''),
          );
        case 'tls' || 'xtls': // xtls 为旧值，按纯 TLS 处理
          tls = Tls(
            alpn: q['alpn']?.split(','),
            enabled: true,
            insecure: q['insecure'] == '1' || q['allowInsecure'] == '1',
            disableSni: !(sni?.isNotEmpty == true),
            serverName: sni,
            utls: utls,
          );
        default: // none 或缺省：无 TLS
          break;
      }

      return Outbound(
        type: OutboundType.vless,
        tag: Uri.decodeComponent(uri.fragment),
        server: uri.host,
        serverPort: uri.port,
        uuid: uri.userInfo,
        flow: q['flow'],
        packetEncoding: q['packetEncoding'],
        tls: tls,
        transport: _toVlessTransport(q),
      );
    } catch (e) {
      return null;
    }
  }

  /// 按 type 参数映射 vless 的 V2Ray 传输层；tcp（或缺省）返回 null。
  static Transport? _toVlessTransport(Map<String, String> q) {
    switch (q['type'] ?? 'tcp') {
      case 'ws':
        return Transport(
          type: OutboundTransportType.webSocket,
          path: q['path'],
          headers: q['host']?.isNotEmpty == true ? {'Host': q['host']} : null,
        );
      case 'grpc':
        // 规范参数为 serviceName，部分客户端只写 path，做兼容
        return Transport(
          type: OutboundTransportType.gRPC,
          serviceName: q['serviceName'] ?? q['path'],
        );
      case 'httpupgrade':
        return Transport(type: OutboundTransportType.httpUpgrade, path: q['path'], host: q['host']);
      case 'http':
        return Transport(type: OutboundTransportType.http, host: q['host']);
      default:
        return null;
    }
  }

  /// 解析 vmess:// 分享链接（vmess://base64(JSON)，无官方规范，字段名以 v2rayN 为事实标准）。
  /// 注意链接不是标准 URI，需传入拆行后的原始行。
  static Outbound? _parseVmess(String line) {
    try {
      final raw = line.substring('vmess://'.length);
      // URL-safe 字母表归一化 + 补 padding（v2rayN 为标准 base64，部分客户端无 padding）
      final s = raw.replaceAll('-', '+').replaceAll('_', '/');
      final padded = s + '=' * ((4 - s.length % 4) % 4);
      final decoded = jsonDecode(utf8.decode(base64.decode(padded)));
      if (decoded is! Map) return null;
      final map = Map<String, dynamic>.from(decoded);

      final add = map['add'] as String?;
      final id = map['id'] as String?;
      if (add?.isNotEmpty != true || id?.isNotEmpty != true) return null;

      // port/aid 在各客户端里类型不一（数字或字符串），统一转 int
      final port = switch (map['port']) {
        num n => n.toInt(),
        String s => int.tryParse(s),
        _ => null,
      };
      if (port == null) return null;
      final alterId = switch (map['aid']) {
        num n => n.toInt(),
        String s => int.tryParse(s) ?? 0,
        _ => 0,
      };

      final net = (map['net'] as String?) ?? 'tcp';
      if (net == 'kcp' || net == 'quic') {
        // V2Ray 私有传输，sing-box 不支持，跳过该节点
        return null;
      }
      final Transport? transport = switch (net) {
        'ws' => Transport(
          type: OutboundTransportType.webSocket,
          path: map['path'] as String?,
          headers: (map['host'] as String?)?.isNotEmpty == true ? {'Host': map['host']} : null,
        ),
        'grpc' => Transport(type: OutboundTransportType.gRPC, serviceName: map['path'] as String?),
        'h2' ||
        'http' => Transport(type: OutboundTransportType.http, host: map['host'], path: map['path']),
        'httpupgrade' => Transport(
          type: OutboundTransportType.httpUpgrade,
          path: map['path'] as String?,
          host: map['host'],
        ),
        // tcp 且 type=http 时为 http 伪装传输，否则无传输层
        _ =>
          map['type'] == 'http'
              ? Transport(type: OutboundTransportType.http, host: map['host'])
              : null,
      };

      // vmess JSON 的 tls 字段为字符串："tls" 启用，""/none 未启用
      final Tls? tls;
      if (map['tls'] == 'tls') {
        final sni = (map['sni'] as String?)?.isNotEmpty == true
            ? map['sni'] as String?
            : map['host'] as String?;
        final alpn = map['alpn'] as String?;
        final fp = map['fp'] as String?;
        final allowInsecure = map['allowInsecure'];
        tls = Tls(
          alpn: alpn != null && alpn.isNotEmpty ? alpn.split(',') : null,
          enabled: true,
          insecure: allowInsecure == true || allowInsecure == '1' || allowInsecure == 'true',
          disableSni: !(sni?.isNotEmpty == true),
          serverName: sni,
          utls: fp?.isNotEmpty == true ? Utls(enabled: true, fingerprint: fp!) : null,
        );
      } else {
        tls = null;
      }

      final ps = map['ps'] as String?;
      return Outbound(
        type: OutboundType.vmess,
        tag: ps?.isNotEmpty == true ? ps! : id!,
        server: add,
        serverPort: port,
        uuid: id,
        // 加密字段新名 scy、旧名 security，缺省 auto
        security: ((map['scy'] ?? map['security']) as String?) ?? 'auto',
        alterId: alterId,
        tls: tls,
        transport: transport,
      );
    } catch (e) {
      return null;
    }
  }
}
