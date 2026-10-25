// 本文件由 tool/gen_models.dart 生成，勿手改。
import 'package:json_annotation/json_annotation.dart';

import 'cache_file_options.dart';
import 'clash_api_options.dart';
import 'debug_options.dart';
import 'v2_ray_api_options.dart';

part 'experimental_options.g.dart';

/// 顶层 `experimental` 配置段模型。
@JsonSerializable(explicitToJson: true, includeIfNull: false)
class ExperimentalOptions {
  /// 对应 JSON 键 `cache_file`，可空（null 不参与序列化）。
  @JsonKey(name: 'cache_file')
  CacheFileOptions? cacheFile;
  /// 对应 JSON 键 `clash_api`，可空（null 不参与序列化）。
  @JsonKey(name: 'clash_api')
  ClashAPIOptions? clashApi;
  /// 对应 JSON 键 `v2ray_api`，可空（null 不参与序列化）。
  @JsonKey(name: 'v2ray_api')
  V2RayAPIOptions? v2rayApi;
  /// 对应 JSON 键 `debug`，可空（null 不参与序列化）。
  DebugOptions? debug;

  /// 构造实例；可空字段省略时为 `null`。
  ExperimentalOptions();

  /// 从 JSON 对象反序列化为本类型。
  factory ExperimentalOptions.fromJson(Map<String, dynamic> json) =>
      _$ExperimentalOptionsFromJson(json);

  /// 序列化为 JSON 对象。
  Map<String, dynamic> toJson() => _$ExperimentalOptionsToJson(this);
}
