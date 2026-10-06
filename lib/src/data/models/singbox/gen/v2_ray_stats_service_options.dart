// 本文件由 tool/gen_models.dart 生成，勿手改。
import 'package:json_annotation/json_annotation.dart';

part 'v2_ray_stats_service_options.g.dart';

@JsonSerializable(explicitToJson: true, includeIfNull: false)
class V2RayStatsServiceOptions {
  bool? enabled;
  List<String>? inbounds;
  List<String>? outbounds;
  List<String>? users;

  V2RayStatsServiceOptions();

  factory V2RayStatsServiceOptions.fromJson(Map<String, dynamic> json) =>
      _$V2RayStatsServiceOptionsFromJson(json);

  Map<String, dynamic> toJson() => _$V2RayStatsServiceOptionsToJson(this);
}
