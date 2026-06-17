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
  independentCache: json['independent_cache'] as bool?,
  dnsFinal: json['final'] as String?,
  strategy: json['strategy'] as String?,
  disableCache: json['disable_cache'] as bool?,
  disableExpire: json['disable_expire'] as bool?,
  cacheCapacity: (json['cache_capacity'] as num?)?.toInt(),
  timeout: json['timeout'] as String?,
  reverseMapping: json['reverse_mapping'] as bool?,
  clientSubnet: json['client_subnet'] as String?,
  optimistic: json['optimistic'],
);

Map<String, dynamic> _$DnsToJson(Dns instance) => <String, dynamic>{
  'servers': instance.servers.map((e) => e.toJson()).toList(),
  'rules': instance.rules.map((e) => e.toJson()).toList(),
  'independent_cache': ?instance.independentCache,
  'final': ?instance.dnsFinal,
  'strategy': ?instance.strategy,
  'disable_cache': ?instance.disableCache,
  'disable_expire': ?instance.disableExpire,
  'cache_capacity': ?instance.cacheCapacity,
  'timeout': ?instance.timeout,
  'reverse_mapping': ?instance.reverseMapping,
  'client_subnet': ?instance.clientSubnet,
  'optimistic': ?instance.optimistic,
};

Server _$ServerFromJson(Map<String, dynamic> json) => Server(
  tag: json['tag'] as String,
  type: json['type'] as String,
  server: json['server'] as String?,
  inet4Range: json['inet4_range'] as String?,
  inet6Range: json['inet6_range'] as String?,
  preferGo: json['prefer_go'] as bool?,
  neighborDomain: (json['neighbor_domain'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
  path: (json['path'] as List<dynamic>?)?.map((e) => e as String).toList(),
  serverPort: (json['server_port'] as num?)?.toInt(),
  service: json['service'] as String?,
  acceptDefaultResolvers: json['accept_default_resolvers'] as bool?,
);

Map<String, dynamic> _$ServerToJson(Server instance) => <String, dynamic>{
  'tag': instance.tag,
  'type': instance.type,
  'server': ?instance.server,
  'inet4_range': ?instance.inet4Range,
  'inet6_range': ?instance.inet6Range,
  'prefer_go': ?instance.preferGo,
  'neighbor_domain': ?instance.neighborDomain,
  'path': ?instance.path,
  'server_port': ?instance.serverPort,
  'service': ?instance.service,
  'accept_default_resolvers': ?instance.acceptDefaultResolvers,
};

DnsRule _$DnsRuleFromJson(Map<String, dynamic> json) => DnsRule(
  action: json['action'] as String? ?? RuleAction.route,
  server: json['server'] as String?,
  strategy: json['strategy'] as String?,
  disableCache: json['disable_cache'] as bool?,
  disableOptimisticCache: json['disable_optimistic_cache'] as bool?,
  timeout: json['timeout'] as String?,
  clientSubnet: json['client_subnet'] as String?,
  clashMode: json['clash_mode'] as String?,
  ruleSet: (json['rule_set'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
  queryType: (json['query_type'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
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
  inbound: (json['inbound'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
  ipVersion: (json['ip_version'] as num?)?.toInt(),
  network: json['network'] as String?,
  protocol: (json['protocol'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
  sourceIpCidr: (json['source_ip_cidr'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
  sourceIpIsPrivate: json['source_ip_is_private'] as bool?,
  sourcePort: (json['source_port'] as List<dynamic>?)
      ?.map((e) => (e as num).toInt())
      .toList(),
  sourcePortRange: (json['source_port_range'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
  port: (json['port'] as List<dynamic>?)
      ?.map((e) => (e as num).toInt())
      .toList(),
  portRange: (json['port_range'] as List<dynamic>?)
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
  sourceMacAddress: (json['source_mac_address'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
  sourceHostname: (json['source_hostname'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
  preferredBy: (json['preferred_by'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
  wifiSsid: (json['wifi_ssid'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
  wifiBssid: (json['wifi_bssid'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
  ruleSetIpCidrMatchSource: json['rule_set_ip_cidr_match_source'] as bool?,
  matchResponse: json['match_response'] as bool?,
  ipCidr: (json['ip_cidr'] as List<dynamic>?)?.map((e) => e as String).toList(),
  ipIsPrivate: json['ip_is_private'] as bool?,
  ipAcceptAny: json['ip_accept_any'] as bool?,
  responseRcode: json['response_rcode'] as String?,
  invert: json['invert'] as bool?,
  outbound: (json['outbound'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
  type: json['type'] as String?,
  mode: json['mode'] as String?,
  rules: json['rules'] as List<dynamic>?,
);

Map<String, dynamic> _$DnsRuleToJson(DnsRule instance) => <String, dynamic>{
  'action': instance.action,
  'server': ?instance.server,
  'strategy': ?instance.strategy,
  'disable_cache': ?instance.disableCache,
  'disable_optimistic_cache': ?instance.disableOptimisticCache,
  'timeout': ?instance.timeout,
  'client_subnet': ?instance.clientSubnet,
  'clash_mode': ?instance.clashMode,
  'rule_set': ?instance.ruleSet,
  'query_type': ?instance.queryType,
  'domain': ?instance.domain,
  'domain_suffix': ?instance.domainSuffix,
  'domain_keyword': ?instance.domainKeyword,
  'domain_regex': ?instance.domainRegex,
  'inbound': ?instance.inbound,
  'ip_version': ?instance.ipVersion,
  'network': ?instance.network,
  'protocol': ?instance.protocol,
  'source_ip_cidr': ?instance.sourceIpCidr,
  'source_ip_is_private': ?instance.sourceIpIsPrivate,
  'source_port': ?instance.sourcePort,
  'source_port_range': ?instance.sourcePortRange,
  'port': ?instance.port,
  'port_range': ?instance.portRange,
  'process_name': ?instance.processName,
  'process_path': ?instance.processPath,
  'process_path_regex': ?instance.processPathRegex,
  'package_name': ?instance.packageName,
  'package_name_regex': ?instance.packageNameRegex,
  'network_type': ?instance.networkType,
  'network_is_expensive': ?instance.networkIsExpensive,
  'network_is_constrained': ?instance.networkIsConstrained,
  'default_interface_address': ?instance.defaultInterfacAddress,
  'source_mac_address': ?instance.sourceMacAddress,
  'source_hostname': ?instance.sourceHostname,
  'preferred_by': ?instance.preferredBy,
  'wifi_ssid': ?instance.wifiSsid,
  'wifi_bssid': ?instance.wifiBssid,
  'rule_set_ip_cidr_match_source': ?instance.ruleSetIpCidrMatchSource,
  'match_response': ?instance.matchResponse,
  'ip_cidr': ?instance.ipCidr,
  'ip_is_private': ?instance.ipIsPrivate,
  'ip_accept_any': ?instance.ipAcceptAny,
  'response_rcode': ?instance.responseRcode,
  'invert': ?instance.invert,
  'outbound': ?instance.outbound,
  'type': ?instance.type,
  'mode': ?instance.mode,
  'rules': ?instance.rules,
};
