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
  @JsonKey(name: "external_controller")
  String? externalController;
  @JsonKey(name: "external_ui")
  String? externalUi;
  @JsonKey(name: "external_ui_download_url")
  String? externalUiDownloadUrl;
  @JsonKey(name: "external_ui_download_detour")
  String? externalUiDownloadDetour;
  String? secret;
  @JsonKey(name: "default_mode")
  String? defaultMode;
  @JsonKey(name: "access_control_allow_origin")
  List<String>? accessControlAllowOrigin;
  @JsonKey(name: "access_control_allow_private_network")
  bool? accessControlAllowPrivateNetwork;

  ClashApi({
    this.externalController,
    this.externalUi,
    this.externalUiDownloadUrl,
    this.externalUiDownloadDetour,
    this.secret,
    this.defaultMode,
    this.accessControlAllowOrigin,
    this.accessControlAllowPrivateNetwork,
  });

  factory ClashApi.fromJson(Map<String, dynamic> json) => _$ClashApiFromJson(json);

  Map<String, dynamic> toJson() => _$ClashApiToJson(this);
}

