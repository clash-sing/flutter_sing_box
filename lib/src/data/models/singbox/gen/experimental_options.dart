// 本文件由 tool/gen_models.dart 生成，勿手改。
import 'package:json_annotation/json_annotation.dart';

import 'cache_file_options.dart';
import 'clash_api_options.dart';
import 'debug_options.dart';
import 'v2_ray_api_options.dart';

part 'experimental_options.g.dart';

@JsonSerializable(explicitToJson: true, includeIfNull: false)
class ExperimentalOptions {
  @JsonKey(name: 'cache_file')
  CacheFileOptions? cacheFile;
  @JsonKey(name: 'clash_api')
  ClashAPIOptions? clashApi;
  @JsonKey(name: 'v2ray_api')
  V2RayAPIOptions? v2rayApi;
  DebugOptions? debug;

  ExperimentalOptions();

  factory ExperimentalOptions.fromJson(Map<String, dynamic> json) =>
      _$ExperimentalOptionsFromJson(json);

  Map<String, dynamic> toJson() => _$ExperimentalOptionsToJson(this);
}
