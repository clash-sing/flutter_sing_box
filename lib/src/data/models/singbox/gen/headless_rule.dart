// 本文件由 tool/gen_models.dart 生成，勿手改。
import 'package:json_annotation/json_annotation.dart';

part 'headless_rule.g.dart';

@JsonSerializable(explicitToJson: true, includeIfNull: false)
class HeadlessRule {
  String? type;
  @JsonKey(name: 'query_type')
  Object? queryType;
  Object? network;
  Object? domain;
  @JsonKey(name: 'domain_suffix')
  Object? domainSuffix;
  @JsonKey(name: 'domain_keyword')
  Object? domainKeyword;
  @JsonKey(name: 'domain_regex')
  Object? domainRegex;
  @JsonKey(name: 'source_ip_cidr')
  Object? sourceIpCidr;
  @JsonKey(name: 'ip_cidr')
  Object? ipCidr;
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
  @JsonKey(name: 'network_interface_address')
  Object? networkInterfaceAddress;
  @JsonKey(name: 'default_interface_address')
  Object? defaultInterfaceAddress;
  bool? invert;
  String? mode;
  List<HeadlessRule>? rules;

  HeadlessRule();

  factory HeadlessRule.fromJson(Map<String, dynamic> json) =>
      _$HeadlessRuleFromJson(json);

  Map<String, dynamic> toJson() => _$HeadlessRuleToJson(this);
}
