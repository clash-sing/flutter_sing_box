// 本文件由 tool/gen_models.dart 生成，勿手改。
import 'package:json_annotation/json_annotation.dart';

import 'v2_ray_stats_service_options.dart';

part 'v2_ray_api_options.g.dart';

/// 由官方 JSON schema `$defs/V2RayAPIOptions` 定义的配置模型。
@JsonSerializable(explicitToJson: true, includeIfNull: false)
class V2RayAPIOptions {
  /// 对应 JSON 键 `listen`，可空（null 不参与序列化）。
  String? listen;
  /// 对应 JSON 键 `stats`，可空（null 不参与序列化）。
  V2RayStatsServiceOptions? stats;

  /// 构造实例；可空字段省略时为 `null`。
  V2RayAPIOptions();

  /// 从 JSON 对象反序列化为本类型。
  factory V2RayAPIOptions.fromJson(Map<String, dynamic> json) =>
      _$V2RayAPIOptionsFromJson(json);

  /// 序列化为 JSON 对象。
  Map<String, dynamic> toJson() => _$V2RayAPIOptionsToJson(this);
}
