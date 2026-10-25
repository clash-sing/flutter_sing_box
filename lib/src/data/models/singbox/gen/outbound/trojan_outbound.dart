// 本文件由 tool/gen_models.dart 生成，勿手改。
part of 'outbound.dart';

/// `type` 判别值为 `trojan` 的出站配置。
@JsonSerializable(explicitToJson: true, includeIfNull: false)
class TrojanOutbound extends Outbound with DialerFields {
  /// 本类的 `type` 判别值。
  static const typeName = 'trojan';

  /// 对应 JSON 键 `tag`，必填。
  @override
  String tag;
  /// 对应 JSON 键 `server`，可空（null 不参与序列化）。
  String? server;
  /// 对应 JSON 键 `server_port`，可空（null 不参与序列化）。
  @JsonKey(name: 'server_port')
  int? serverPort;
  /// 对应 JSON 键 `password`，可空（null 不参与序列化）。
  String? password;
  /// 对应 JSON 键 `network`，可空（null 不参与序列化）。
  Object? network;
  /// 对应 JSON 键 `tls`，可空（null 不参与序列化）。
  OutboundTLSOptions? tls;
  /// 对应 JSON 键 `multiplex`，可空（null 不参与序列化）。
  OutboundMultiplexOptions? multiplex;
  /// 对应 JSON 键 `transport`，可空（null 不参与序列化）。
  V2RayTransport? transport;

  /// 以 [tag] 构造；可空字段省略时为 `null`。
  TrojanOutbound({
    required this.tag,
    // 可空字段省略（默认 null）
  });

  /// `type` 判别值，固定为 [typeName]。
  @override
  String get type => typeName;

  /// 从 JSON 对象反序列化为本类型。
  factory TrojanOutbound.fromJson(Map<String, dynamic> json) =>
      _$TrojanOutboundFromJson(json);

  /// 序列化为 JSON；输出携带 `type` 判别键。
  @override
  Map<String, dynamic> toJson() =>
      {'type': typeName, ..._$TrojanOutboundToJson(this)};
}
