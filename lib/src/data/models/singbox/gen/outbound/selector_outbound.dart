// 本文件由 tool/gen_models.dart 生成，勿手改。
part of 'outbound.dart';

/// `type` 判别值为 `selector` 的出站配置。
@JsonSerializable(explicitToJson: true, includeIfNull: false)
class SelectorOutbound extends Outbound {
  /// 本类的 `type` 判别值。
  static const typeName = 'selector';

  /// 对应 JSON 键 `tag`，必填。
  @override
  String tag;
  /// 对应 JSON 键 `outbounds`，可空（null 不参与序列化）。
  List<String>? outbounds;
  /// 对应 JSON 键 `default`，可空（null 不参与序列化）。
  @JsonKey(name: 'default')
  String? default_;
  /// 对应 JSON 键 `interrupt_exist_connections`，可空（null 不参与序列化）。
  @JsonKey(name: 'interrupt_exist_connections')
  bool? interruptExistConnections;

  /// 以 [tag] 构造；可空字段省略时为 `null`。
  SelectorOutbound({
    required this.tag,
    // 可空字段省略（默认 null）
  });

  /// `type` 判别值，固定为 [typeName]。
  @override
  String get type => typeName;

  /// 从 JSON 对象反序列化为本类型。
  factory SelectorOutbound.fromJson(Map<String, dynamic> json) =>
      _$SelectorOutboundFromJson(json);

  /// 序列化为 JSON；输出携带 `type` 判别键。
  @override
  Map<String, dynamic> toJson() =>
      {'type': typeName, ..._$SelectorOutboundToJson(this)};
}
