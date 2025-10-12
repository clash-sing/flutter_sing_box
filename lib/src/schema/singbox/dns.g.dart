// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dns.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Dns _$DnsFromJson(Map<String, dynamic> json) => Dns(
  servers: (json['servers'] as List<dynamic>)
      .map((e) => Server.fromJson(e as Map<String, dynamic>))
      .toList(),
  rules: (json['rules'] as List<dynamic>)
      .map((e) => DnsRule.fromJson(e as Map<String, dynamic>))
      .toList(),
  independentCache: json['independent_cache'] as bool,
  dnsFinal: json['final'] as String,
  strategy: json['strategy'] as String,
);

Map<String, dynamic> _$DnsToJson(Dns instance) => <String, dynamic>{
  'servers': instance.servers.map((e) => e.toJson()).toList(),
  'rules': instance.rules.map((e) => e.toJson()).toList(),
  'independent_cache': instance.independentCache,
  'final': instance.dnsFinal,
  'strategy': instance.strategy,
};

Server _$ServerFromJson(Map<String, dynamic> json) => Server(
  tag: json['tag'] as String,
  type: json['type'] as String,
  server: json['server'] as String?,
  inet4Range: json['inet4_range'] as String?,
  inet6Range: json['inet6_range'] as String?,
);

Map<String, dynamic> _$ServerToJson(Server instance) => <String, dynamic>{
  'tag': instance.tag,
  'type': instance.type,
  'server': ?instance.server,
  'inet4_range': ?instance.inet4Range,
  'inet6_range': ?instance.inet6Range,
};

DnsRule _$DnsRuleFromJson(Map<String, dynamic> json) => DnsRule(
  clashMode: json['clash_mode'] as String?,
  server: json['server'] as String,
  ruleSet: (json['rule_set'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
  queryType: (json['query_type'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
);

Map<String, dynamic> _$DnsRuleToJson(DnsRule instance) => <String, dynamic>{
  'clash_mode': ?instance.clashMode,
  'server': instance.server,
  'rule_set': ?instance.ruleSet,
  'query_type': ?instance.queryType,
};
