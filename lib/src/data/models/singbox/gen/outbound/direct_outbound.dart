// 本文件由 tool/gen_models.dart 生成，勿手改。
part of 'outbound.dart';

/// `type` 判别值为 `direct` 的出站配置。
@JsonSerializable(explicitToJson: true, includeIfNull: false)
class DirectOutbound extends Outbound with DialerFields {
  /// 本类的 `type` 判别值。
  static const typeName = 'direct';

  /// 对应 JSON 键 `tag`，必填。
  @override
  String tag;

  /// 以 [tag] 构造；可空字段省略时为 `null`。
  DirectOutbound({
    required this.tag,
    // 可空字段省略（默认 null）
  });

  /// `type` 判别值，固定为 [typeName]。
  @override
  String get type => typeName;

  /// 从 JSON 对象反序列化为本类型。
  factory DirectOutbound.fromJson(Map<String, dynamic> json) =>
      _$DirectOutboundFromJson(json);

  /// 序列化为 JSON；输出携带 `type` 判别键。
  @override
  Map<String, dynamic> toJson() =>
      {'type': typeName, ..._$DirectOutboundToJson(this)};
}
