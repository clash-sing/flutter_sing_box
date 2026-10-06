// 本文件由 tool/gen_models.dart 生成，勿手改。
part of 'outbound.dart';

@JsonSerializable(explicitToJson: true, includeIfNull: false)
class ShadowsocksOutbound extends Outbound with DialerFields {
  static const typeName = 'shadowsocks';

  @override
  @JsonKey()
  String tag;
  String? server;
  @JsonKey(name: 'server_port')
  int? serverPort;
  String? method;
  String? password;
  String? plugin;
  @JsonKey(name: 'plugin_opts')
  String? pluginOpts;
  Object? network;
  @JsonKey(name: 'udp_over_tcp')
  Object? udpOverTcp;
  OutboundMultiplexOptions? multiplex;

  ShadowsocksOutbound({
    required this.tag,
    // 可空字段省略（默认 null）
  });

  @override
  String get type => typeName;

  factory ShadowsocksOutbound.fromJson(Map<String, dynamic> json) =>
      _$ShadowsocksOutboundFromJson(json);

  @override
  Map<String, dynamic> toJson() =>
      {'type': typeName, ..._$ShadowsocksOutboundToJson(this)};
}
