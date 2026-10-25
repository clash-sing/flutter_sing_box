// 本文件由 tool/gen_models.dart 生成，勿手改。
import 'package:json_annotation/json_annotation.dart';

part 'v2_ray_stats_service_options.g.dart';

/// 由官方 JSON schema `$defs/V2RayStatsServiceOptions` 定义的配置模型。
@JsonSerializable(explicitToJson: true, includeIfNull: false)
class V2RayStatsServiceOptions {
  /// 对应 JSON 键 `enabled`，可空（null 不参与序列化）。
  bool? enabled;
  /// 对应 JSON 键 `inbounds`，可空（null 不参与序列化）。
  List<String>? inbounds;
  /// 对应 JSON 键 `outbounds`，可空（null 不参与序列化）。
  List<String>? outbounds;
  /// 对应 JSON 键 `users`，可空（null 不参与序列化）。
  List<String>? users;

  /// 构造实例；可空字段省略时为 `null`。
  V2RayStatsServiceOptions();

  /// 从 JSON 对象反序列化为本类型。
  factory V2RayStatsServiceOptions.fromJson(Map<String, dynamic> json) =>
      _$V2RayStatsServiceOptionsFromJson(json);

  /// 序列化为 JSON 对象。
  Map<String, dynamic> toJson() => _$V2RayStatsServiceOptionsToJson(this);
}
