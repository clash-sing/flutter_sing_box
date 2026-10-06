// 本文件由 tool/gen_models.dart 生成，勿手改。
part of 'outbound.dart';

@JsonSerializable(explicitToJson: true, includeIfNull: false)
class HttpOutbound extends Outbound with DialerFields {
  static const typeName = 'http';

  @override
  String tag;
  String? server;
  @JsonKey(name: 'server_port')
  int? serverPort;
  String? username;
  String? password;
  OutboundTLSOptions? tls;
  String? path;
  HTTPHeader? headers;
  int? version;
  @JsonKey(name: 'disable_version_fallback')
  bool? disableVersionFallback;
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

  HttpOutbound({
    required this.tag,
    // 可空字段省略（默认 null）
  });

  @override
  String get type => typeName;

  factory HttpOutbound.fromJson(Map<String, dynamic> json) =>
      _$HttpOutboundFromJson(json);

  @override
  Map<String, dynamic> toJson() =>
      {'type': typeName, ..._$HttpOutboundToJson(this)};
}
