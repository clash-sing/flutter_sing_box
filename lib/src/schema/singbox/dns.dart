import 'package:json_annotation/json_annotation.dart';

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
  @JsonKey(name: "clash_mode")
  String? clashMode;
  String server;
  @JsonKey(name: "rule_set")
  List<String>? ruleSet;
  @JsonKey(name: "query_type")
  List<String>? queryType;

  DnsRule({
    this.clashMode,
    required this.server,
    this.ruleSet,
    this.queryType,
  });

  factory DnsRule.fromJson(Map<String, dynamic> json) => _$DnsRuleFromJson(json);

  Map<String, dynamic> toJson() => _$DnsRuleToJson(this);
}