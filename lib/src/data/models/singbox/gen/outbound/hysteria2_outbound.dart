// 本文件由 tool/gen_models.dart 生成，勿手改。
part of 'outbound.dart';

@JsonSerializable(explicitToJson: true, includeIfNull: false)
class Hysteria2Outbound extends Outbound with DialerFields {
  static const typeName = 'hysteria2';

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
  @JsonKey(name: 'hop_interval_max')
  String? hopIntervalMax;
  @JsonKey(name: 'up_mbps')
  int? upMbps;
  @JsonKey(name: 'down_mbps')
  int? downMbps;
  Object? obfs;
  String? password;
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
  @JsonKey(name: 'bbr_profile')
  String? bbrProfile;
  @JsonKey(name: 'brutal_debug')
  bool? brutalDebug;
  @JsonKey(name: 'disable_chrome_parrot')
  bool? disableChromeParrot;
  Hysteria2Realm? realm;

  Hysteria2Outbound({
    required this.tag,
    // 可空字段省略（默认 null）
  });

  @override
  String get type => typeName;

  factory Hysteria2Outbound.fromJson(Map<String, dynamic> json) =>
      _$Hysteria2OutboundFromJson(json);

  @override
  Map<String, dynamic> toJson() =>
      {'type': typeName, ..._$Hysteria2OutboundToJson(this)};
}
