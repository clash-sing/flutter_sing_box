// 本文件由 tool/gen_models.dart 生成，勿手改。
part of 'dns_server.dart';

/// 未建模 DNS 服务器类型：持有原始 JSON 原样透传（保真读写）。
class UnknownDnsServer extends DNSServer {
  final Map<String, dynamic> raw;
  UnknownDnsServer(this.raw);

  @override
  String get tag => raw['tag'] as String? ?? '';
  @override
  String get type => raw['type'] as String? ?? '';

  factory UnknownDnsServer.fromJson(Map<String, dynamic> json) =>
      UnknownDnsServer(Map<String, dynamic>.from(json));

  @override
  Map<String, dynamic> toJson() => Map<String, dynamic>.from(raw);
}
