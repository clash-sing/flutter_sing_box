// 本文件由 tool/gen_models.dart 生成，勿手改。
import 'package:json_annotation/json_annotation.dart';

import 'rule.dart';
import 'rule_set.dart';

part 'route_options.g.dart';

/// 顶层 `route` 配置段模型。
@JsonSerializable(explicitToJson: true, includeIfNull: false)
class RouteOptions {
  /// 对应 JSON 键 `rules`，可空（null 不参与序列化）。
  List<Rule>? rules;
  /// 对应 JSON 键 `rule_set`，可空（null 不参与序列化）。
  @JsonKey(name: 'rule_set')
  List<RuleSet>? ruleSet;
  /// 对应 JSON 键 `final`，可空（null 不参与序列化）。
  @JsonKey(name: 'final')
  String? final_;
  /// 对应 JSON 键 `find_process`，可空（null 不参与序列化）。
  @JsonKey(name: 'find_process')
  bool? findProcess;
  /// 对应 JSON 键 `find_neighbor`，可空（null 不参与序列化）。
  @JsonKey(name: 'find_neighbor')
  bool? findNeighbor;
  /// 对应 JSON 键 `dhcp_lease_files`，可空（null 不参与序列化）。
  @JsonKey(name: 'dhcp_lease_files')
  List<String>? dhcpLeaseFiles;
  /// 对应 JSON 键 `auto_detect_interface`，可空（null 不参与序列化）。
  @JsonKey(name: 'auto_detect_interface')
  bool? autoDetectInterface;
  /// 对应 JSON 键 `override_android_vpn`，可空（null 不参与序列化）。
  @JsonKey(name: 'override_android_vpn')
  bool? overrideAndroidVpn;
  /// 对应 JSON 键 `default_interface`，可空（null 不参与序列化）。
  @JsonKey(name: 'default_interface')
  String? defaultInterface;
  /// 对应 JSON 键 `default_mark`，可空（null 不参与序列化）。
  @JsonKey(name: 'default_mark')
  Object? defaultMark;
  /// 对应 JSON 键 `default_domain_resolver`，可空（null 不参与序列化）。
  @JsonKey(name: 'default_domain_resolver')
  Object? defaultDomainResolver;
  /// 对应 JSON 键 `default_network_strategy`，可空（null 不参与序列化）。
  @JsonKey(name: 'default_network_strategy')
  String? defaultNetworkStrategy;
  /// 对应 JSON 键 `default_network_type`，可空（null 不参与序列化）。
  @JsonKey(name: 'default_network_type')
  Object? defaultNetworkType;
  /// 对应 JSON 键 `default_fallback_network_type`，可空（null 不参与序列化）。
  @JsonKey(name: 'default_fallback_network_type')
  Object? defaultFallbackNetworkType;
  /// 对应 JSON 键 `default_fallback_delay`，可空（null 不参与序列化）。
  @JsonKey(name: 'default_fallback_delay')
  String? defaultFallbackDelay;
  /// 对应 JSON 键 `default_http_client`，可空（null 不参与序列化）。
  @JsonKey(name: 'default_http_client')
  String? defaultHttpClient;

  /// 构造实例；可空字段省略时为 `null`。
  RouteOptions();

  /// 从 JSON 对象反序列化为本类型。
  factory RouteOptions.fromJson(Map<String, dynamic> json) =>
      _$RouteOptionsFromJson(json);

  /// 序列化为 JSON 对象。
  Map<String, dynamic> toJson() => _$RouteOptionsToJson(this);
}
