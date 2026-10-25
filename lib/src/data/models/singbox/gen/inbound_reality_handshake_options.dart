// 本文件由 tool/gen_models.dart 生成，勿手改。
import 'package:json_annotation/json_annotation.dart';

part 'inbound_reality_handshake_options.g.dart';

/// 由官方 JSON schema `$defs/InboundRealityHandshakeOptions` 定义的配置模型。
@JsonSerializable(explicitToJson: true, includeIfNull: false)
class InboundRealityHandshakeOptions {
  /// 对应 JSON 键 `server`，可空（null 不参与序列化）。
  String? server;
  /// 对应 JSON 键 `server_port`，可空（null 不参与序列化）。
  @JsonKey(name: 'server_port')
  int? serverPort;
  /// 对应 JSON 键 `detour`，可空（null 不参与序列化）。
  String? detour;
  /// 对应 JSON 键 `bind_interface`，可空（null 不参与序列化）。
  @JsonKey(name: 'bind_interface')
  String? bindInterface;
  /// 对应 JSON 键 `inet4_bind_address`，可空（null 不参与序列化）。
  @JsonKey(name: 'inet4_bind_address')
  Object? inet4BindAddress;
  /// 对应 JSON 键 `inet6_bind_address`，可空（null 不参与序列化）。
  @JsonKey(name: 'inet6_bind_address')
  Object? inet6BindAddress;
  /// 对应 JSON 键 `bind_address_no_port`，可空（null 不参与序列化）。
  @JsonKey(name: 'bind_address_no_port')
  bool? bindAddressNoPort;
  /// 对应 JSON 键 `protect_path`，可空（null 不参与序列化）。
  @JsonKey(name: 'protect_path')
  String? protectPath;
  /// 对应 JSON 键 `routing_mark`，可空（null 不参与序列化）。
  @JsonKey(name: 'routing_mark')
  Object? routingMark;
  /// 对应 JSON 键 `reuse_addr`，可空（null 不参与序列化）。
  @JsonKey(name: 'reuse_addr')
  bool? reuseAddr;
  /// 对应 JSON 键 `netns`，可空（null 不参与序列化）。
  String? netns;
  /// 对应 JSON 键 `connect_timeout`，可空（null 不参与序列化）。
  @JsonKey(name: 'connect_timeout')
  String? connectTimeout;
  /// 对应 JSON 键 `tcp_fast_open`，可空（null 不参与序列化）。
  @JsonKey(name: 'tcp_fast_open')
  bool? tcpFastOpen;
  /// 对应 JSON 键 `tcp_multi_path`，可空（null 不参与序列化）。
  @JsonKey(name: 'tcp_multi_path')
  bool? tcpMultiPath;
  /// 对应 JSON 键 `disable_tcp_keep_alive`，可空（null 不参与序列化）。
  @JsonKey(name: 'disable_tcp_keep_alive')
  bool? disableTcpKeepAlive;
  /// 对应 JSON 键 `tcp_keep_alive`，可空（null 不参与序列化）。
  @JsonKey(name: 'tcp_keep_alive')
  String? tcpKeepAlive;
  /// 对应 JSON 键 `tcp_keep_alive_interval`，可空（null 不参与序列化）。
  @JsonKey(name: 'tcp_keep_alive_interval')
  String? tcpKeepAliveInterval;
  /// 对应 JSON 键 `udp_fragment`，可空（null 不参与序列化）。
  @JsonKey(name: 'udp_fragment')
  bool? udpFragment;
  /// 对应 JSON 键 `domain_resolver`，可空（null 不参与序列化）。
  @JsonKey(name: 'domain_resolver')
  Object? domainResolver;
  /// 对应 JSON 键 `network_strategy`，可空（null 不参与序列化）。
  @JsonKey(name: 'network_strategy')
  String? networkStrategy;
  /// 对应 JSON 键 `network_type`，可空（null 不参与序列化）。
  @JsonKey(name: 'network_type')
  Object? networkType;
  /// 对应 JSON 键 `fallback_network_type`，可空（null 不参与序列化）。
  @JsonKey(name: 'fallback_network_type')
  Object? fallbackNetworkType;
  /// 对应 JSON 键 `fallback_delay`，可空（null 不参与序列化）。
  @JsonKey(name: 'fallback_delay')
  String? fallbackDelay;

  /// 构造实例；可空字段省略时为 `null`。
  InboundRealityHandshakeOptions();

  /// 从 JSON 对象反序列化为本类型。
  factory InboundRealityHandshakeOptions.fromJson(Map<String, dynamic> json) =>
      _$InboundRealityHandshakeOptionsFromJson(json);

  /// 序列化为 JSON 对象。
  Map<String, dynamic> toJson() => _$InboundRealityHandshakeOptionsToJson(this);
}
