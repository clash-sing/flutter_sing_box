// 本文件由 tool/gen_models.dart 生成，勿手改。
import 'package:json_annotation/json_annotation.dart';

part 'nested_dns_rule.g.dart';

@JsonSerializable(explicitToJson: true, includeIfNull: false)
class NestedDNSRule {
  String? type;
  Object? inbound;
  @JsonKey(name: 'ip_version')
  int? ipVersion;
  @JsonKey(name: 'query_type')
  Object? queryType;
  @JsonKey(name: 'query_client_subnet')
  Object? queryClientSubnet;
  @JsonKey(name: 'query_dnssec')
  bool? queryDnssec;
  Object? network;
  @JsonKey(name: 'auth_user')
  Object? authUser;
  Object? protocol;
  Object? domain;
  @JsonKey(name: 'domain_suffix')
  Object? domainSuffix;
  @JsonKey(name: 'domain_keyword')
  Object? domainKeyword;
  @JsonKey(name: 'domain_regex')
  Object? domainRegex;
  @JsonKey(name: 'source_ip_cidr')
  Object? sourceIpCidr;
  @JsonKey(name: 'source_ip_is_private')
  bool? sourceIpIsPrivate;
  @JsonKey(name: 'source_port')
  Object? sourcePort;
  @JsonKey(name: 'source_port_range')
  Object? sourcePortRange;
  Object? port;
  @JsonKey(name: 'port_range')
  Object? portRange;
  @JsonKey(name: 'process_name')
  Object? processName;
  @JsonKey(name: 'process_path')
  Object? processPath;
  @JsonKey(name: 'process_path_regex')
  Object? processPathRegex;
  @JsonKey(name: 'package_name')
  Object? packageName;
  @JsonKey(name: 'package_name_regex')
  Object? packageNameRegex;
  Object? user;
  @JsonKey(name: 'user_id')
  Object? userId;
  @JsonKey(name: 'clash_mode')
  String? clashMode;
  @JsonKey(name: 'network_type')
  Object? networkType;
  @JsonKey(name: 'network_is_expensive')
  bool? networkIsExpensive;
  @JsonKey(name: 'network_is_constrained')
  bool? networkIsConstrained;
  @JsonKey(name: 'wifi_ssid')
  Object? wifiSsid;
  @JsonKey(name: 'wifi_bssid')
  Object? wifiBssid;
  @JsonKey(name: 'interface_address')
  Object? interfaceAddress;
  @JsonKey(name: 'network_interface_address')
  Object? networkInterfaceAddress;
  @JsonKey(name: 'default_interface_address')
  Object? defaultInterfaceAddress;
  @JsonKey(name: 'source_mac_address')
  Object? sourceMacAddress;
  @JsonKey(name: 'source_hostname')
  Object? sourceHostname;
  @JsonKey(name: 'preferred_by')
  Object? preferredBy;
  @JsonKey(name: 'dns_server_address')
  Object? dnsServerAddress;
  @JsonKey(name: 'dns_search_domain')
  Object? dnsSearchDomain;
  @JsonKey(name: 'rule_set')
  Object? ruleSet;
  @JsonKey(name: 'rule_set_ip_cidr_match_source')
  bool? ruleSetIpCidrMatchSource;
  @JsonKey(name: 'match_response')
  Object? matchResponse;
  @JsonKey(name: 'ip_cidr')
  Object? ipCidr;
  @JsonKey(name: 'ip_is_private')
  bool? ipIsPrivate;
  @JsonKey(name: 'ip_accept_any')
  bool? ipAcceptAny;
  @JsonKey(name: 'response_rcode')
  Object? responseRcode;
  @JsonKey(name: 'response_answer')
  Object? responseAnswer;
  @JsonKey(name: 'response_ns')
  Object? responseNs;
  @JsonKey(name: 'response_extra')
  Object? responseExtra;
  bool? invert;
  String? mode;
  List<NestedDNSRule>? rules;

  NestedDNSRule();

  factory NestedDNSRule.fromJson(Map<String, dynamic> json) =>
      _$NestedDNSRuleFromJson(json);

  Map<String, dynamic> toJson() => _$NestedDNSRuleToJson(this);
}
