// 本文件由 tool/gen_models.dart 生成，勿手改。
part of 'outbound.dart';

/// `type` 判别值为 `block` 的出站配置。
@JsonSerializable(explicitToJson: true, includeIfNull: false)
class BlockOutbound extends Outbound {
  /// 本类的 `type` 判别值。
  static const typeName = 'block';

  /// 对应 JSON 键 `tag`，必填。
  @override
  String tag;

  /// 以 [tag] 构造；可空字段省略时为 `null`。
  BlockOutbound({
    required this.tag,
  });

  /// `type` 判别值，固定为 [typeName]。
  @override
  String get type => typeName;

  /// 从 JSON 对象反序列化为本类型。
  factory BlockOutbound.fromJson(Map<String, dynamic> json) =>
      _$BlockOutboundFromJson(json);

  /// 序列化为 JSON；输出携带 `type` 判别键。
  @override
  Map<String, dynamic> toJson() =>
      {'type': typeName, ..._$BlockOutboundToJson(this)};
}
