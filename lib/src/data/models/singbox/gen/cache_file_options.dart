// 本文件由 tool/gen_models.dart 生成，勿手改。
import 'package:json_annotation/json_annotation.dart';

part 'cache_file_options.g.dart';

/// 由官方 JSON schema `$defs/CacheFileOptions` 定义的配置模型。
@JsonSerializable(explicitToJson: true, includeIfNull: false)
class CacheFileOptions {
  /// 对应 JSON 键 `enabled`，可空（null 不参与序列化）。
  bool? enabled;
  /// 对应 JSON 键 `path`，可空（null 不参与序列化）。
  String? path;
  /// 对应 JSON 键 `cache_id`，可空（null 不参与序列化）。
  @JsonKey(name: 'cache_id')
  String? cacheId;
  /// 对应 JSON 键 `store_fakeip`，可空（null 不参与序列化）。
  @JsonKey(name: 'store_fakeip')
  bool? storeFakeip;
  /// 对应 JSON 键 `store_dns`，可空（null 不参与序列化）。
  @JsonKey(name: 'store_dns')
  bool? storeDns;
  /// 对应 JSON 键 `buffer_size`，可空（null 不参与序列化）。
  @JsonKey(name: 'buffer_size')
  Object? bufferSize;
  /// 对应 JSON 键 `flush_interval`，可空（null 不参与序列化）。
  @JsonKey(name: 'flush_interval')
  String? flushInterval;

  /// 构造实例；可空字段省略时为 `null`。
  CacheFileOptions();

  /// 从 JSON 对象反序列化为本类型。
  factory CacheFileOptions.fromJson(Map<String, dynamic> json) =>
      _$CacheFileOptionsFromJson(json);

  /// 序列化为 JSON 对象。
  Map<String, dynamic> toJson() => _$CacheFileOptionsToJson(this);
}
