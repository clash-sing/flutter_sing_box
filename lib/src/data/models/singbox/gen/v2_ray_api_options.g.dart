// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'v2_ray_api_options.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

V2RayAPIOptions _$V2RayAPIOptionsFromJson(Map<String, dynamic> json) =>
    V2RayAPIOptions()
      ..listen = json['listen'] as String?
      ..stats = json['stats'] == null
          ? null
          : V2RayStatsServiceOptions.fromJson(
              json['stats'] as Map<String, dynamic>,
            );

Map<String, dynamic> _$V2RayAPIOptionsToJson(V2RayAPIOptions instance) =>
    <String, dynamic>{
      'listen': ?instance.listen,
      'stats': ?instance.stats?.toJson(),
    };
