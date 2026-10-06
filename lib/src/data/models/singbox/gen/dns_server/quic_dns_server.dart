// 本文件由 tool/gen_models.dart 生成，勿手改。
part of 'dns_server.dart';

@JsonSerializable(explicitToJson: true, includeIfNull: false)
class QuicDNSServer extends DNSServer {
  static const typeName = 'quic';

  @override
  String tag;
  String? detour;
  @JsonKey(name: 'bind_interface')
  String? bindInterface;
  @JsonKey(name: 'inet4_bind_address')
  Object? inet4BindAddress;
  @JsonKey(name: 'inet6_bind_address')
  Object? inet6BindAddress;
  @JsonKey(name: 'bind_address_no_port')
  bool? bindAddressNoPort;
  @JsonKey(name: 'protect_path')
  String? protectPath;
  @JsonKey(name: 'routing_mark')
  Object? routingMark;
  @JsonKey(name: 'reuse_addr')
  bool? reuseAddr;
  String? netns;
  @JsonKey(name: 'connect_timeout')
  String? connectTimeout;
  @JsonKey(name: 'tcp_fast_open')
  bool? tcpFastOpen;
  @JsonKey(name: 'tcp_multi_path')
  bool? tcpMultiPath;
  @JsonKey(name: 'disable_tcp_keep_alive')
  bool? disableTcpKeepAlive;
  @JsonKey(name: 'tcp_keep_alive')
  String? tcpKeepAlive;
  @JsonKey(name: 'tcp_keep_alive_interval')
  String? tcpKeepAliveInterval;
  @JsonKey(name: 'udp_fragment')
  bool? udpFragment;
  @JsonKey(name: 'domain_resolver')
  Object? domainResolver;
  @JsonKey(name: 'network_strategy')
  String? networkStrategy;
  @JsonKey(name: 'network_type')
  Object? networkType;
  @JsonKey(name: 'fallback_network_type')
  Object? fallbackNetworkType;
  @JsonKey(name: 'fallback_delay')
  String? fallbackDelay;
  String? server;
  @JsonKey(name: 'server_port')
  int? serverPort;
  OutboundTLSOptions? tls;

  QuicDNSServer({
    required this.tag,
    // 可空字段省略（默认 null）
  });

  @override
  String get type => typeName;

  factory QuicDNSServer.fromJson(Map<String, dynamic> json) =>
      _$QuicDNSServerFromJson(json);

  @override
  Map<String, dynamic> toJson() =>
      {'type': typeName, ..._$QuicDNSServerToJson(this)};
}
