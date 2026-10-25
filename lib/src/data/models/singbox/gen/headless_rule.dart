// 本文件由 tool/gen_models.dart 生成，勿手改。
import 'package:json_annotation/json_annotation.dart';

part 'headless_rule.g.dart';

/// 由官方 JSON schema `$defs/HeadlessRule` 定义的配置模型。
@JsonSerializable(explicitToJson: true, includeIfNull: false)
class HeadlessRule {
  /// 对应 JSON 键 `type`，可空（null 不参与序列化）。
  String? type;
  /// 对应 JSON 键 `query_type`，可空（null 不参与序列化）。
  @JsonKey(name: 'query_type')
  Object? queryType;
  /// 对应 JSON 键 `network`，可空（null 不参与序列化）。
  Object? network;
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
  /// 对应 JSON 键 `ip_cidr`，可空（null 不参与序列化）。
  @JsonKey(name: 'ip_cidr')
  Object? ipCidr;
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
  /// 对应 JSON 键 `network_interface_address`，可空（null 不参与序列化）。
  @JsonKey(name: 'network_interface_address')
  Object? networkInterfaceAddress;
  /// 对应 JSON 键 `default_interface_address`，可空（null 不参与序列化）。
  @JsonKey(name: 'default_interface_address')
  Object? defaultInterfaceAddress;
  /// 对应 JSON 键 `invert`，可空（null 不参与序列化）。
  bool? invert;
  /// 对应 JSON 键 `mode`，可空（null 不参与序列化）。
  String? mode;
  /// 对应 JSON 键 `rules`，可空（null 不参与序列化）。
  List<HeadlessRule>? rules;

  /// 构造实例；可空字段省略时为 `null`。
  HeadlessRule();

  /// 从 JSON 对象反序列化为本类型。
  factory HeadlessRule.fromJson(Map<String, dynamic> json) =>
      _$HeadlessRuleFromJson(json);

  /// 序列化为 JSON 对象。
  Map<String, dynamic> toJson() => _$HeadlessRuleToJson(this);
}
