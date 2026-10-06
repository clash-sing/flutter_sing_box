// 本文件由 tool/gen_models.dart 生成，勿手改。
part of 'outbound.dart';

@JsonSerializable(explicitToJson: true, includeIfNull: false)
class SocksOutbound extends Outbound with DialerFields {
  static const typeName = 'socks';

  @override
  @JsonKey()
  String tag;
  String? server;
  @JsonKey(name: 'server_port')
  int? serverPort;
  String? version;
  String? username;
  String? password;
  Object? network;
  @JsonKey(name: 'udp_over_tcp')
  Object? udpOverTcp;

  SocksOutbound({
    required this.tag,
    // 可空字段省略（默认 null）
  });

  @override
  String get type => typeName;

  factory SocksOutbound.fromJson(Map<String, dynamic> json) =>
      _$SocksOutboundFromJson(json);

  @override
  Map<String, dynamic> toJson() =>
      {'type': typeName, ..._$SocksOutboundToJson(this)};
}
