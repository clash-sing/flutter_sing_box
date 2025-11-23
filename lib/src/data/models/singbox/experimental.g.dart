// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'experimental.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Experimental _$ExperimentalFromJson(Map<String, dynamic> json) => Experimental(
  cacheFile: json['cache_file'] == null
      ? null
      : CacheFile.fromJson(json['cache_file'] as Map<String, dynamic>),
  clashApi: json['clash_api'] == null
      ? null
      : ClashApi.fromJson(json['clash_api'] as Map<String, dynamic>),
);

Map<String, dynamic> _$ExperimentalToJson(Experimental instance) =>
    <String, dynamic>{
      'cache_file': ?instance.cacheFile?.toJson(),
      'clash_api': ?instance.clashApi?.toJson(),
    };

CacheFile _$CacheFileFromJson(Map<String, dynamic> json) => CacheFile(
  enabled: json['enabled'] as bool?,
  storeFakeip: json['store_fakeip'] as bool?,
  storeRdrc: json['store_rdrc'] as bool?,
);

Map<String, dynamic> _$CacheFileToJson(CacheFile instance) => <String, dynamic>{
  'enabled': ?instance.enabled,
  'store_fakeip': ?instance.storeFakeip,
  'store_rdrc': ?instance.storeRdrc,
};

ClashApi _$ClashApiFromJson(Map<String, dynamic> json) => ClashApi(
  secret: json['secret'] as String?,
  externalController: json['external_controller'] as String?,
  externalUi: json['external_ui'] as String?,
  externalUiDownloadUrl: json['external_ui_download_url'] as String?,
);

Map<String, dynamic> _$ClashApiToJson(ClashApi instance) => <String, dynamic>{
  'secret': ?instance.secret,
  'external_controller': ?instance.externalController,
  'external_ui': ?instance.externalUi,
  'external_ui_download_url': ?instance.externalUiDownloadUrl,
};
