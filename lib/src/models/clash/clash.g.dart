// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'clash.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Clash _$ClashFromJson(Map<String, dynamic> json) => Clash(
  proxies: (json['proxies'] as List<dynamic>)
      .map((e) => ClashProxy.fromJson(e as Map<String, dynamic>))
      .toList(),
  proxyGroups: (json['proxy-groups'] as List<dynamic>)
      .map((e) => ClashGroup.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$ClashToJson(Clash instance) => <String, dynamic>{
  'proxies': instance.proxies.map((e) => e.toJson()).toList(),
  'proxy-groups': instance.proxyGroups.map((e) => e.toJson()).toList(),
};
