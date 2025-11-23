import 'package:json_annotation/json_annotation.dart';

part 'experimental.g.dart';

@JsonSerializable(explicitToJson: true)
class Experimental {
  @JsonKey(name: "cache_file")
  CacheFile? cacheFile;
  @JsonKey(name: "clash_api")
  ClashApi? clashApi;

  Experimental({
    this.cacheFile,
    this.clashApi,
  });

  factory Experimental.fromJson(Map<String, dynamic> json) => _$ExperimentalFromJson(json);

  Map<String, dynamic> toJson() => _$ExperimentalToJson(this);
}

@JsonSerializable()
class CacheFile {
  bool? enabled;
  @JsonKey(name: "store_fakeip")
  bool? storeFakeip;
  @JsonKey(name: "store_rdrc")
  bool? storeRdrc;

  CacheFile({
    this.enabled,
    this.storeFakeip,
    this.storeRdrc,
  });

  factory CacheFile.fromJson(Map<String, dynamic> json) => _$CacheFileFromJson(json);

  Map<String, dynamic> toJson() => _$CacheFileToJson(this);
}

@JsonSerializable()
class ClashApi {
  String? secret;
  @JsonKey(name: "external_controller")
  String? externalController;
  @JsonKey(name: "external_ui")
  String? externalUi;
  @JsonKey(name: "external_ui_download_url")
  String? externalUiDownloadUrl;

  ClashApi({
    this.secret,
    this.externalController,
    this.externalUi,
    this.externalUiDownloadUrl,
  });

  factory ClashApi.fromJson(Map<String, dynamic> json) => _$ClashApiFromJson(json);

  Map<String, dynamic> toJson() => _$ClashApiToJson(this);
}

