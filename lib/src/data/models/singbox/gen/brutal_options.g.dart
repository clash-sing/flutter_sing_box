// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'brutal_options.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BrutalOptions _$BrutalOptionsFromJson(Map<String, dynamic> json) =>
    BrutalOptions()
      ..enabled = json['enabled'] as bool?
      ..upMbps = (json['up_mbps'] as num?)?.toInt()
      ..downMbps = (json['down_mbps'] as num?)?.toInt();

Map<String, dynamic> _$BrutalOptionsToJson(BrutalOptions instance) =>
    <String, dynamic>{
      'enabled': ?instance.enabled,
      'up_mbps': ?instance.upMbps,
      'down_mbps': ?instance.downMbps,
    };
