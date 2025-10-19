import 'package:json_annotation/json_annotation.dart';

part 'experimental.g.dart';

@JsonSerializable(explicitToJson: true)
class Experimental {
  @JsonKey(name: "cache_file")
  CacheFile cacheFile;

  Experimental({
    required this.cacheFile,
  });

  factory Experimental.fromJson(Map<String, dynamic> json) => _$ExperimentalFromJson(json);

  Map<String, dynamic> toJson() => _$ExperimentalToJson(this);
}

@JsonSerializable()
class CacheFile {
  bool enabled;
  @JsonKey(name: "store_fakeip")
  bool storeFakeip;

  CacheFile({
    required this.enabled,
    required this.storeFakeip,
  });

  factory CacheFile.fromJson(Map<String, dynamic> json) => _$CacheFileFromJson(json);

  Map<String, dynamic> toJson() => _$CacheFileToJson(this);
}