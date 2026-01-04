import 'package:json_annotation/json_annotation.dart';

part 'route.g.dart';

@JsonSerializable(explicitToJson: true)
class Route {
  @JsonKey(name: "default_domain_resolver")
  String defaultDomainResolver;
  List<RouteRule> rules;
  @JsonKey(name: "final")
  String? routeFinal;
  @JsonKey(name: "auto_detect_interface")
  bool autoDetectInterface;
  @JsonKey(name: "rule_set")
  List<RuleSet> ruleSet;

  Route({
    required this.defaultDomainResolver,
    required this.rules,
    required this.routeFinal,
    required this.autoDetectInterface,
    required this.ruleSet,
  });

  factory Route.fromJson(Map<String, dynamic> json) => _$RouteFromJson(json);

  Map<String, dynamic> toJson() => _$RouteToJson(this);
}


@JsonSerializable()
class RouteRule {
  String? action;
  dynamic protocol;
  @JsonKey(name: "clash_mode")
  String? clashMode;
  String? outbound;
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



  RouteRule({
    this.action,
    this.protocol,
    this.clashMode,
    this.outbound,
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
  });

  factory RouteRule.fromJson(Map<String, dynamic> json) => _$RouteRuleFromJson(json);

  Map<String, dynamic> toJson() => _$RouteRuleToJson(this);
}


@JsonSerializable()
class RuleSet {
  String tag;
  String type;
  String format;
  String url;
  @JsonKey(name: "download_detour")
  String? downloadDetour;
  @JsonKey(name: "update_interval")
  String? updateInterval;

  RuleSet({
    required this.tag,
    required this.type,
    required this.format,
    required this.url,
    this.downloadDetour,
    this.updateInterval,
  });

  factory RuleSet.fromJson(Map<String, dynamic> json) => _$RuleSetFromJson(json);

  Map<String, dynamic> toJson() => _$RuleSetToJson(this);
}