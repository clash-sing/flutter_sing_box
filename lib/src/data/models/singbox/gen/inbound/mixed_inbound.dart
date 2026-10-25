// 本文件由 tool/gen_models.dart 生成，勿手改。
part of 'inbound.dart';

/// `type` 判别值为 `mixed` 的入站配置。
@JsonSerializable(explicitToJson: true, includeIfNull: false)
class MixedInbound extends Inbound with ListenFields, DialerFields {
  /// 本类的 `type` 判别值。
  static const typeName = 'mixed';

  /// 对应 JSON 键 `tag`，必填。
  @override
  String tag;
  /// 对应 JSON 键 `listen`，可空（null 不参与序列化）。
  Object? listen;
  /// 对应 JSON 键 `listen_port`，可空（null 不参与序列化）。
  @JsonKey(name: 'listen_port')
  int? listenPort;
  /// 对应 JSON 键 `users`，可空（null 不参与序列化）。
  List<User>? users;
  /// 对应 JSON 键 `set_system_proxy`，可空（null 不参与序列化）。
  @JsonKey(name: 'set_system_proxy')
  bool? setSystemProxy;
  /// 对应 JSON 键 `tls`，可空（null 不参与序列化）。
  InboundTLSOptions? tls;

  /// 以 [tag] 构造；可空字段省略时为 `null`。
  MixedInbound({
    required this.tag,
    // 可空字段省略（默认 null）
  });

  /// `type` 判别值，固定为 [typeName]。
  @override
  String get type => typeName;

  /// 从 JSON 对象反序列化为本类型。
  factory MixedInbound.fromJson(Map<String, dynamic> json) =>
      _$MixedInboundFromJson(json);

  /// 序列化为 JSON；输出携带 `type` 判别键。
  @override
  Map<String, dynamic> toJson() =>
      {'type': typeName, ..._$MixedInboundToJson(this)};
}
