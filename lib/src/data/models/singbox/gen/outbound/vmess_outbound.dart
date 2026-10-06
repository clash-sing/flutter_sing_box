// 本文件由 tool/gen_models.dart 生成，勿手改。
part of 'outbound.dart';

@JsonSerializable(explicitToJson: true, includeIfNull: false)
class VmessOutbound extends Outbound with DialerFields {
  static const typeName = 'vmess';

  @override
  @JsonKey()
  String tag;
  String? server;
  @JsonKey(name: 'server_port')
  int? serverPort;
  String? uuid;
  String? security;
  @JsonKey(name: 'alter_id')
  int? alterId;
  @JsonKey(name: 'global_padding')
  bool? globalPadding;
  @JsonKey(name: 'authenticated_length')
  bool? authenticatedLength;
  Object? network;
  OutboundTLSOptions? tls;
  @JsonKey(name: 'packet_encoding')
  String? packetEncoding;
  OutboundMultiplexOptions? multiplex;
  V2RayTransport? transport;

  VmessOutbound({
    required this.tag,
    // 可空字段省略（默认 null）
  });

  @override
  String get type => typeName;

  factory VmessOutbound.fromJson(Map<String, dynamic> json) =>
      _$VmessOutboundFromJson(json);

  @override
  Map<String, dynamic> toJson() =>
      {'type': typeName, ..._$VmessOutboundToJson(this)};
}
