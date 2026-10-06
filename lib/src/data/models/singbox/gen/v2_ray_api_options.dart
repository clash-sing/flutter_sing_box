// 本文件由 tool/gen_models.dart 生成，勿手改。
import 'package:json_annotation/json_annotation.dart';

import 'v2_ray_stats_service_options.dart';

part 'v2_ray_api_options.g.dart';

@JsonSerializable(explicitToJson: true, includeIfNull: false)
class V2RayAPIOptions {
  String? listen;
  V2RayStatsServiceOptions? stats;

  V2RayAPIOptions();

  factory V2RayAPIOptions.fromJson(Map<String, dynamic> json) =>
      _$V2RayAPIOptionsFromJson(json);

  Map<String, dynamic> toJson() => _$V2RayAPIOptionsToJson(this);
}
