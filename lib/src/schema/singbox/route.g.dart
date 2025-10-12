// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'route.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Route _$RouteFromJson(Map<String, dynamic> json) => Route(
  defaultDomainResolver: json['default_domain_resolver'] as String,
  rules: (json['rules'] as List<dynamic>)
      .map((e) => RouteRule.fromJson(e as Map<String, dynamic>))
      .toList(),
  routeFinal: json['final'] as String,
  autoDetectInterface: json['auto_detect_interface'] as bool,
  ruleSet: (json['rule_set'] as List<dynamic>)
      .map((e) => RuleSet.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$RouteToJson(Route instance) => <String, dynamic>{
  'default_domain_resolver': instance.defaultDomainResolver,
  'rules': instance.rules,
  'final': instance.routeFinal,
  'auto_detect_interface': instance.autoDetectInterface,
  'rule_set': instance.ruleSet,
};

RouteRule _$RouteRuleFromJson(Map<String, dynamic> json) => RouteRule(
  action: json['action'] as String?,
  protocol: json['protocol'],
  clashMode: json['clash_mode'] as String?,
  outbound: json['outbound'] as String?,
  ipIsPrivate: json['ip_is_private'] as bool?,
  ruleSet: (json['rule_set'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
);

Map<String, dynamic> _$RouteRuleToJson(RouteRule instance) => <String, dynamic>{
  'action': instance.action,
  'protocol': instance.protocol,
  'clash_mode': instance.clashMode,
  'outbound': instance.outbound,
  'ip_is_private': instance.ipIsPrivate,
  'rule_set': instance.ruleSet,
};

RuleSet _$RuleSetFromJson(Map<String, dynamic> json) => RuleSet(
  tag: json['tag'] as String,
  type: json['type'] as String,
  format: json['format'] as String,
  url: json['url'] as String,
  downloadDetour: json['download_detour'] as String,
);

Map<String, dynamic> _$RuleSetToJson(RuleSet instance) => <String, dynamic>{
  'tag': instance.tag,
  'type': instance.type,
  'format': instance.format,
  'url': instance.url,
  'download_detour': instance.downloadDetour,
};
