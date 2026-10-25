// 本文件由 tool/gen_models.dart 生成，勿手改。
import 'package:json_annotation/json_annotation.dart';

import 'nested_rule.dart';

part 'rule.g.dart';

/// 由官方 JSON schema `$defs/Rule` 定义的配置模型。
@JsonSerializable(explicitToJson: true, includeIfNull: false)
class Rule {
  /// 对应 JSON 键 `type`，可空（null 不参与序列化）。
  String? type;
  /// 对应 JSON 键 `inbound`，可空（null 不参与序列化）。
  Object? inbound;
  /// 对应 JSON 键 `ip_version`，可空（null 不参与序列化）。
  @JsonKey(name: 'ip_version')
  int? ipVersion;
  /// 对应 JSON 键 `network`，可空（null 不参与序列化）。
  Object? network;
  /// 对应 JSON 键 `auth_user`，可空（null 不参与序列化）。
  @JsonKey(name: 'auth_user')
  Object? authUser;
  /// 对应 JSON 键 `protocol`，可空（null 不参与序列化）。
  Object? protocol;
  /// 对应 JSON 键 `client`，可空（null 不参与序列化）。
  Object? client;
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
  /// 对应 JSON 键 `ip_cidr`，可空（null 不参与序列化）。
  @JsonKey(name: 'ip_cidr')
  Object? ipCidr;
  /// 对应 JSON 键 `ip_is_private`，可空（null 不参与序列化）。
  @JsonKey(name: 'ip_is_private')
  bool? ipIsPrivate;
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
  /// 对应 JSON 键 `invert`，可空（null 不参与序列化）。
  bool? invert;
  /// 对应 JSON 键 `action`，可空（null 不参与序列化）。
  String? action;
  /// 对应 JSON 键 `outbound`，可空（null 不参与序列化）。
  String? outbound;
  /// 对应 JSON 键 `override_address`，可空（null 不参与序列化）。
  @JsonKey(name: 'override_address')
  String? overrideAddress;
  /// 对应 JSON 键 `override_port`，可空（null 不参与序列化）。
  @JsonKey(name: 'override_port')
  int? overridePort;
  /// 对应 JSON 键 `network_strategy`，可空（null 不参与序列化）。
  @JsonKey(name: 'network_strategy')
  String? networkStrategy;
  /// 对应 JSON 键 `fallback_delay`，可空（null 不参与序列化）。
  @JsonKey(name: 'fallback_delay')
  int? fallbackDelay;
  /// 对应 JSON 键 `udp_disable_domain_unmapping`，可空（null 不参与序列化）。
  @JsonKey(name: 'udp_disable_domain_unmapping')
  bool? udpDisableDomainUnmapping;
  /// 对应 JSON 键 `udp_connect`，可空（null 不参与序列化）。
  @JsonKey(name: 'udp_connect')
  bool? udpConnect;
  /// 对应 JSON 键 `udp_timeout`，可空（null 不参与序列化）。
  @JsonKey(name: 'udp_timeout')
  String? udpTimeout;
  /// 对应 JSON 键 `tls_fragment`，可空（null 不参与序列化）。
  @JsonKey(name: 'tls_fragment')
  bool? tlsFragment;
  /// 对应 JSON 键 `tls_fragment_fallback_delay`，可空（null 不参与序列化）。
  @JsonKey(name: 'tls_fragment_fallback_delay')
  String? tlsFragmentFallbackDelay;
  /// 对应 JSON 键 `tls_record_fragment`，可空（null 不参与序列化）。
  @JsonKey(name: 'tls_record_fragment')
  bool? tlsRecordFragment;
  /// 对应 JSON 键 `tls_spoof`，可空（null 不参与序列化）。
  @JsonKey(name: 'tls_spoof')
  String? tlsSpoof;
  /// 对应 JSON 键 `tls_spoof_method`，可空（null 不参与序列化）。
  @JsonKey(name: 'tls_spoof_method')
  String? tlsSpoofMethod;
  /// 对应 JSON 键 `bind_interface`，可空（null 不参与序列化）。
  @JsonKey(name: 'bind_interface')
  String? bindInterface;
  /// 对应 JSON 键 `inet4_bind_address`，可空（null 不参与序列化）。
  @JsonKey(name: 'inet4_bind_address')
  Object? inet4BindAddress;
  /// 对应 JSON 键 `inet6_bind_address`，可空（null 不参与序列化）。
  @JsonKey(name: 'inet6_bind_address')
  Object? inet6BindAddress;
  /// 对应 JSON 键 `bind_address_no_port`，可空（null 不参与序列化）。
  @JsonKey(name: 'bind_address_no_port')
  bool? bindAddressNoPort;
  /// 对应 JSON 键 `protect_path`，可空（null 不参与序列化）。
  @JsonKey(name: 'protect_path')
  String? protectPath;
  /// 对应 JSON 键 `routing_mark`，可空（null 不参与序列化）。
  @JsonKey(name: 'routing_mark')
  Object? routingMark;
  /// 对应 JSON 键 `reuse_addr`，可空（null 不参与序列化）。
  @JsonKey(name: 'reuse_addr')
  bool? reuseAddr;
  /// 对应 JSON 键 `netns`，可空（null 不参与序列化）。
  String? netns;
  /// 对应 JSON 键 `connect_timeout`，可空（null 不参与序列化）。
  @JsonKey(name: 'connect_timeout')
  String? connectTimeout;
  /// 对应 JSON 键 `tcp_fast_open`，可空（null 不参与序列化）。
  @JsonKey(name: 'tcp_fast_open')
  bool? tcpFastOpen;
  /// 对应 JSON 键 `tcp_multi_path`，可空（null 不参与序列化）。
  @JsonKey(name: 'tcp_multi_path')
  bool? tcpMultiPath;
  /// 对应 JSON 键 `disable_tcp_keep_alive`，可空（null 不参与序列化）。
  @JsonKey(name: 'disable_tcp_keep_alive')
  bool? disableTcpKeepAlive;
  /// 对应 JSON 键 `tcp_keep_alive`，可空（null 不参与序列化）。
  @JsonKey(name: 'tcp_keep_alive')
  String? tcpKeepAlive;
  /// 对应 JSON 键 `tcp_keep_alive_interval`，可空（null 不参与序列化）。
  @JsonKey(name: 'tcp_keep_alive_interval')
  String? tcpKeepAliveInterval;
  /// 对应 JSON 键 `udp_fragment`，可空（null 不参与序列化）。
  @JsonKey(name: 'udp_fragment')
  bool? udpFragment;
  /// 对应 JSON 键 `domain_resolver`，可空（null 不参与序列化）。
  @JsonKey(name: 'domain_resolver')
  Object? domainResolver;
  /// 对应 JSON 键 `fallback_network_type`，可空（null 不参与序列化）。
  @JsonKey(name: 'fallback_network_type')
  Object? fallbackNetworkType;
  /// 对应 JSON 键 `method`，可空（null 不参与序列化）。
  String? method;
  /// 对应 JSON 键 `no_drop`，可空（null 不参与序列化）。
  @JsonKey(name: 'no_drop')
  bool? noDrop;
  /// 对应 JSON 键 `sniffer`，可空（null 不参与序列化）。
  Object? sniffer;
  /// 对应 JSON 键 `timeout`，可空（null 不参与序列化）。
  String? timeout;
  /// 对应 JSON 键 `server`，可空（null 不参与序列化）。
  String? server;
  /// 对应 JSON 键 `strategy`，可空（null 不参与序列化）。
  Object? strategy;
  /// 对应 JSON 键 `disable_cache`，可空（null 不参与序列化）。
  @JsonKey(name: 'disable_cache')
  bool? disableCache;
  /// 对应 JSON 键 `disable_optimistic_cache`，可空（null 不参与序列化）。
  @JsonKey(name: 'disable_optimistic_cache')
  bool? disableOptimisticCache;
  /// 对应 JSON 键 `rewrite_ttl`，可空（null 不参与序列化）。
  @JsonKey(name: 'rewrite_ttl')
  int? rewriteTtl;
  /// 对应 JSON 键 `client_subnet`，可空（null 不参与序列化）。
  @JsonKey(name: 'client_subnet')
  Object? clientSubnet;
  /// 对应 JSON 键 `mode`，可空（null 不参与序列化）。
  String? mode;
  /// 对应 JSON 键 `rules`，可空（null 不参与序列化）。
  List<NestedRule>? rules;

  /// 构造实例；可空字段省略时为 `null`。
  Rule();

  /// 从 JSON 对象反序列化为本类型。
  factory Rule.fromJson(Map<String, dynamic> json) =>
      _$RuleFromJson(json);

  /// 序列化为 JSON 对象。
  Map<String, dynamic> toJson() => _$RuleToJson(this);
}
