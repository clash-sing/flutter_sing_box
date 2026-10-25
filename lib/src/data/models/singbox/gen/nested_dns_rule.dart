// 本文件由 tool/gen_models.dart 生成，勿手改。
import 'package:json_annotation/json_annotation.dart';

part 'nested_dns_rule.g.dart';

/// 由官方 JSON schema `$defs/NestedDNSRule` 定义的配置模型。
@JsonSerializable(explicitToJson: true, includeIfNull: false)
class NestedDNSRule {
  /// 对应 JSON 键 `type`，可空（null 不参与序列化）。
  String? type;
  /// 对应 JSON 键 `inbound`，可空（null 不参与序列化）。
  Object? inbound;
  /// 对应 JSON 键 `ip_version`，可空（null 不参与序列化）。
  @JsonKey(name: 'ip_version')
  int? ipVersion;
  /// 对应 JSON 键 `query_type`，可空（null 不参与序列化）。
  @JsonKey(name: 'query_type')
  Object? queryType;
  /// 对应 JSON 键 `query_client_subnet`，可空（null 不参与序列化）。
  @JsonKey(name: 'query_client_subnet')
  Object? queryClientSubnet;
  /// 对应 JSON 键 `query_dnssec`，可空（null 不参与序列化）。
  @JsonKey(name: 'query_dnssec')
  bool? queryDnssec;
  /// 对应 JSON 键 `network`，可空（null 不参与序列化）。
  Object? network;
  /// 对应 JSON 键 `auth_user`，可空（null 不参与序列化）。
  @JsonKey(name: 'auth_user')
  Object? authUser;
  /// 对应 JSON 键 `protocol`，可空（null 不参与序列化）。
  Object? protocol;
  /// 对应 JSON 键 `domain`，可空（null 不参与序列化）。
  Object? domain;
  /// 对应 JSON 键 `domain_suffix`，可空（null 不参与序列化）。
  @JsonKey(name: 'domain_suffix')
  Object? domainSuffix;
  /// 对应 JSON 键 `domain_keyword`，可空（null 不参与序列化）。
  @JsonKey(name: 'domain_keyword')
  Object? domainKeyword;
  /// 对应 JSON 键 `domain_regex`，可空（null 不参与序列化）。
  @JsonKey(name: 'domain_regex')
  Object? domainRegex;
  /// 对应 JSON 键 `source_ip_cidr`，可空（null 不参与序列化）。
  @JsonKey(name: 'source_ip_cidr')
  Object? sourceIpCidr;
  /// 对应 JSON 键 `source_ip_is_private`，可空（null 不参与序列化）。
  @JsonKey(name: 'source_ip_is_private')
  bool? sourceIpIsPrivate;
  /// 对应 JSON 键 `source_port`，可空（null 不参与序列化）。
  @JsonKey(name: 'source_port')
  Object? sourcePort;
  /// 对应 JSON 键 `source_port_range`，可空（null 不参与序列化）。
  @JsonKey(name: 'source_port_range')
  Object? sourcePortRange;
  /// 对应 JSON 键 `port`，可空（null 不参与序列化）。
  Object? port;
  /// 对应 JSON 键 `port_range`，可空（null 不参与序列化）。
  @JsonKey(name: 'port_range')
  Object? portRange;
  /// 对应 JSON 键 `process_name`，可空（null 不参与序列化）。
  @JsonKey(name: 'process_name')
  Object? processName;
  /// 对应 JSON 键 `process_path`，可空（null 不参与序列化）。
  @JsonKey(name: 'process_path')
  Object? processPath;
  /// 对应 JSON 键 `process_path_regex`，可空（null 不参与序列化）。
  @JsonKey(name: 'process_path_regex')
  Object? processPathRegex;
  /// 对应 JSON 键 `package_name`，可空（null 不参与序列化）。
  @JsonKey(name: 'package_name')
  Object? packageName;
  /// 对应 JSON 键 `package_name_regex`，可空（null 不参与序列化）。
  @JsonKey(name: 'package_name_regex')
  Object? packageNameRegex;
  /// 对应 JSON 键 `user`，可空（null 不参与序列化）。
  Object? user;
  /// 对应 JSON 键 `user_id`，可空（null 不参与序列化）。
  @JsonKey(name: 'user_id')
  Object? userId;
  /// 对应 JSON 键 `clash_mode`，可空（null 不参与序列化）。
  @JsonKey(name: 'clash_mode')
  String? clashMode;
  /// 对应 JSON 键 `network_type`，可空（null 不参与序列化）。
  @JsonKey(name: 'network_type')
  Object? networkType;
  /// 对应 JSON 键 `network_is_expensive`，可空（null 不参与序列化）。
  @JsonKey(name: 'network_is_expensive')
  bool? networkIsExpensive;
  /// 对应 JSON 键 `network_is_constrained`，可空（null 不参与序列化）。
  @JsonKey(name: 'network_is_constrained')
  bool? networkIsConstrained;
  /// 对应 JSON 键 `wifi_ssid`，可空（null 不参与序列化）。
  @JsonKey(name: 'wifi_ssid')
  Object? wifiSsid;
  /// 对应 JSON 键 `wifi_bssid`，可空（null 不参与序列化）。
  @JsonKey(name: 'wifi_bssid')
  Object? wifiBssid;
  /// 对应 JSON 键 `interface_address`，可空（null 不参与序列化）。
  @JsonKey(name: 'interface_address')
  Object? interfaceAddress;
  /// 对应 JSON 键 `network_interface_address`，可空（null 不参与序列化）。
  @JsonKey(name: 'network_interface_address')
  Object? networkInterfaceAddress;
  /// 对应 JSON 键 `default_interface_address`，可空（null 不参与序列化）。
  @JsonKey(name: 'default_interface_address')
  Object? defaultInterfaceAddress;
  /// 对应 JSON 键 `source_mac_address`，可空（null 不参与序列化）。
  @JsonKey(name: 'source_mac_address')
  Object? sourceMacAddress;
  /// 对应 JSON 键 `source_hostname`，可空（null 不参与序列化）。
  @JsonKey(name: 'source_hostname')
  Object? sourceHostname;
  /// 对应 JSON 键 `preferred_by`，可空（null 不参与序列化）。
  @JsonKey(name: 'preferred_by')
  Object? preferredBy;
  /// 对应 JSON 键 `dns_server_address`，可空（null 不参与序列化）。
  @JsonKey(name: 'dns_server_address')
  Object? dnsServerAddress;
  /// 对应 JSON 键 `dns_search_domain`，可空（null 不参与序列化）。
  @JsonKey(name: 'dns_search_domain')
  Object? dnsSearchDomain;
  /// 对应 JSON 键 `rule_set`，可空（null 不参与序列化）。
  @JsonKey(name: 'rule_set')
  Object? ruleSet;
  /// 对应 JSON 键 `rule_set_ip_cidr_match_source`，可空（null 不参与序列化）。
  @JsonKey(name: 'rule_set_ip_cidr_match_source')
  bool? ruleSetIpCidrMatchSource;
  /// 对应 JSON 键 `match_response`，可空（null 不参与序列化）。
  @JsonKey(name: 'match_response')
  Object? matchResponse;
  /// 对应 JSON 键 `ip_cidr`，可空（null 不参与序列化）。
  @JsonKey(name: 'ip_cidr')
  Object? ipCidr;
  /// 对应 JSON 键 `ip_is_private`，可空（null 不参与序列化）。
  @JsonKey(name: 'ip_is_private')
  bool? ipIsPrivate;
  /// 对应 JSON 键 `ip_accept_any`，可空（null 不参与序列化）。
  @JsonKey(name: 'ip_accept_any')
  bool? ipAcceptAny;
  /// 对应 JSON 键 `response_rcode`，可空（null 不参与序列化）。
  @JsonKey(name: 'response_rcode')
  Object? responseRcode;
  /// 对应 JSON 键 `response_answer`，可空（null 不参与序列化）。
  @JsonKey(name: 'response_answer')
  Object? responseAnswer;
  /// 对应 JSON 键 `response_ns`，可空（null 不参与序列化）。
  @JsonKey(name: 'response_ns')
  Object? responseNs;
  /// 对应 JSON 键 `response_extra`，可空（null 不参与序列化）。
  @JsonKey(name: 'response_extra')
  Object? responseExtra;
  /// 对应 JSON 键 `invert`，可空（null 不参与序列化）。
  bool? invert;
  /// 对应 JSON 键 `mode`，可空（null 不参与序列化）。
  String? mode;
  /// 对应 JSON 键 `rules`，可空（null 不参与序列化）。
  List<NestedDNSRule>? rules;

  /// 构造实例；可空字段省略时为 `null`。
  NestedDNSRule();

  /// 从 JSON 对象反序列化为本类型。
  factory NestedDNSRule.fromJson(Map<String, dynamic> json) =>
      _$NestedDNSRuleFromJson(json);

  /// 序列化为 JSON 对象。
  Map<String, dynamic> toJson() => _$NestedDNSRuleToJson(this);
}
