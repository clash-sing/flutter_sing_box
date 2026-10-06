// 本文件由 tool/gen_models.dart 生成，勿手改。
part of 'outbound.dart';

@JsonSerializable(explicitToJson: true, includeIfNull: false)
class ShadowtlsOutbound extends Outbound with DialerFields {
  static const typeName = 'shadowtls';

  @override
  String tag;
  String? server;
  @JsonKey(name: 'server_port')
  int? serverPort;
  int? version;
  String? password;
  OutboundTLSOptions? tls;

  ShadowtlsOutbound({
    required this.tag,
    // 可空字段省略（默认 null）
  });

  @override
  String get type => typeName;

  factory ShadowtlsOutbound.fromJson(Map<String, dynamic> json) =>
      _$ShadowtlsOutboundFromJson(json);

  @override
  Map<String, dynamic> toJson() =>
      {'type': typeName, ..._$ShadowtlsOutboundToJson(this)};
}
