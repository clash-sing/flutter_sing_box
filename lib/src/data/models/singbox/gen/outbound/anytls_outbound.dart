// 本文件由 tool/gen_models.dart 生成，勿手改。
part of 'outbound.dart';

@JsonSerializable(explicitToJson: true, includeIfNull: false)
class AnytlsOutbound extends Outbound with DialerFields {
  static const typeName = 'anytls';

  @override
  @JsonKey()
  String tag;
  String? server;
  @JsonKey(name: 'server_port')
  int? serverPort;
  OutboundTLSOptions? tls;
  String? password;
  @JsonKey(name: 'idle_session_check_interval')
  String? idleSessionCheckInterval;
  @JsonKey(name: 'idle_session_timeout')
  String? idleSessionTimeout;
  @JsonKey(name: 'min_idle_session')
  int? minIdleSession;
  @JsonKey(name: 'client_metadata')
  String? clientMetadata;

  AnytlsOutbound({
    required this.tag,
    // 可空字段省略（默认 null）
  });

  @override
  String get type => typeName;

  factory AnytlsOutbound.fromJson(Map<String, dynamic> json) =>
      _$AnytlsOutboundFromJson(json);

  @override
  Map<String, dynamic> toJson() =>
      {'type': typeName, ..._$AnytlsOutboundToJson(this)};
}
