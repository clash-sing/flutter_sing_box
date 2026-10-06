// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'experimental_options.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ExperimentalOptions _$ExperimentalOptionsFromJson(Map<String, dynamic> json) =>
    ExperimentalOptions()
      ..cacheFile = json['cache_file'] == null
          ? null
          : CacheFileOptions.fromJson(
              json['cache_file'] as Map<String, dynamic>,
            )
      ..clashApi = json['clash_api'] == null
          ? null
          : ClashAPIOptions.fromJson(json['clash_api'] as Map<String, dynamic>)
      ..v2rayApi = json['v2ray_api'] == null
          ? null
          : V2RayAPIOptions.fromJson(json['v2ray_api'] as Map<String, dynamic>)
      ..debug = json['debug'] == null
          ? null
          : DebugOptions.fromJson(json['debug'] as Map<String, dynamic>);

Map<String, dynamic> _$ExperimentalOptionsToJson(
  ExperimentalOptions instance,
) => <String, dynamic>{
  'cache_file': ?instance.cacheFile?.toJson(),
  'clash_api': ?instance.clashApi?.toJson(),
  'v2ray_api': ?instance.v2rayApi?.toJson(),
  'debug': ?instance.debug?.toJson(),
};
