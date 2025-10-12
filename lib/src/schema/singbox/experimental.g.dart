// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'experimental.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Experimental _$ExperimentalFromJson(Map<String, dynamic> json) => Experimental(
  cacheFile: CacheFile.fromJson(json['cache_file'] as Map<String, dynamic>),
);

Map<String, dynamic> _$ExperimentalToJson(Experimental instance) =>
    <String, dynamic>{'cache_file': instance.cacheFile};

CacheFile _$CacheFileFromJson(Map<String, dynamic> json) => CacheFile(
  enabled: json['enabled'] as bool,
  storeFakeip: json['store_fakeip'] as bool,
);

Map<String, dynamic> _$CacheFileToJson(CacheFile instance) => <String, dynamic>{
  'enabled': instance.enabled,
  'store_fakeip': instance.storeFakeip,
};
