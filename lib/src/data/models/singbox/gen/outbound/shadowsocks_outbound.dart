// 本文件由 tool/gen_models.dart 生成，勿手改。
part of 'outbound.dart';

/// `type` 判别值为 `shadowsocks` 的出站配置。
@JsonSerializable(explicitToJson: true, includeIfNull: false)
class ShadowsocksOutbound extends Outbound with DialerFields {
  /// 本类的 `type` 判别值。
  static const typeName = 'shadowsocks';

  /// 对应 JSON 键 `tag`，必填。
  @override
  String tag;
  /// 对应 JSON 键 `server`，可空（null 不参与序列化）。
  String? server;
  /// 对应 JSON 键 `server_port`，可空（null 不参与序列化）。
  @JsonKey(name: 'server_port')
  int? serverPort;
  /// 对应 JSON 键 `method`，可空（null 不参与序列化）。
  String? method;
  /// 对应 JSON 键 `password`，可空（null 不参与序列化）。
  String? password;
  /// 对应 JSON 键 `plugin`，可空（null 不参与序列化）。
  String? plugin;
  /// 对应 JSON 键 `plugin_opts`，可空（null 不参与序列化）。
  @JsonKey(name: 'plugin_opts')
  String? pluginOpts;
  /// 对应 JSON 键 `network`，可空（null 不参与序列化）。
  Object? network;
  /// 对应 JSON 键 `udp_over_tcp`，可空（null 不参与序列化）。
  @JsonKey(name: 'udp_over_tcp')
  Object? udpOverTcp;
  /// 对应 JSON 键 `multiplex`，可空（null 不参与序列化）。
  OutboundMultiplexOptions? multiplex;

  /// 以 [tag] 构造；可空字段省略时为 `null`。
  ShadowsocksOutbound({
    required this.tag,
    // 可空字段省略（默认 null）
  });

  /// `type` 判别值，固定为 [typeName]。
  @override
  String get type => typeName;

  /// 从 JSON 对象反序列化为本类型。
  factory ShadowsocksOutbound.fromJson(Map<String, dynamic> json) =>
      _$ShadowsocksOutboundFromJson(json);

  /// 序列化为 JSON；输出携带 `type` 判别键。
  @override
  Map<String, dynamic> toJson() =>
      {'type': typeName, ..._$ShadowsocksOutboundToJson(this)};
}
