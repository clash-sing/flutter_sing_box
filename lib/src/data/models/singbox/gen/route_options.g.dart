// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'route_options.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RouteOptions _$RouteOptionsFromJson(Map<String, dynamic> json) => RouteOptions()
  ..rules = (json['rules'] as List<dynamic>?)
      ?.map((e) => Rule.fromJson(e as Map<String, dynamic>))
      .toList()
  ..ruleSet = (json['rule_set'] as List<dynamic>?)
      ?.map((e) => RuleSet.fromJson(e as Map<String, dynamic>))
      .toList()
  ..final_ = json['final'] as String?
  ..findProcess = json['find_process'] as bool?
  ..findNeighbor = json['find_neighbor'] as bool?
  ..dhcpLeaseFiles = (json['dhcp_lease_files'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList()
  ..autoDetectInterface = json['auto_detect_interface'] as bool?
  ..overrideAndroidVpn = json['override_android_vpn'] as bool?
  ..defaultInterface = json['default_interface'] as String?
  ..defaultMark = json['default_mark']
  ..defaultDomainResolver = json['default_domain_resolver']
  ..defaultNetworkStrategy = json['default_network_strategy'] as String?
  ..defaultNetworkType = json['default_network_type']
  ..defaultFallbackNetworkType = json['default_fallback_network_type']
  ..defaultFallbackDelay = json['default_fallback_delay'] as String?
  ..defaultHttpClient = json['default_http_client'] as String?;

Map<String, dynamic> _$RouteOptionsToJson(RouteOptions instance) =>
    <String, dynamic>{
      'rules': ?instance.rules?.map((e) => e.toJson()).toList(),
      'rule_set': ?instance.ruleSet?.map((e) => e.toJson()).toList(),
      'final': ?instance.final_,
      'find_process': ?instance.findProcess,
      'find_neighbor': ?instance.findNeighbor,
      'dhcp_lease_files': ?instance.dhcpLeaseFiles,
      'auto_detect_interface': ?instance.autoDetectInterface,
      'override_android_vpn': ?instance.overrideAndroidVpn,
      'default_interface': ?instance.defaultInterface,
      'default_mark': ?instance.defaultMark,
      'default_domain_resolver': ?instance.defaultDomainResolver,
      'default_network_strategy': ?instance.defaultNetworkStrategy,
      'default_network_type': ?instance.defaultNetworkType,
      'default_fallback_network_type': ?instance.defaultFallbackNetworkType,
      'default_fallback_delay': ?instance.defaultFallbackDelay,
      'default_http_client': ?instance.defaultHttpClient,
    };
