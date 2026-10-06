// 本文件由 tool/gen_models.dart 生成，勿手改。
part of 'outbound.dart';

@JsonSerializable(explicitToJson: true, includeIfNull: false)
class TuicOutbound extends Outbound with DialerFields {
  static const typeName = 'tuic';

  @override
  String tag;
  String? server;
  @JsonKey(name: 'server_port')
  int? serverPort;
  String? uuid;
  String? password;
  @JsonKey(name: 'congestion_control')
  String? congestionControl;
  @JsonKey(name: 'udp_relay_mode')
  String? udpRelayMode;
  @JsonKey(name: 'udp_over_stream')
  bool? udpOverStream;
  @JsonKey(name: 'zero_rtt_handshake')
  bool? zeroRttHandshake;
  String? heartbeat;
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

  TuicOutbound({
    required this.tag,
    // 可空字段省略（默认 null）
  });

  @override
  String get type => typeName;

  factory TuicOutbound.fromJson(Map<String, dynamic> json) =>
      _$TuicOutboundFromJson(json);

  @override
  Map<String, dynamic> toJson() =>
      {'type': typeName, ..._$TuicOutboundToJson(this)};
}
