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

  Outbound({
    required this.tag,
    required this.type,
    this.outbounds,
    this.url,
    this.interval,
    this.tolerance,
    this.server,
    this.serverPort,
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
  });

  factory Outbound.fromJson(Map<String, dynamic> json) => _$OutboundFromJson(json);

  Map<String, dynamic> toJson() => _$OutboundToJson(this);
}

@JsonSerializable(explicitToJson: true)
class Tls {
  List<String>? alpn;
  bool enabled;
  @JsonKey(name: "disable_sni")
  bool? disableSni;
  bool insecure;
  @JsonKey(name: "server_name")
  String? serverName;
  Utls? utls;

  Tls({
    this.alpn,
    required this.enabled,
    this.disableSni,
    required this.insecure,
    this.serverName,
    this.utls,
  });

  factory Tls.fromJson(Map<String, dynamic> json) => _$TlsFromJson(json);

  Map<String, dynamic> toJson() => _$TlsToJson(this);
}


@JsonSerializable()
class Utls {
  bool enabled;
  String fingerprint;

  Utls({
    required this.enabled,
    required this.fingerprint,
  });

  factory Utls.fromJson(Map<String, dynamic> json) => _$UtlsFromJson(json);

  Map<String, dynamic> toJson() => _$UtlsToJson(this);
}

@JsonSerializable()
class Transport {
  String type;
  String? path;
  Map<String, dynamic>? headers;
  @JsonKey(name: "max_early_data")
  int? maxEarlyData;
  @JsonKey(name: "early_data_header_name")
  String? earlyDataHeaderName;

  Transport({
    required this.type,
    this.path,
    this.headers,
    this.maxEarlyData,
    this.earlyDataHeaderName,
  });

  factory Transport.fromJson(Map<String, dynamic> json) => _$TransportFromJson(json);

  Map<String, dynamic> toJson() => _$TransportToJson(this);
}

@JsonSerializable()
class Multiplex {
  bool enabled;

  Multiplex({
    required this.enabled,
  });

  factory Multiplex.fromJson(Map<String, dynamic> json) => _$MultiplexFromJson(json);

  Map<String, dynamic> toJson() => _$MultiplexToJson(this);

}