// 本文件由 tool/gen_models.dart 生成，勿手改。
part of 'outbound.dart';

@JsonSerializable(explicitToJson: true, includeIfNull: false)
class NaiveOutbound extends Outbound with DialerFields {
  static const typeName = 'naive';

  @override
  @JsonKey()
  String tag;
  String? server;
  @JsonKey(name: 'server_port')
  int? serverPort;
  String? username;
  String? password;
  @JsonKey(name: 'insecure_concurrency')
  int? insecureConcurrency;
  @JsonKey(name: 'extra_headers')
  HTTPHeader? extraHeaders;
  @JsonKey(name: 'stream_receive_window')
  Object? streamReceiveWindow;
  @JsonKey(name: 'udp_over_tcp')
  Object? udpOverTcp;
  bool? quic;
  @JsonKey(name: 'quic_congestion_control')
  String? quicCongestionControl;
  @JsonKey(name: 'quic_session_receive_window')
  Object? quicSessionReceiveWindow;
  OutboundTLSOptions? tls;

  NaiveOutbound({
    required this.tag,
    // 可空字段省略（默认 null）
  });

  @override
  String get type => typeName;

  factory NaiveOutbound.fromJson(Map<String, dynamic> json) =>
      _$NaiveOutboundFromJson(json);

  @override
  Map<String, dynamic> toJson() =>
      {'type': typeName, ..._$NaiveOutboundToJson(this)};
}
