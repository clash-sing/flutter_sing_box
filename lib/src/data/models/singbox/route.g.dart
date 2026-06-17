// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'route.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Route _$RouteFromJson(Map<String, dynamic> json) => Route(
  rules: (json['rules'] as List<dynamic>)
      .map((e) => RouteRule.fromJson(e as Map<String, dynamic>))
      .toList(),
  autoDetectInterface: json['auto_detect_interface'] as bool?,
  defaultDomainResolver: json['default_domain_resolver'] as String?,
  routeFinal: json['final'] as String?,
  ruleSet: (json['rule_set'] as List<dynamic>?)
      ?.map((e) => RuleSet.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$RouteToJson(Route instance) => <String, dynamic>{
  'rules': instance.rules.map((e) => e.toJson()).toList(),
  'auto_detect_interface': ?instance.autoDetectInterface,
  'default_domain_resolver': ?instance.defaultDomainResolver,
  'final': ?instance.routeFinal,
  'rule_set': ?instance.ruleSet?.map((e) => e.toJson()).toList(),
};

RouteRule _$RouteRuleFromJson(Map<String, dynamic> json) => RouteRule(
  action: json['action'] as String? ?? RuleAction.route,
  outbound: json['outbound'] as String?,
  method: json['method'] as String?,
  noDrop: json['no_drop'] as bool?,
  protocol: json['protocol'],
  clashMode: json['clash_mode'] as String?,
  domain: (json['domain'] as List<dynamic>?)?.map((e) => e as String).toList(),
  domainSuffix: (json['domain_suffix'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
  domainKeyword: (json['domain_keyword'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
  domainRegex: (json['domain_regex'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
  processName: (json['process_name'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
  processPath: (json['process_path'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
  processPathRegex: (json['process_path_regex'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
  packageName: (json['package_name'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
  ipIsPrivate: json['ip_is_private'] as bool?,
  ruleSet: (json['rule_set'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
  ipCidr: (json['ip_cidr'] as List<dynamic>?)?.map((e) => e as String).toList(),
  sourceIpCidr: (json['source_ip_cidr'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
  port: (json['port'] as List<dynamic>?)
      ?.map((e) => (e as num).toInt())
      .toList(),
  portRange: (json['port_range'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
  sourcePort: (json['source_port'] as List<dynamic>?)
      ?.map((e) => (e as num).toInt())
      .toList(),
  sourcePortRange: (json['source_port_range'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
  timeout: json['timeout'] as String?,
  inbound: (json['inbound'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
  ipVersion: (json['ip_version'] as num?)?.toInt(),
  network: json['network'] as String?,
  client: (json['client'] as List<dynamic>?)?.map((e) => e as String).toList(),
  sourceIpIsPrivate: json['source_ip_is_private'] as bool?,
  packageNameRegex: (json['package_name_regex'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
  networkType: (json['network_type'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
  networkIsExpensive: json['network_is_expensive'] as bool?,
  networkIsConstrained: json['network_is_constrained'] as bool?,
  defaultInterfacAddress: (json['default_interface_address'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
  wifiSsid: (json['wifi_ssid'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
  wifiBssid: (json['wifi_bssid'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
  preferredBy: (json['preferred_by'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
  sourceMacAddress: (json['source_mac_address'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
  sourceHostname: (json['source_hostname'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
  invert: json['invert'] as bool?,
  type: json['type'] as String?,
  mode: json['mode'] as String?,
  rules: json['rules'] as List<dynamic>?,
);

Map<String, dynamic> _$RouteRuleToJson(RouteRule instance) => <String, dynamic>{
  'action': instance.action,
  'outbound': ?instance.outbound,
  'method': ?instance.method,
  'no_drop': ?instance.noDrop,
  'protocol': ?instance.protocol,
  'clash_mode': ?instance.clashMode,
  'domain': ?instance.domain,
  'domain_suffix': ?instance.domainSuffix,
  'domain_keyword': ?instance.domainKeyword,
  'domain_regex': ?instance.domainRegex,
  'process_name': ?instance.processName,
  'process_path': ?instance.processPath,
  'process_path_regex': ?instance.processPathRegex,
  'package_name': ?instance.packageName,
  'ip_is_private': ?instance.ipIsPrivate,
  'rule_set': ?instance.ruleSet,
  'ip_cidr': ?instance.ipCidr,
  'source_ip_cidr': ?instance.sourceIpCidr,
  'port': ?instance.port,
  'port_range': ?instance.portRange,
  'source_port': ?instance.sourcePort,
  'source_port_range': ?instance.sourcePortRange,
  'timeout': ?instance.timeout,
  'inbound': ?instance.inbound,
  'ip_version': ?instance.ipVersion,
  'network': ?instance.network,
  'client': ?instance.client,
  'source_ip_is_private': ?instance.sourceIpIsPrivate,
  'package_name_regex': ?instance.packageNameRegex,
  'network_type': ?instance.networkType,
  'network_is_expensive': ?instance.networkIsExpensive,
  'network_is_constrained': ?instance.networkIsConstrained,
  'default_interface_address': ?instance.defaultInterfacAddress,
  'wifi_ssid': ?instance.wifiSsid,
  'wifi_bssid': ?instance.wifiBssid,
  'preferred_by': ?instance.preferredBy,
  'source_mac_address': ?instance.sourceMacAddress,
  'source_hostname': ?instance.sourceHostname,
  'invert': ?instance.invert,
  'type': ?instance.type,
  'mode': ?instance.mode,
  'rules': ?instance.rules,
};

RuleSet _$RuleSetFromJson(Map<String, dynamic> json) => RuleSet(
  tag: json['tag'] as String,
  type: json['type'] as String,
  format: json['format'] as String?,
  url: json['url'] as String?,
  downloadDetour: json['download_detour'] as String?,
  updateInterval: json['update_interval'] as String?,
  path: json['path'] as String?,
);

Map<String, dynamic> _$RuleSetToJson(RuleSet instance) => <String, dynamic>{
  'tag': instance.tag,
  'type': instance.type,
  'format': ?instance.format,
  'url': ?instance.url,
  'download_detour': ?instance.downloadDetour,
  'update_interval': ?instance.updateInterval,
  'path': ?instance.path,
};
