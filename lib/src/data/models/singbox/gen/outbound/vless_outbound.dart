// 本文件由 tool/gen_models.dart 生成，勿手改。
part of 'outbound.dart';

@JsonSerializable(explicitToJson: true, includeIfNull: false)
class VlessOutbound extends Outbound with DialerFields {
  static const typeName = 'vless';

  @override
  @JsonKey()
  String tag;
  String? server;
  @JsonKey(name: 'server_port')
  int? serverPort;
  String? uuid;
  String? flow;
  Object? network;
  OutboundTLSOptions? tls;
  OutboundMultiplexOptions? multiplex;
  V2RayTransport? transport;
  @JsonKey(name: 'packet_encoding')
  String? packetEncoding;

  VlessOutbound({
    required this.tag,
    // 可空字段省略（默认 null）
  });

  @override
  String get type => typeName;

  factory VlessOutbound.fromJson(Map<String, dynamic> json) =>
      _$VlessOutboundFromJson(json);

  @override
  Map<String, dynamic> toJson() =>
      {'type': typeName, ..._$VlessOutboundToJson(this)};
}
