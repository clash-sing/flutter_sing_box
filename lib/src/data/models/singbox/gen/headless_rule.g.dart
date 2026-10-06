// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'headless_rule.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

HeadlessRule _$HeadlessRuleFromJson(Map<String, dynamic> json) => HeadlessRule()
  ..type = json['type'] as String?
  ..queryType = json['query_type']
  ..network = json['network']
  ..domain = json['domain']
  ..domainSuffix = json['domain_suffix']
  ..domainKeyword = json['domain_keyword']
  ..domainRegex = json['domain_regex']
  ..sourceIpCidr = json['source_ip_cidr']
  ..ipCidr = json['ip_cidr']
  ..sourcePort = json['source_port']
  ..sourcePortRange = json['source_port_range']
  ..port = json['port']
  ..portRange = json['port_range']
  ..processName = json['process_name']
  ..processPath = json['process_path']
  ..processPathRegex = json['process_path_regex']
  ..packageName = json['package_name']
  ..packageNameRegex = json['package_name_regex']
  ..networkType = json['network_type']
  ..networkIsExpensive = json['network_is_expensive'] as bool?
  ..networkIsConstrained = json['network_is_constrained'] as bool?
  ..wifiSsid = json['wifi_ssid']
  ..wifiBssid = json['wifi_bssid']
  ..networkInterfaceAddress = json['network_interface_address']
  ..defaultInterfaceAddress = json['default_interface_address']
  ..invert = json['invert'] as bool?
  ..mode = json['mode'] as String?
  ..rules = (json['rules'] as List<dynamic>?)
      ?.map((e) => HeadlessRule.fromJson(e as Map<String, dynamic>))
      .toList();

Map<String, dynamic> _$HeadlessRuleToJson(HeadlessRule instance) =>
    <String, dynamic>{
      'type': ?instance.type,
      'query_type': ?instance.queryType,
      'network': ?instance.network,
      'domain': ?instance.domain,
      'domain_suffix': ?instance.domainSuffix,
      'domain_keyword': ?instance.domainKeyword,
      'domain_regex': ?instance.domainRegex,
      'source_ip_cidr': ?instance.sourceIpCidr,
      'ip_cidr': ?instance.ipCidr,
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
      'wifi_ssid': ?instance.wifiSsid,
      'wifi_bssid': ?instance.wifiBssid,
      'network_interface_address': ?instance.networkInterfaceAddress,
      'default_interface_address': ?instance.defaultInterfaceAddress,
      'invert': ?instance.invert,
      'mode': ?instance.mode,
      'rules': ?instance.rules?.map((e) => e.toJson()).toList(),
    };
