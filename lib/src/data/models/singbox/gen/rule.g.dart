// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'rule.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Rule _$RuleFromJson(Map<String, dynamic> json) => Rule()
  ..type = json['type'] as String?
  ..inbound = json['inbound']
  ..ipVersion = (json['ip_version'] as num?)?.toInt()
  ..network = json['network']
  ..authUser = json['auth_user']
  ..protocol = json['protocol']
  ..client = json['client']
  ..domain = json['domain']
  ..domainSuffix = json['domain_suffix']
  ..domainKeyword = json['domain_keyword']
  ..domainRegex = json['domain_regex']
  ..sourceIpCidr = json['source_ip_cidr']
  ..sourceIpIsPrivate = json['source_ip_is_private'] as bool?
  ..ipCidr = json['ip_cidr']
  ..ipIsPrivate = json['ip_is_private'] as bool?
  ..sourcePort = json['source_port']
  ..sourcePortRange = json['source_port_range']
  ..port = json['port']
  ..portRange = json['port_range']
  ..processName = json['process_name']
  ..processPath = json['process_path']
  ..processPathRegex = json['process_path_regex']
  ..packageName = json['package_name']
  ..packageNameRegex = json['package_name_regex']
  ..user = json['user']
  ..userId = json['user_id']
  ..clashMode = json['clash_mode'] as String?
  ..networkType = json['network_type']
  ..networkIsExpensive = json['network_is_expensive'] as bool?
  ..networkIsConstrained = json['network_is_constrained'] as bool?
  ..wifiSsid = json['wifi_ssid']
  ..wifiBssid = json['wifi_bssid']
  ..interfaceAddress = json['interface_address']
  ..networkInterfaceAddress = json['network_interface_address']
  ..defaultInterfaceAddress = json['default_interface_address']
  ..sourceMacAddress = json['source_mac_address']
  ..sourceHostname = json['source_hostname']
  ..preferredBy = json['preferred_by']
  ..dnsServerAddress = json['dns_server_address']
  ..dnsSearchDomain = json['dns_search_domain']
  ..ruleSet = json['rule_set']
  ..ruleSetIpCidrMatchSource = json['rule_set_ip_cidr_match_source'] as bool?
  ..invert = json['invert'] as bool?
  ..action = json['action'] as String?
  ..outbound = json['outbound'] as String?
  ..overrideAddress = json['override_address'] as String?
  ..overridePort = (json['override_port'] as num?)?.toInt()
  ..networkStrategy = json['network_strategy'] as String?
  ..fallbackDelay = (json['fallback_delay'] as num?)?.toInt()
  ..udpDisableDomainUnmapping = json['udp_disable_domain_unmapping'] as bool?
  ..udpConnect = json['udp_connect'] as bool?
  ..udpTimeout = json['udp_timeout'] as String?
  ..tlsFragment = json['tls_fragment'] as bool?
  ..tlsFragmentFallbackDelay = json['tls_fragment_fallback_delay'] as String?
  ..tlsRecordFragment = json['tls_record_fragment'] as bool?
  ..tlsSpoof = json['tls_spoof'] as String?
  ..tlsSpoofMethod = json['tls_spoof_method'] as String?
  ..method = json['method'] as String?
  ..noDrop = json['no_drop'] as bool?
  ..sniffer = json['sniffer']
  ..timeout = json['timeout'] as String?
  ..server = json['server'] as String?
  ..strategy = json['strategy']
  ..disableCache = json['disable_cache'] as bool?
  ..disableOptimisticCache = json['disable_optimistic_cache'] as bool?
  ..rewriteTtl = (json['rewrite_ttl'] as num?)?.toInt()
  ..clientSubnet = json['client_subnet']
  ..mode = json['mode'] as String?
  ..rules = (json['rules'] as List<dynamic>?)
      ?.map((e) => NestedRule.fromJson(e as Map<String, dynamic>))
      .toList();

Map<String, dynamic> _$RuleToJson(Rule instance) => <String, dynamic>{
  'type': ?instance.type,
  'inbound': ?instance.inbound,
  'ip_version': ?instance.ipVersion,
  'network': ?instance.network,
  'auth_user': ?instance.authUser,
  'protocol': ?instance.protocol,
  'client': ?instance.client,
  'domain': ?instance.domain,
  'domain_suffix': ?instance.domainSuffix,
  'domain_keyword': ?instance.domainKeyword,
  'domain_regex': ?instance.domainRegex,
  'source_ip_cidr': ?instance.sourceIpCidr,
  'source_ip_is_private': ?instance.sourceIpIsPrivate,
  'ip_cidr': ?instance.ipCidr,
  'ip_is_private': ?instance.ipIsPrivate,
  'source_port': ?instance.sourcePort,
  'source_port_range': ?instance.sourcePortRange,
  'port': ?instance.port,
  'port_range': ?instance.portRange,
  'process_name': ?instance.processName,
  'process_path': ?instance.processPath,
  'process_path_regex': ?instance.processPathRegex,
  'package_name': ?instance.packageName,
  'package_name_regex': ?instance.packageNameRegex,
  'user': ?instance.user,
  'user_id': ?instance.userId,
  'clash_mode': ?instance.clashMode,
  'network_type': ?instance.networkType,
  'network_is_expensive': ?instance.networkIsExpensive,
  'network_is_constrained': ?instance.networkIsConstrained,
  'wifi_ssid': ?instance.wifiSsid,
  'wifi_bssid': ?instance.wifiBssid,
  'interface_address': ?instance.interfaceAddress,
  'network_interface_address': ?instance.networkInterfaceAddress,
  'default_interface_address': ?instance.defaultInterfaceAddress,
  'source_mac_address': ?instance.sourceMacAddress,
  'source_hostname': ?instance.sourceHostname,
  'preferred_by': ?instance.preferredBy,
  'dns_server_address': ?instance.dnsServerAddress,
  'dns_search_domain': ?instance.dnsSearchDomain,
  'rule_set': ?instance.ruleSet,
  'rule_set_ip_cidr_match_source': ?instance.ruleSetIpCidrMatchSource,
  'invert': ?instance.invert,
  'action': ?instance.action,
  'outbound': ?instance.outbound,
  'override_address': ?instance.overrideAddress,
  'override_port': ?instance.overridePort,
  'network_strategy': ?instance.networkStrategy,
  'fallback_delay': ?instance.fallbackDelay,
  'udp_disable_domain_unmapping': ?instance.udpDisableDomainUnmapping,
  'udp_connect': ?instance.udpConnect,
  'udp_timeout': ?instance.udpTimeout,
  'tls_fragment': ?instance.tlsFragment,
  'tls_fragment_fallback_delay': ?instance.tlsFragmentFallbackDelay,
  'tls_record_fragment': ?instance.tlsRecordFragment,
  'tls_spoof': ?instance.tlsSpoof,
  'tls_spoof_method': ?instance.tlsSpoofMethod,
  'method': ?instance.method,
  'no_drop': ?instance.noDrop,
  'sniffer': ?instance.sniffer,
  'timeout': ?instance.timeout,
  'server': ?instance.server,
  'strategy': ?instance.strategy,
  'disable_cache': ?instance.disableCache,
  'disable_optimistic_cache': ?instance.disableOptimisticCache,
  'rewrite_ttl': ?instance.rewriteTtl,
  'client_subnet': ?instance.clientSubnet,
  'mode': ?instance.mode,
  'rules': ?instance.rules?.map((e) => e.toJson()).toList(),
};
