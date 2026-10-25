// 本文件由 tool/gen_models.dart 生成，勿手改。
part of 'outbound.dart';

/// `type` 判别值为 `naive` 的出站配置。
@JsonSerializable(explicitToJson: true, includeIfNull: false)
class NaiveOutbound extends Outbound with DialerFields {
  /// 本类的 `type` 判别值。
  static const typeName = 'naive';

  /// 对应 JSON 键 `tag`，必填。
  @override
  String tag;
  /// 对应 JSON 键 `server`，可空（null 不参与序列化）。
  String? server;
  /// 对应 JSON 键 `server_port`，可空（null 不参与序列化）。
  @JsonKey(name: 'server_port')
  int? serverPort;
  /// 对应 JSON 键 `username`，可空（null 不参与序列化）。
  String? username;
  /// 对应 JSON 键 `password`，可空（null 不参与序列化）。
  String? password;
  /// 对应 JSON 键 `insecure_concurrency`，可空（null 不参与序列化）。
  @JsonKey(name: 'insecure_concurrency')
  int? insecureConcurrency;
  /// 对应 JSON 键 `extra_headers`，可空（null 不参与序列化）。
  @JsonKey(name: 'extra_headers')
  HTTPHeader? extraHeaders;
  /// 对应 JSON 键 `stream_receive_window`，可空（null 不参与序列化）。
  @JsonKey(name: 'stream_receive_window')
  Object? streamReceiveWindow;
  /// 对应 JSON 键 `udp_over_tcp`，可空（null 不参与序列化）。
  @JsonKey(name: 'udp_over_tcp')
  Object? udpOverTcp;
  /// 对应 JSON 键 `quic`，可空（null 不参与序列化）。
  bool? quic;
  /// 对应 JSON 键 `quic_congestion_control`，可空（null 不参与序列化）。
  @JsonKey(name: 'quic_congestion_control')
  String? quicCongestionControl;
  /// 对应 JSON 键 `quic_session_receive_window`，可空（null 不参与序列化）。
  @JsonKey(name: 'quic_session_receive_window')
  Object? quicSessionReceiveWindow;
  /// 对应 JSON 键 `tls`，可空（null 不参与序列化）。
  OutboundTLSOptions? tls;

  /// 以 [tag] 构造；可空字段省略时为 `null`。
  NaiveOutbound({
    required this.tag,
    // 可空字段省略（默认 null）
  });

  /// `type` 判别值，固定为 [typeName]。
  @override
  String get type => typeName;

  /// 从 JSON 对象反序列化为本类型。
  factory NaiveOutbound.fromJson(Map<String, dynamic> json) =>
      _$NaiveOutboundFromJson(json);

  /// 序列化为 JSON；输出携带 `type` 判别键。
  @override
  Map<String, dynamic> toJson() =>
      {'type': typeName, ..._$NaiveOutboundToJson(this)};
}
