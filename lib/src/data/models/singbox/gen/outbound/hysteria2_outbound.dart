// 本文件由 tool/gen_models.dart 生成，勿手改。
part of 'outbound.dart';

/// `type` 判别值为 `hysteria2` 的出站配置。
@JsonSerializable(explicitToJson: true, includeIfNull: false)
class Hysteria2Outbound extends Outbound with DialerFields {
  /// 本类的 `type` 判别值。
  static const typeName = 'hysteria2';

  /// 对应 JSON 键 `tag`，必填。
  @override
  String tag;
  /// 对应 JSON 键 `server`，可空（null 不参与序列化）。
  String? server;
  /// 对应 JSON 键 `server_port`，可空（null 不参与序列化）。
  @JsonKey(name: 'server_port')
  int? serverPort;
  /// 对应 JSON 键 `server_ports`，可空（null 不参与序列化）。
  @JsonKey(name: 'server_ports')
  List<String>? serverPorts;
  /// 对应 JSON 键 `hop_interval`，可空（null 不参与序列化）。
  @JsonKey(name: 'hop_interval')
  String? hopInterval;
  /// 对应 JSON 键 `hop_interval_max`，可空（null 不参与序列化）。
  @JsonKey(name: 'hop_interval_max')
  String? hopIntervalMax;
  /// 对应 JSON 键 `up_mbps`，可空（null 不参与序列化）。
  @JsonKey(name: 'up_mbps')
  int? upMbps;
  /// 对应 JSON 键 `down_mbps`，可空（null 不参与序列化）。
  @JsonKey(name: 'down_mbps')
  int? downMbps;
  /// 对应 JSON 键 `obfs`，可空（null 不参与序列化）。
  Object? obfs;
  /// 对应 JSON 键 `password`，可空（null 不参与序列化）。
  String? password;
  /// 对应 JSON 键 `network`，可空（null 不参与序列化）。
  Object? network;
  /// 对应 JSON 键 `tls`，可空（null 不参与序列化）。
  OutboundTLSOptions? tls;
  /// 对应 JSON 键 `idle_timeout`，可空（null 不参与序列化）。
  @JsonKey(name: 'idle_timeout')
  String? idleTimeout;
  /// 对应 JSON 键 `keep_alive_period`，可空（null 不参与序列化）。
  @JsonKey(name: 'keep_alive_period')
  String? keepAlivePeriod;
  /// 对应 JSON 键 `stream_receive_window`，可空（null 不参与序列化）。
  @JsonKey(name: 'stream_receive_window')
  Object? streamReceiveWindow;
  /// 对应 JSON 键 `connection_receive_window`，可空（null 不参与序列化）。
  @JsonKey(name: 'connection_receive_window')
  Object? connectionReceiveWindow;
  /// 对应 JSON 键 `max_concurrent_streams`，可空（null 不参与序列化）。
  @JsonKey(name: 'max_concurrent_streams')
  int? maxConcurrentStreams;
  /// 对应 JSON 键 `initial_packet_size`，可空（null 不参与序列化）。
  @JsonKey(name: 'initial_packet_size')
  int? initialPacketSize;
  /// 对应 JSON 键 `disable_path_mtu_discovery`，可空（null 不参与序列化）。
  @JsonKey(name: 'disable_path_mtu_discovery')
  bool? disablePathMtuDiscovery;
  /// 对应 JSON 键 `bbr_profile`，可空（null 不参与序列化）。
  @JsonKey(name: 'bbr_profile')
  String? bbrProfile;
  /// 对应 JSON 键 `brutal_debug`，可空（null 不参与序列化）。
  @JsonKey(name: 'brutal_debug')
  bool? brutalDebug;
  /// 对应 JSON 键 `disable_chrome_parrot`，可空（null 不参与序列化）。
  @JsonKey(name: 'disable_chrome_parrot')
  bool? disableChromeParrot;
  /// 对应 JSON 键 `realm`，可空（null 不参与序列化）。
  Hysteria2Realm? realm;

  /// 以 [tag] 构造；可空字段省略时为 `null`。
  Hysteria2Outbound({
    required this.tag,
    // 可空字段省略（默认 null）
  });

  /// `type` 判别值，固定为 [typeName]。
  @override
  String get type => typeName;

  /// 从 JSON 对象反序列化为本类型。
  factory Hysteria2Outbound.fromJson(Map<String, dynamic> json) =>
      _$Hysteria2OutboundFromJson(json);

  /// 序列化为 JSON；输出携带 `type` 判别键。
  @override
  Map<String, dynamic> toJson() =>
      {'type': typeName, ..._$Hysteria2OutboundToJson(this)};
}
