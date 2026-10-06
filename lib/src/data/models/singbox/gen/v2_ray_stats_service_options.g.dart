// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'v2_ray_stats_service_options.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

V2RayStatsServiceOptions _$V2RayStatsServiceOptionsFromJson(
  Map<String, dynamic> json,
) => V2RayStatsServiceOptions()
  ..enabled = json['enabled'] as bool?
  ..inbounds = (json['inbounds'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList()
  ..outbounds = (json['outbounds'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList()
  ..users = (json['users'] as List<dynamic>?)?.map((e) => e as String).toList();

Map<String, dynamic> _$V2RayStatsServiceOptionsToJson(
  V2RayStatsServiceOptions instance,
) => <String, dynamic>{
  'enabled': ?instance.enabled,
  'inbounds': ?instance.inbounds,
  'outbounds': ?instance.outbounds,
  'users': ?instance.users,
};
