// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'clash_group.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ClashGroup _$ClashGroupFromJson(Map<String, dynamic> json) => ClashGroup(
  name: json['name'] as String,
  type: json['type'] as String,
  proxies: (json['proxies'] as List<dynamic>).map((e) => e as String).toList(),
  url: json['url'] as String?,
  interval: (json['interval'] as num?)?.toInt(),
);

Map<String, dynamic> _$ClashGroupToJson(ClashGroup instance) =>
    <String, dynamic>{
      'name': instance.name,
      'type': instance.type,
      'proxies': instance.proxies,
      'url': ?instance.url,
      'interval': ?instance.interval,
    };
