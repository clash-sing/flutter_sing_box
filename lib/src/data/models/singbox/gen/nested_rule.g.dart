// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'nested_rule.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NestedRule _$NestedRuleFromJson(Map<String, dynamic> json) => NestedRule()
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
  ..mode = json['mode'] as String?
  ..rules = (json['rules'] as List<dynamic>?)
      ?.map((e) => NestedRule.fromJson(e as Map<String, dynamic>))
      .toList();

Map<String, dynamic> _$NestedRuleToJson(NestedRule instance) =>
    <String, dynamic>{
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
      'mode': ?instance.mode,
      'rules': ?instance.rules?.map((e) => e.toJson()).toList(),
    };
