// 本文件由 tool/gen_models.dart 生成，勿手改。
import 'package:json_annotation/json_annotation.dart';

part 'cache_file_options.g.dart';

@JsonSerializable(explicitToJson: true, includeIfNull: false)
class CacheFileOptions {
  bool? enabled;
  String? path;
  @JsonKey(name: 'cache_id')
  String? cacheId;
  @JsonKey(name: 'store_fakeip')
  bool? storeFakeip;
  @JsonKey(name: 'store_dns')
  bool? storeDns;
  @JsonKey(name: 'buffer_size')
  Object? bufferSize;
  @JsonKey(name: 'flush_interval')
  String? flushInterval;

  CacheFileOptions();

  factory CacheFileOptions.fromJson(Map<String, dynamic> json) =>
      _$CacheFileOptionsFromJson(json);

  Map<String, dynamic> toJson() => _$CacheFileOptionsToJson(this);
}
