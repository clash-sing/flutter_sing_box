// 本文件由 tool/gen_models.dart 生成，勿手改。
import 'package:json_annotation/json_annotation.dart';

import '../http_header.dart';
import '../outbound_tls_options.dart';

part 'dhcp_dns_server.dart';
part 'fakeip_dns_server.dart';
part 'h3_dns_server.dart';
part 'hosts_dns_server.dart';
part 'https_dns_server.dart';
part 'local_dns_server.dart';
part 'mdns_dns_server.dart';
part 'openconnect_dns_server.dart';
part 'openvpn_dns_server.dart';
part 'quic_dns_server.dart';
part 'resolved_dns_server.dart';
part 'tailscale_dns_server.dart';
part 'tcp_dns_server.dart';
part 'tls_dns_server.dart';
part 'udp_dns_server.dart';
part 'unknown_dns_server.dart';

part 'dns_server.g.dart';

/// DNS 服务器配置，按 type 判别的密封类层级。
sealed class DNSServer {
  const DNSServer();

  String get tag;
  String get type;

  /// 子类输出须带 type 判别键（round-trip 保真的关键）。
  Map<String, dynamic> toJson();

  /// 按 type 判别反序列化；未知类型进 [UnknownDnsServer] 透传。
  factory DNSServer.fromJson(Map<String, dynamic> json) {
    final type = json['type'] as String?;
    return switch (type) {
      'dhcp' => DhcpDNSServer.fromJson(json),
      'fakeip' => FakeipDNSServer.fromJson(json),
      'h3' => H3DNSServer.fromJson(json),
      'hosts' => HostsDNSServer.fromJson(json),
      'https' => HttpsDNSServer.fromJson(json),
      'local' => LocalDNSServer.fromJson(json),
      'mdns' => MdnsDNSServer.fromJson(json),
      'openconnect' => OpenconnectDNSServer.fromJson(json),
      'openvpn' => OpenvpnDNSServer.fromJson(json),
      'quic' => QuicDNSServer.fromJson(json),
      'resolved' => ResolvedDNSServer.fromJson(json),
      'tailscale' => TailscaleDNSServer.fromJson(json),
      'tcp' => TcpDNSServer.fromJson(json),
      'tls' => TlsDNSServer.fromJson(json),
      'udp' => UdpDNSServer.fromJson(json),
      _ => UnknownDnsServer.fromJson(json),
    };
  }
}

/// 全部 DNS 服务器类型名（schema 全量收集，无白名单）。
const Set<String> kDnsServerTypeNames = {
  'dhcp',
  'fakeip',
  'h3',
  'hosts',
  'https',
  'local',
  'mdns',
  'openconnect',
  'openvpn',
  'quic',
  'resolved',
  'tailscale',
  'tcp',
  'tls',
  'udp',
};
