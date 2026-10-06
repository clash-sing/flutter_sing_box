// 本文件由 tool/gen_models.dart 生成，勿手改。
import 'package:json_annotation/json_annotation.dart';

import 'rule.dart';
import 'rule_set.dart';

part 'route_options.g.dart';

@JsonSerializable(explicitToJson: true, includeIfNull: false)
class RouteOptions {
  List<Rule>? rules;
  @JsonKey(name: 'rule_set')
  List<RuleSet>? ruleSet;
  @JsonKey(name: 'final')
  String? final_;
  @JsonKey(name: 'find_process')
  bool? findProcess;
  @JsonKey(name: 'find_neighbor')
  bool? findNeighbor;
  @JsonKey(name: 'dhcp_lease_files')
  List<String>? dhcpLeaseFiles;
  @JsonKey(name: 'auto_detect_interface')
  bool? autoDetectInterface;
  @JsonKey(name: 'override_android_vpn')
  bool? overrideAndroidVpn;
  @JsonKey(name: 'default_interface')
  String? defaultInterface;
  @JsonKey(name: 'default_mark')
  Object? defaultMark;
  @JsonKey(name: 'default_domain_resolver')
  Object? defaultDomainResolver;
  @JsonKey(name: 'default_network_strategy')
  String? defaultNetworkStrategy;
  @JsonKey(name: 'default_network_type')
  Object? defaultNetworkType;
  @JsonKey(name: 'default_fallback_network_type')
  Object? defaultFallbackNetworkType;
  @JsonKey(name: 'default_fallback_delay')
  String? defaultFallbackDelay;
  @JsonKey(name: 'default_http_client')
  String? defaultHttpClient;

  RouteOptions();

  factory RouteOptions.fromJson(Map<String, dynamic> json) =>
      _$RouteOptionsFromJson(json);

  Map<String, dynamic> toJson() => _$RouteOptionsToJson(this);
}
