// 本文件由 tool/gen_models.dart 生成，勿手改。
part of 'outbound.dart';

@JsonSerializable(explicitToJson: true, includeIfNull: false)
class HysteriaOutbound extends Outbound with DialerFields {
  static const typeName = 'hysteria';

  @override
  @JsonKey()
  String tag;
  String? server;
  @JsonKey(name: 'server_port')
  int? serverPort;
  @JsonKey(name: 'server_ports')
  List<String>? serverPorts;
  @JsonKey(name: 'hop_interval')
  String? hopInterval;
  Object? up;
  @JsonKey(name: 'up_mbps')
  int? upMbps;
  Object? down;
  @JsonKey(name: 'down_mbps')
  int? downMbps;
  String? obfs;
  Object? auth;
  @JsonKey(name: 'auth_str')
  String? authStr;
  Object? network;
  OutboundTLSOptions? tls;
  @JsonKey(name: 'idle_timeout')
  String? idleTimeout;
  @JsonKey(name: 'keep_alive_period')
  String? keepAlivePeriod;
  @JsonKey(name: 'stream_receive_window')
  Object? streamReceiveWindow;
  @JsonKey(name: 'connection_receive_window')
  Object? connectionReceiveWindow;
  @JsonKey(name: 'max_concurrent_streams')
  int? maxConcurrentStreams;
  @JsonKey(name: 'initial_packet_size')
  int? initialPacketSize;
  @JsonKey(name: 'disable_path_mtu_discovery')
  bool? disablePathMtuDiscovery;

  HysteriaOutbound({
    required this.tag,
    // 可空字段省略（默认 null）
  });

  @override
  String get type => typeName;

  factory HysteriaOutbound.fromJson(Map<String, dynamic> json) =>
      _$HysteriaOutboundFromJson(json);

  @override
  Map<String, dynamic> toJson() =>
      {'type': typeName, ..._$HysteriaOutboundToJson(this)};
}
