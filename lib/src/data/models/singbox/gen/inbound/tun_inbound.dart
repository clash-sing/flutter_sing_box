// 本文件由 tool/gen_models.dart 生成，勿手改。
part of 'inbound.dart';

@JsonSerializable(explicitToJson: true, includeIfNull: false)
class TunInbound extends Inbound with ListenFields, DialerFields {
  static const typeName = 'tun';

  @override
  String tag;
  @JsonKey(name: 'interface_name')
  String? interfaceName;
  int? mtu;
  Object? address;
  @JsonKey(name: 'dns_mode')
  String? dnsMode;
  @JsonKey(name: 'dns_address')
  Object? dnsAddress;
  @JsonKey(name: 'auto_route')
  bool? autoRoute;
  @JsonKey(name: 'iproute2_table_index')
  int? iproute2TableIndex;
  @JsonKey(name: 'iproute2_rule_index')
  int? iproute2RuleIndex;
  @JsonKey(name: 'auto_redirect')
  bool? autoRedirect;
  @JsonKey(name: 'auto_redirect_input_mark')
  Object? autoRedirectInputMark;
  @JsonKey(name: 'auto_redirect_output_mark')
  Object? autoRedirectOutputMark;
  @JsonKey(name: 'auto_redirect_reset_mark')
  Object? autoRedirectResetMark;
  @JsonKey(name: 'auto_redirect_tproxy_mark')
  Object? autoRedirectTproxyMark;
  @JsonKey(name: 'auto_redirect_nfqueue')
  int? autoRedirectNfqueue;
  @JsonKey(name: 'auto_redirect_iproute2_fallback_rule_index')
  int? autoRedirectIproute2FallbackRuleIndex;
  @JsonKey(name: 'exclude_mptcp')
  bool? excludeMptcp;
  @JsonKey(name: 'loopback_address')
  Object? loopbackAddress;
  @JsonKey(name: 'strict_route')
  bool? strictRoute;
  @JsonKey(name: 'route_address')
  Object? routeAddress;
  @JsonKey(name: 'route_address_set')
  Object? routeAddressSet;
  @JsonKey(name: 'route_exclude_address')
  Object? routeExcludeAddress;
  @JsonKey(name: 'route_exclude_address_set')
  Object? routeExcludeAddressSet;
  @JsonKey(name: 'include_interface')
  Object? includeInterface;
  @JsonKey(name: 'exclude_interface')
  Object? excludeInterface;
  @JsonKey(name: 'include_uid')
  Object? includeUid;
  @JsonKey(name: 'include_uid_range')
  Object? includeUidRange;
  @JsonKey(name: 'exclude_uid')
  Object? excludeUid;
  @JsonKey(name: 'exclude_uid_range')
  Object? excludeUidRange;
  @JsonKey(name: 'include_android_user')
  Object? includeAndroidUser;
  @JsonKey(name: 'include_package')
  Object? includePackage;
  @JsonKey(name: 'exclude_package')
  Object? excludePackage;
  @JsonKey(name: 'include_mac_address')
  Object? includeMacAddress;
  @JsonKey(name: 'exclude_mac_address')
  Object? excludeMacAddress;
  @JsonKey(name: 'udp_mapping')
  String? udpMapping;
  @JsonKey(name: 'udp_filtering')
  String? udpFiltering;
  @JsonKey(name: 'udp_nat_max')
  int? udpNatMax;
  @JsonKey(name: 'multi_queue')
  bool? multiQueue;
  TunPlatformOptions? platform;

  TunInbound({
    required this.tag,
    // 可空字段省略（默认 null）
  });

  @override
  String get type => typeName;

  factory TunInbound.fromJson(Map<String, dynamic> json) =>
      _$TunInboundFromJson(json);

  @override
  Map<String, dynamic> toJson() =>
      {'type': typeName, ..._$TunInboundToJson(this)};
}
