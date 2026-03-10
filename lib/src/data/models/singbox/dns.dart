import 'package:json_annotation/json_annotation.dart';
import '../../../constants/rule_action.dart';

part 'dns.g.dart';

@JsonSerializable(explicitToJson: true)
class Dns {
  List<Server> servers;
  List<DnsRule> rules;
  @JsonKey(name: "independent_cache")
  bool independentCache;
  @JsonKey(name: "final")
  String dnsFinal;
  String strategy;

  Dns({
    required this.servers,
    required this.rules,
    required this.independentCache,
    required this.dnsFinal,
    required this.strategy,
  });

  factory Dns.fromJson(Map<String, dynamic> json) => _$DnsFromJson(json);

  Map<String, dynamic> toJson() => _$DnsToJson(this);
}


@JsonSerializable()
class Server {
  String tag;
  String type;
  String? server;
  @JsonKey(name: "inet4_range")
  String? inet4Range;
  @JsonKey(name: "inet6_range")
  String? inet6Range;

  Server({
    required this.tag,
    required this.type,
    this.server,
    this.inet4Range,
    this.inet6Range,
  });

  factory Server.fromJson(Map<String, dynamic> json) => _$ServerFromJson(json);

  Map<String, dynamic> toJson() => _$ServerToJson(this);
}


@JsonSerializable()
class DnsRule {
  String action;
  String? server;
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

  DnsRule({
    this.action = RuleAction.route,
    this.server,
    this.clashMode,
    this.ruleSet,
    this.queryType,
    this.domain,
    this.domainSuffix,
    this.domainKeyword,
    this.domainRegex,
  });

  factory DnsRule.fromJson(Map<String, dynamic> json) => _$DnsRuleFromJson(json);

  Map<String, dynamic> toJson() => _$DnsRuleToJson(this);
}