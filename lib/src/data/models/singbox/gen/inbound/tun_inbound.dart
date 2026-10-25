// 本文件由 tool/gen_models.dart 生成，勿手改。
part of 'inbound.dart';

/// `type` 判别值为 `tun` 的入站配置。
@JsonSerializable(explicitToJson: true, includeIfNull: false)
class TunInbound extends Inbound with ListenFields, DialerFields {
  /// 本类的 `type` 判别值。
  static const typeName = 'tun';

  /// 对应 JSON 键 `tag`，必填。
  @override
  String tag;
  /// 对应 JSON 键 `interface_name`，可空（null 不参与序列化）。
  @JsonKey(name: 'interface_name')
  String? interfaceName;
  /// 对应 JSON 键 `mtu`，可空（null 不参与序列化）。
  int? mtu;
  /// 对应 JSON 键 `address`，可空（null 不参与序列化）。
  Object? address;
  /// 对应 JSON 键 `dns_mode`，可空（null 不参与序列化）。
  @JsonKey(name: 'dns_mode')
  String? dnsMode;
  /// 对应 JSON 键 `dns_address`，可空（null 不参与序列化）。
  @JsonKey(name: 'dns_address')
  Object? dnsAddress;
  /// 对应 JSON 键 `auto_route`，可空（null 不参与序列化）。
  @JsonKey(name: 'auto_route')
  bool? autoRoute;
  /// 对应 JSON 键 `iproute2_table_index`，可空（null 不参与序列化）。
  @JsonKey(name: 'iproute2_table_index')
  int? iproute2TableIndex;
  /// 对应 JSON 键 `iproute2_rule_index`，可空（null 不参与序列化）。
  @JsonKey(name: 'iproute2_rule_index')
  int? iproute2RuleIndex;
  /// 对应 JSON 键 `auto_redirect`，可空（null 不参与序列化）。
  @JsonKey(name: 'auto_redirect')
  bool? autoRedirect;
  /// 对应 JSON 键 `auto_redirect_input_mark`，可空（null 不参与序列化）。
  @JsonKey(name: 'auto_redirect_input_mark')
  Object? autoRedirectInputMark;
  /// 对应 JSON 键 `auto_redirect_output_mark`，可空（null 不参与序列化）。
  @JsonKey(name: 'auto_redirect_output_mark')
  Object? autoRedirectOutputMark;
  /// 对应 JSON 键 `auto_redirect_reset_mark`，可空（null 不参与序列化）。
  @JsonKey(name: 'auto_redirect_reset_mark')
  Object? autoRedirectResetMark;
  /// 对应 JSON 键 `auto_redirect_tproxy_mark`，可空（null 不参与序列化）。
  @JsonKey(name: 'auto_redirect_tproxy_mark')
  Object? autoRedirectTproxyMark;
  /// 对应 JSON 键 `auto_redirect_nfqueue`，可空（null 不参与序列化）。
  @JsonKey(name: 'auto_redirect_nfqueue')
  int? autoRedirectNfqueue;
  /// 对应 JSON 键 `auto_redirect_iproute2_fallback_rule_index`，可空（null 不参与序列化）。
  @JsonKey(name: 'auto_redirect_iproute2_fallback_rule_index')
  int? autoRedirectIproute2FallbackRuleIndex;
  /// 对应 JSON 键 `exclude_mptcp`，可空（null 不参与序列化）。
  @JsonKey(name: 'exclude_mptcp')
  bool? excludeMptcp;
  /// 对应 JSON 键 `loopback_address`，可空（null 不参与序列化）。
  @JsonKey(name: 'loopback_address')
  Object? loopbackAddress;
  /// 对应 JSON 键 `strict_route`，可空（null 不参与序列化）。
  @JsonKey(name: 'strict_route')
  bool? strictRoute;
  /// 对应 JSON 键 `route_address`，可空（null 不参与序列化）。
  @JsonKey(name: 'route_address')
  Object? routeAddress;
  /// 对应 JSON 键 `route_address_set`，可空（null 不参与序列化）。
  @JsonKey(name: 'route_address_set')
  Object? routeAddressSet;
  /// 对应 JSON 键 `route_exclude_address`，可空（null 不参与序列化）。
  @JsonKey(name: 'route_exclude_address')
  Object? routeExcludeAddress;
  /// 对应 JSON 键 `route_exclude_address_set`，可空（null 不参与序列化）。
  @JsonKey(name: 'route_exclude_address_set')
  Object? routeExcludeAddressSet;
  /// 对应 JSON 键 `include_interface`，可空（null 不参与序列化）。
  @JsonKey(name: 'include_interface')
  Object? includeInterface;
  /// 对应 JSON 键 `exclude_interface`，可空（null 不参与序列化）。
  @JsonKey(name: 'exclude_interface')
  Object? excludeInterface;
  /// 对应 JSON 键 `include_uid`，可空（null 不参与序列化）。
  @JsonKey(name: 'include_uid')
  Object? includeUid;
  /// 对应 JSON 键 `include_uid_range`，可空（null 不参与序列化）。
  @JsonKey(name: 'include_uid_range')
  Object? includeUidRange;
  /// 对应 JSON 键 `exclude_uid`，可空（null 不参与序列化）。
  @JsonKey(name: 'exclude_uid')
  Object? excludeUid;
  /// 对应 JSON 键 `exclude_uid_range`，可空（null 不参与序列化）。
  @JsonKey(name: 'exclude_uid_range')
  Object? excludeUidRange;
  /// 对应 JSON 键 `include_android_user`，可空（null 不参与序列化）。
  @JsonKey(name: 'include_android_user')
  Object? includeAndroidUser;
  /// 对应 JSON 键 `include_package`，可空（null 不参与序列化）。
  @JsonKey(name: 'include_package')
  Object? includePackage;
  /// 对应 JSON 键 `exclude_package`，可空（null 不参与序列化）。
  @JsonKey(name: 'exclude_package')
  Object? excludePackage;
  /// 对应 JSON 键 `include_mac_address`，可空（null 不参与序列化）。
  @JsonKey(name: 'include_mac_address')
  Object? includeMacAddress;
  /// 对应 JSON 键 `exclude_mac_address`，可空（null 不参与序列化）。
  @JsonKey(name: 'exclude_mac_address')
  Object? excludeMacAddress;
  /// 对应 JSON 键 `udp_mapping`，可空（null 不参与序列化）。
  @JsonKey(name: 'udp_mapping')
  String? udpMapping;
  /// 对应 JSON 键 `udp_filtering`，可空（null 不参与序列化）。
  @JsonKey(name: 'udp_filtering')
  String? udpFiltering;
  /// 对应 JSON 键 `udp_nat_max`，可空（null 不参与序列化）。
  @JsonKey(name: 'udp_nat_max')
  int? udpNatMax;
  /// 对应 JSON 键 `multi_queue`，可空（null 不参与序列化）。
  @JsonKey(name: 'multi_queue')
  bool? multiQueue;
  /// 对应 JSON 键 `platform`，可空（null 不参与序列化）。
  TunPlatformOptions? platform;

  /// 以 [tag] 构造；可空字段省略时为 `null`。
  TunInbound({
    required this.tag,
    // 可空字段省略（默认 null）
  });

  /// `type` 判别值，固定为 [typeName]。
  @override
  String get type => typeName;

  /// 从 JSON 对象反序列化为本类型。
  factory TunInbound.fromJson(Map<String, dynamic> json) =>
      _$TunInboundFromJson(json);

  /// 序列化为 JSON；输出携带 `type` 判别键。
  @override
  Map<String, dynamic> toJson() =>
      {'type': typeName, ..._$TunInboundToJson(this)};
}
