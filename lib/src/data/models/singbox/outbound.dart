import 'package:flutter_sing_box/src/data/models/singbox/tls.dart';
import 'package:json_annotation/json_annotation.dart';

part 'outbound.g.dart';

@JsonSerializable(explicitToJson: true)
class Outbound {
  String tag;
  String type;
  List<String>? outbounds;
  @JsonKey(name: "default")
  String? defaultTag;
  String? url;
  String? interval;
  int? tolerance;
  String? server;
  @JsonKey(name: "server_port")
  int? serverPort;
  String? username;
  String? password;
  String? uuid;
  String? security;
  @JsonKey(name: "alter_id")
  int? alterId;
  @JsonKey(name: "packet_encoding")
  String? packetEncoding;
  Tls? tls;
  @JsonKey(name: "server_ports")
  List<String>? serverPorts;
  Transport? transport;
  @JsonKey(name: "up_mbps")
  int? upMbps;
  @JsonKey(name: "down_mbps")
  int? downMbps;
  @JsonKey(name: "auth_str")
  String? authStr;
  @JsonKey(name: "disable_mtu_discovery")
  bool? disableMtuDiscovery;
  Multiplex? multiplex;

  /// 在客户端启用 0-RTT QUIC 连接握手 这对性能影响不大，因为协议是完全复用的，
  /// 强烈建议禁用此功能，因为它容易受到重放攻击。
  @JsonKey(name: "zero_rtt_handshake")
  bool? zeroRttHandshake;

  /// QUIC 拥塞控制算法，可选值: cubic/new_reno/bbr，默认使用 cubic。
  @JsonKey(name: "congestion_control")
  String? congestionControl;

  /// UDP 包中继模式，可以是 native/quic，与 udp_over_stream 冲突。
  @JsonKey(name: "udp_relay_mode")
  String? udpRelayMode;

  /// TUIC 的 UDP over TCP 协议 移植， 旨在提供 TUIC 不提供的 基于 QUIC 流的 UDP 中继模式。
  /// 由于它是一个附加协议，因此您需要使用 sing-box 或其他兼容的程序作为服务器。
  /// 此模式在正确的 UDP 代理场景中没有任何积极作用，仅适用于中继流式 UDP 流量（基本上是 QUIC 流）。
  /// 与 udp_relay_mode 冲突。
  @JsonKey(name: "udp_over_stream")
  bool? udpOverStream;
  String? heartbeat;

  /// Shadowsocks 的加密方法，可选值: aes-256-gcm/aes-192-gcm/aes-128-gcm/chacha20-ietf-poly1305，等等。
  String? method;

  /// 启用的网络协议 ，tcp 或 udp。
  /// 类型可以是 String 或 List&lt;String&gt;。
  /// 默认：所有（tcp 和 udp）。
  Object? network;
  bool? quic;
  @JsonKey(name: "quic_congestion_control")
  String? quicCongestionControl;

  /// UDP over TCP 配置。
  /// 类型可以是 bool 或 [UdpOverTcp]。
  @JsonKey(name: "udp_over_tcp")
  Object? udpOverTcp;
  @JsonKey(name: "interrupt_exist_connections")
  bool? interruptExistConnections;
  @JsonKey(name: "domain_resolver")
  String? domainResolver;

  @JsonKey(name: "hop_interval")
  String? hopInterval;
  @JsonKey(name: "hop_interval_max")
  String? hopIntervalMax;
  @JsonKey(name: "bbr_profile")
  String? bbrProfile;
  @JsonKey(name: "disable_chrome_parrot")
  bool? disableChromeParrot;
  Realm? realm;
  Obfs? obfs;
  @JsonKey(name: "idle_session_check_interval")
  String? idleSessionCheckInterval;
  @JsonKey(name: "idle_session_timeout")
  String? idleSessionTimeout;
  @JsonKey(name: "min_idle_session")
  int? minIdleSession;
  @JsonKey(name: "client_metadata")
  String? clientMetadata;
  @JsonKey(name: "global_padding")
  bool? globalPadding;
  @JsonKey(name: "authenticated_length")
  bool? authenticatedLength;
  String? flow;
  String? plugin;
  @JsonKey(name: "plugin_opts")
  String? pluginOpts;

  Outbound({
    required this.tag,
    required this.type,
    this.outbounds,
    this.defaultTag,
    this.url,
    this.interval,
    this.tolerance,
    this.server,
    this.serverPort,
    this.username,
    this.password,
    this.uuid,
    this.security,
    this.alterId,
    this.packetEncoding,
    this.tls,
    this.serverPorts,
    this.transport,
    this.upMbps,
    this.downMbps,
    this.authStr,
    this.disableMtuDiscovery,
    this.multiplex,
    this.zeroRttHandshake,
    this.congestionControl,
    this.udpRelayMode,
    this.udpOverStream,
    this.heartbeat,
    this.method,
    this.network,
    this.quic,
    this.quicCongestionControl,
    this.udpOverTcp,
    this.interruptExistConnections,
    this.domainResolver,
    this.hopInterval,
    this.hopIntervalMax,
    this.bbrProfile,
    this.disableChromeParrot,
    this.realm,
    this.obfs,
    this.idleSessionCheckInterval,
    this.idleSessionTimeout,
    this.minIdleSession,
    this.clientMetadata,
    this.globalPadding,
    this.authenticatedLength,
    this.flow,
    this.plugin,
    this.pluginOpts,
  });

