import 'package:json_annotation/json_annotation.dart';
import '../../../constants/rule_action.dart';

part 'route.g.dart';

@JsonSerializable(explicitToJson: true)
class Route {
  List<RouteRule> rules;
  @JsonKey(name: "auto_detect_interface")
  bool? autoDetectInterface;
  @JsonKey(name: "default_domain_resolver")
  String? defaultDomainResolver;
  @JsonKey(name: "final")
  String? routeFinal;
  @JsonKey(name: "rule_set")
  List<RuleSet>? ruleSet;

  Route({
    required this.rules,
    this.autoDetectInterface,
    this.defaultDomainResolver,
    this.routeFinal,
    this.ruleSet,
  });

  factory Route.fromJson(Map<String, dynamic> json) => _$RouteFromJson(json);

  Map<String, dynamic> toJson() => _$RouteToJson(this);
}

@JsonSerializable(explicitToJson: true)
class RouteRule {
  String action;
  String? outbound;

  /// 仅当 action 为 'redirect' 时有效，默认：default
  String? method;

  /// 仅当 action 为 'redirect' 时有效。
  @JsonKey(name: "no_drop")
  bool? noDrop;
  dynamic protocol;
  @JsonKey(name: "clash_mode")
  String? clashMode;
  List<String>? domain;
  @JsonKey(name: "domain_suffix")
  List<String>? domainSuffix;
  @JsonKey(name: "domain_keyword")
  List<String>? domainKeyword;
  @JsonKey(name: "domain_regex")
  List<String>? domainRegex;
  @JsonKey(name: "process_name")
  List<String>? processName;
  @JsonKey(name: "process_path")
  List<String>? processPath;
  @JsonKey(name: "process_path_regex")
  List<String>? processPathRegex;
  @JsonKey(name: "package_name")
  List<String>? packageName;
  @JsonKey(name: "ip_is_private")
  bool? ipIsPrivate;
  @JsonKey(name: "rule_set")
  List<String>? ruleSet;
  @JsonKey(name: "ip_cidr")
  List<String>? ipCidr;
  @JsonKey(name: "source_ip_cidr")
  List<String>? sourceIpCidr;
  List<int>? port;
  @JsonKey(name: "port_range")
  List<String>? portRange;
  @JsonKey(name: "source_port")
  List<int>? sourcePort;
  @JsonKey(name: "source_port_range")
  List<String>? sourcePortRange;
  String? timeout;
  List<String>? inbound;

  /// 4 (A DNS 查询) 或 6 (AAAA DNS 查询)
  @JsonKey(name: "ip_version")
  int? ipVersion;

  /// tcp 或 udp
  String? network;
  List<String>? client;
  @JsonKey(name: "source_ip_is_private")
  bool? sourceIpIsPrivate;
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
  @JsonKey(name: "wifi_ssid")
  List<String>? wifiSsid;
  @JsonKey(name: "wifi_bssid")
  List<String>? wifiBssid;
  @JsonKey(name: "preferred_by")
  List<String>? preferredBy;
  @JsonKey(name: "source_mac_address")
  List<String>? sourceMacAddress;
  @JsonKey(name: "source_hostname")
  List<String>? sourceHostname;
  bool? invert;

  /// 以下是逻辑字段 ///

  /// 可选值：logical
  String? type;

  /// 可选值：and 或 or
  String? mode;

  /// 包括的规则
  List<dynamic>? rules;

  RouteRule({
    this.action = RuleAction.route,
    this.outbound,
    this.method,
    this.noDrop,
    this.protocol,
    this.clashMode,
    this.domain,
    this.domainSuffix,
    this.domainKeyword,
    this.domainRegex,
    this.processName,
    this.processPath,
    this.processPathRegex,
    this.packageName,
    this.ipIsPrivate,
    this.ruleSet,
    this.ipCidr,
    this.sourceIpCidr,
    this.port,
    this.portRange,
    this.sourcePort,
    this.sourcePortRange,
    this.timeout,
    this.inbound,
    this.ipVersion,
    this.network,
    this.client,
    this.sourceIpIsPrivate,
    this.packageNameRegex,
    this.networkType,
    this.networkIsExpensive,
    this.networkIsConstrained,
    this.defaultInterfacAddress,
    this.wifiSsid,
    this.wifiBssid,
    this.preferredBy,
    this.sourceMacAddress,
    this.sourceHostname,
    this.invert,
    this.type,
    this.mode,
    this.rules,
  });

  factory RouteRule.fromJson(Map<String, dynamic> json) => _$RouteRuleFromJson(json);

  Map<String, dynamic> toJson() => _$RouteRuleToJson(this);
}

@JsonSerializable(explicitToJson: true)
class RuleSet {
  String tag;
  String type;
  String? format;
  String? url;
  @JsonKey(name: "download_detour")
  String? downloadDetour;
  @JsonKey(name: "update_interval")
  String? updateInterval;
  String? path;

  RuleSet({
    required this.tag,
    required this.type,
    this.format,
    this.url,
    this.downloadDetour,
    this.updateInterval,
    this.path,
  });

  factory RuleSet.fromJson(Map<String, dynamic> json) => _$RuleSetFromJson(json);

  Map<String, dynamic> toJson() => _$RuleSetToJson(this);
}
