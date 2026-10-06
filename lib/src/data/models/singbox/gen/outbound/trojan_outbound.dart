// 本文件由 tool/gen_models.dart 生成，勿手改。
part of 'outbound.dart';

@JsonSerializable(explicitToJson: true, includeIfNull: false)
class TrojanOutbound extends Outbound with DialerFields {
  static const typeName = 'trojan';

  @override
  @JsonKey()
  String tag;
  String? server;
  @JsonKey(name: 'server_port')
  int? serverPort;
  String? password;
  Object? network;
  OutboundTLSOptions? tls;
  OutboundMultiplexOptions? multiplex;
  V2RayTransport? transport;

  TrojanOutbound({
    required this.tag,
    // 可空字段省略（默认 null）
  });

  @override
  String get type => typeName;

  factory TrojanOutbound.fromJson(Map<String, dynamic> json) =>
      _$TrojanOutboundFromJson(json);

  @override
  Map<String, dynamic> toJson() =>
      {'type': typeName, ..._$TrojanOutboundToJson(this)};
}