  factory Outbound.fromJson(Map<String, dynamic> json) => _$OutboundFromJson(json);

  Map<String, dynamic> toJson() => _$OutboundToJson(this);
}

/// V2Ray 传输层
/// V2Ray Transport 是 v2ray 发明的一组私有协议，并污染了其他协议的名称，如 clash 中的 trojan-grpc。
@JsonSerializable(explicitToJson: true)
class Transport {
  /// 可用的传输协议：HTTP（http）、WebSocket（ws）、gRPC（grpc）、QUIC（quic）、HTTPUpgrade（httpupgrade）。
  String type;
  Object? host;
  @JsonKey(name: "service_name")
  String? serviceName;
  String? path;
  String? method;
  Map<String, dynamic>? headers;
  @JsonKey(name: "idle_timeout")
  String? idleTimeout;
  @JsonKey(name: "ping_timeout")
  String? pingTimeout;
  @JsonKey(name: "max_early_data")
  int? maxEarlyData;
  @JsonKey(name: "early_data_header_name")
  String? earlyDataHeaderName;
  @JsonKey(name: "permit_without_stream")
  bool? permitWithoutStream;

  Transport({
    required this.type,
    this.host,
    this.serviceName,
    this.path,
    this.method,
    this.headers,
    this.idleTimeout,
    this.pingTimeout,
    this.maxEarlyData,
    this.earlyDataHeaderName,
    this.permitWithoutStream,
  });

  factory Transport.fromJson(Map<String, dynamic> json) => _$TransportFromJson(json);

  Map<String, dynamic> toJson() => _$TransportToJson(this);
}

@JsonSerializable(explicitToJson: true)
class Multiplex {
  bool? enabled;

  Multiplex({this.enabled});

  factory Multiplex.fromJson(Map<String, dynamic> json) => _$MultiplexFromJson(json);

  Map<String, dynamic> toJson() => _$MultiplexToJson(this);
}

/// 自 sing-box 1.14.0 起
/// 通过 Hysteria Realm 会合服务连接 Hysteria2 服务器。
@JsonSerializable(explicitToJson: true)
final class Realm {
  @JsonKey(name: "server_url")
  String? serverUrl;
  String? token;
  @JsonKey(name: "realm_id")
  String? realmId;

  /// 用于发现本客户端公网地址的 STUN 服务器列表（host 或 host:port）。
  /// 域名通过 拨号字段 中的 domain_resolver 解析。
  /// 类型可以是 String 或 List&lt;String&gt;。
  @JsonKey(name: "stun_servers")
  Object? stunServers;
  @JsonKey(name: "ip_version")
  int? ipVersion;
  @JsonKey(name: "port_mapping")
  RealmPortMapping? portMapping;
  @JsonKey(name: "http_client")
  Object? httpClient;

  Realm({
    this.serverUrl,
    this.token,
    this.realmId,
    this.stunServers,
    this.ipVersion,
    this.portMapping,
    this.httpClient,
  });

  factory Realm.fromJson(Map<String, dynamic> json) => _$RealmFromJson(json);

  Map<String, dynamic> toJson() => _$RealmToJson(this);
}

@JsonSerializable(explicitToJson: true)
final class RealmPortMapping {
  bool? enabled;
  String? timeout;
  String? lifetime;

  RealmPortMapping({this.enabled, this.timeout, this.lifetime});

  factory RealmPortMapping.fromJson(Map<String, dynamic> json) => _$RealmPortMappingFromJson(json);

  Map<String, dynamic> toJson() => _$RealmPortMappingToJson(this);
}

@JsonSerializable(explicitToJson: true)
final class Obfs {
  /// QUIC 流量混淆器类型，可选 salamander gecko。如果为空则禁用。
  String type;
  String? password;
  @JsonKey(name: "min_packet_size")
  int? minPacketSize;
  @JsonKey(name: "max_packet_size")
  int? maxPacketSize;

  Obfs({required this.type, this.password, this.minPacketSize, this.maxPacketSize});

  factory Obfs.fromJson(Map<String, dynamic> json) => _$ObfsFromJson(json);

  Map<String, dynamic> toJson() => _$ObfsToJson(this);
}

@JsonSerializable(explicitToJson: true)
final class UdpOverTcp {
  bool? enabled;

  /// 协议版本，1 或 2，默认为 2。
  int? version;

  UdpOverTcp({this.enabled, this.version});

  factory UdpOverTcp.fromJson(Map<String, dynamic> json) => _$UdpOverTcpFromJson(json);

  Map<String, dynamic> toJson() => _$UdpOverTcpToJson(this);
}
