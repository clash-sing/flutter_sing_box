import 'package:json_annotation/json_annotation.dart';
import '../../../constants/rule_action.dart';

part 'dns.g.dart';

@JsonSerializable(explicitToJson: true)
class Dns {
  List<Server> servers;
  List<DnsRule> rules;
  @Deprecated('在 sing-box 1.14.0 废弃，且将在 sing-box 1.16.0 中被移除。')
  @JsonKey(name: "independent_cache")
  bool? independentCache;
  @JsonKey(name: "final")
  String? dnsFinal;
  String? strategy;
  @JsonKey(name: "disable_cache")
  bool? disableCache;
  @JsonKey(name: "disable_expire")
  bool? disableExpire;
  @JsonKey(name: "cache_capacity")
  int? cacheCapacity;
  String? timeout;
  @JsonKey(name: "reverse_mapping")
  bool? reverseMapping;
  @JsonKey(name: "client_subnet")
  String? clientSubnet;
  dynamic optimistic;

  Dns({
    required this.servers,
    required this.rules,
    this.independentCache,
    this.dnsFinal,
    this.strategy,
    this.disableCache,
    this.disableExpire,
    this.cacheCapacity,
    this.timeout,
    this.reverseMapping,
    this.clientSubnet,
    this.optimistic,
  });

  factory Dns.fromJson(Map<String, dynamic> json) => _$DnsFromJson(json);

  Map<String, dynamic> toJson() => _$DnsToJson(this);
}

@JsonSerializable(explicitToJson: true)
class Server {
  String tag;
  String type;
  String? server;
  @JsonKey(name: "inet4_range")
  String? inet4Range;
  @JsonKey(name: "inet6_range")
  String? inet6Range;
  @JsonKey(name: "prefer_go")
  bool? preferGo;
  @JsonKey(name: "neighbor_domain")
  List<String>? neighborDomain;
  List<String>? path;
  @JsonKey(name: "server_port")
  int? serverPort;
  String? service;
  @JsonKey(name: "accept_default_resolvers")
  bool? acceptDefaultResolvers;

  Server({
    required this.tag,
    required this.type,
    this.server,
    this.inet4Range,
    this.inet6Range,
    this.preferGo,
    this.neighborDomain,
    this.path,
    this.serverPort,
    this.service,
    this.acceptDefaultResolvers,
  });

  factory Server.fromJson(Map<String, dynamic> json) => _$ServerFromJson(json);

  Map<String, dynamic> toJson() => _$ServerToJson(this);
}

@JsonSerializable(explicitToJson: true)
class DnsRule {
  String action;
  String? server;
  @Deprecated('已在 sing-box 1.14.0 废弃，且将在 sing-box 1.16.0 中被移除。')
  String? strategy;
  @JsonKey(name: "disable_cache")
  bool? disableCache;
  @JsonKey(name: "disable_optimistic_cache")
  bool? disableOptimisticCache;
  String? timeout;
  @JsonKey(name: "client_subnet")
  String? clientSubnet;
  @JsonKey(name: "clash_mode")
  String? clashMode;
  @JsonKey(name: "rule_set")
  List<String>? ruleSet;
  @JsonKey(name: "query_type")
  List<String>? queryType;
  List<String>? domain;
  @JsonKey(name: "domain_suffix")
  List<String>? domainSuffix;
  @JsonKey(name: "domain_keyword")
  List<String>? domainKeyword;
  @JsonKey(name: "domain_regex")
  List<String>? domainRegex;
  List<String>? inbound;

  /// 4 (A DNS 查询) 或 6 (AAAA DNS 查询)
  @JsonKey(name: "ip_version")
  int? ipVersion;

  /// tcp 或 udp
  String? network;
  List<String>? protocol;
  @JsonKey(name: "source_ip_cidr")
  List<String>? sourceIpCidr;
  @JsonKey(name: "source_ip_is_private")
  bool? sourceIpIsPrivate;
  @JsonKey(name: "source_port")
  List<int>? sourcePort;
  @JsonKey(name: "source_port_range")
  List<String>? sourcePortRange;
  List<int>? port;
  @JsonKey(name: "port_range")
  List<String>? portRange;
  @JsonKey(name: "process_name")
  List<String>? processName;
  @JsonKey(name: "process_path")
  List<String>? processPath;
  @JsonKey(name: "process_path_regex")
  List<String>? processPathRegex;
  @JsonKey(name: "package_name")
  List<String>? packageName;
  @JsonKey(name: "package_name_regex")
  List<String>? packageNameRegex;
  @JsonKey(name: "network_type")
  List<String>? networkType;
  @JsonKey(name: "network_is_expensive")
  bool? networkIsExpensive;
  @JsonKey(name: "network_is_constrained")
  bool? networkIsConstrained;
  @JsonKey(name: "default_interface_address")
  List<String>? defaultInterfacAddress;
  @JsonKey(name: "source_mac_address")
  List<String>? sourceMacAddress;
  @JsonKey(name: "source_hostname")
  List<String>? sourceHostname;
  @JsonKey(name: "preferred_by")
  List<String>? preferredBy;
  @JsonKey(name: "wifi_ssid")
  List<String>? wifiSsid;
  @JsonKey(name: "wifi_bssid")
  List<String>? wifiBssid;
  @JsonKey(name: "rule_set_ip_cidr_match_source")
  bool? ruleSetIpCidrMatchSource;
  @JsonKey(name: "match_response")
  bool? matchResponse;
  @JsonKey(name: "ip_cidr")
  List<String>? ipCidr;
  @JsonKey(name: "ip_is_private")
  bool? ipIsPrivate;
  @JsonKey(name: "ip_accept_any")
  bool? ipAcceptAny;
  @JsonKey(name: "response_rcode")
  String? responseRcode;
  bool? invert;
  @Deprecated('已在 sing-box 1.12.0 废弃，且将在 sing-box 1.14.0 中被移除。')
  List<String>? outbound;

  /// 以下是逻辑字段 ///

  /// 可选值：logical
  String? type;

  /// 可选值：and 或 or
  String? mode;

  /// 包括的规则
  List<dynamic>? rules;

  DnsRule({
    this.action = RuleAction.route,
    this.server,
    this.strategy,
    this.disableCache,
    this.disableOptimisticCache,
    this.timeout,
    this.clientSubnet,
    this.clashMode,
    this.ruleSet,
    this.queryType,
    this.domain,
    this.domainSuffix,
    this.domainKeyword,
    this.domainRegex,
    this.inbound,
    this.ipVersion,
    this.network,
    this.protocol,
    this.sourceIpCidr,
    this.sourceIpIsPrivate,
    this.sourcePort,
    this.sourcePortRange,
    this.port,
    this.portRange,
    this.processName,
    this.processPath,
    this.processPathRegex,
    this.packageName,
    this.packageNameRegex,
    this.networkType,
    this.networkIsExpensive,
    this.networkIsConstrained,
    this.defaultInterfacAddress,
    this.sourceMacAddress,
    this.sourceHostname,
    this.preferredBy,
    this.wifiSsid,
    this.wifiBssid,
    this.ruleSetIpCidrMatchSource,
    this.matchResponse,
    this.ipCidr,
    this.ipIsPrivate,
    this.ipAcceptAny,
    this.responseRcode,
    this.invert,
    this.outbound,
    this.type,
    this.mode,
    this.rules,
  });

  factory DnsRule.fromJson(Map<String, dynamic> json) => _$DnsRuleFromJson(json);

  Map<String, dynamic> toJson() => _$DnsRuleToJson(this);
}
