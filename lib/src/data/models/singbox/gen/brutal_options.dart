// 本文件由 tool/gen_models.dart 生成，勿手改。
import 'package:json_annotation/json_annotation.dart';

part 'brutal_options.g.dart';

/// 由官方 JSON schema `$defs/BrutalOptions` 定义的配置模型。
@JsonSerializable(explicitToJson: true, includeIfNull: false)
class BrutalOptions {
  /// 对应 JSON 键 `enabled`，可空（null 不参与序列化）。
  bool? enabled;
  /// 对应 JSON 键 `up_mbps`，可空（null 不参与序列化）。
  @JsonKey(name: 'up_mbps')
  int? upMbps;
  /// 对应 JSON 键 `down_mbps`，可空（null 不参与序列化）。
  @JsonKey(name: 'down_mbps')
  int? downMbps;

  /// 构造实例；可空字段省略时为 `null`。
  BrutalOptions();

  /// 从 JSON 对象反序列化为本类型。
  factory BrutalOptions.fromJson(Map<String, dynamic> json) =>
      _$BrutalOptionsFromJson(json);

  /// 序列化为 JSON 对象。
  Map<String, dynamic> toJson() => _$BrutalOptionsToJson(this);
}
