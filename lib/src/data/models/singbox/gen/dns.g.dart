// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dns.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DNS _$DNSFromJson(Map<String, dynamic> json) => DNS()
  ..servers = (json['servers'] as List<dynamic>?)
      ?.map((e) => DNSServer.fromJson(e as Map<String, dynamic>))
      .toList()
  ..rules = (json['rules'] as List<dynamic>?)
      ?.map((e) => DNSRule.fromJson(e as Map<String, dynamic>))
      .toList()
  ..final_ = json['final'] as String?
  ..reverseMapping = json['reverse_mapping'] as bool?
  ..strategy = json['strategy']
  ..timeout = json['timeout'] as String?
  ..disableCache = json['disable_cache'] as bool?
  ..disableExpire = json['disable_expire'] as bool?
  ..cacheCapacity = (json['cache_capacity'] as num?)?.toInt()
  ..optimistic = json['optimistic']
  ..clientSubnet = json['client_subnet'];

Map<String, dynamic> _$DNSToJson(DNS instance) => <String, dynamic>{
  'servers': ?instance.servers?.map((e) => e.toJson()).toList(),
  'rules': ?instance.rules?.map((e) => e.toJson()).toList(),
  'final': ?instance.final_,
  'reverse_mapping': ?instance.reverseMapping,
  'strategy': ?instance.strategy,
  'timeout': ?instance.timeout,
  'disable_cache': ?instance.disableCache,
  'disable_expire': ?instance.disableExpire,
  'cache_capacity': ?instance.cacheCapacity,
  'optimistic': ?instance.optimistic,
  'client_subnet': ?instance.clientSubnet,
};
