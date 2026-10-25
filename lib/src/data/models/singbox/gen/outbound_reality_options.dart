// 本文件由 tool/gen_models.dart 生成，勿手改。
import 'package:json_annotation/json_annotation.dart';

part 'outbound_reality_options.g.dart';

/// 由官方 JSON schema `$defs/OutboundRealityOptions` 定义的配置模型。
@JsonSerializable(explicitToJson: true, includeIfNull: false)
class OutboundRealityOptions {
  /// 对应 JSON 键 `enabled`，可空（null 不参与序列化）。
  bool? enabled;
  /// 对应 JSON 键 `public_key`，可空（null 不参与序列化）。
  @JsonKey(name: 'public_key')
  String? publicKey;
  /// 对应 JSON 键 `short_id`，可空（null 不参与序列化）。
  @JsonKey(name: 'short_id')
  String? shortId;

  /// 构造实例；可空字段省略时为 `null`。
  OutboundRealityOptions();

  /// 从 JSON 对象反序列化为本类型。
  factory OutboundRealityOptions.fromJson(Map<String, dynamic> json) =>
      _$OutboundRealityOptionsFromJson(json);

  /// 序列化为 JSON 对象。
  Map<String, dynamic> toJson() => _$OutboundRealityOptionsToJson(this);
}
