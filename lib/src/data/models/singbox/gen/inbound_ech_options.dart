// 本文件由 tool/gen_models.dart 生成，勿手改。
import 'package:json_annotation/json_annotation.dart';

part 'inbound_ech_options.g.dart';

/// 由官方 JSON schema `$defs/InboundECHOptions` 定义的配置模型。
@JsonSerializable(explicitToJson: true, includeIfNull: false)
class InboundECHOptions {
  /// 对应 JSON 键 `enabled`，可空（null 不参与序列化）。
  bool? enabled;
  /// 对应 JSON 键 `key`，可空（null 不参与序列化）。
  Object? key;
  /// 对应 JSON 键 `key_path`，可空（null 不参与序列化）。
  @JsonKey(name: 'key_path')
  String? keyPath;

  /// 构造实例；可空字段省略时为 `null`。
  InboundECHOptions();

  /// 从 JSON 对象反序列化为本类型。
  factory InboundECHOptions.fromJson(Map<String, dynamic> json) =>
      _$InboundECHOptionsFromJson(json);

  /// 序列化为 JSON 对象。
  Map<String, dynamic> toJson() => _$InboundECHOptionsToJson(this);
}
