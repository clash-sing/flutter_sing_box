import 'package:json_annotation/json_annotation.dart';

part 'clash_proxy.g.dart';

@JsonSerializable(explicitToJson: true)
class ClashProxy {
  String name;
  String type;
  String server;
  int port;
  String? ports;
  String? password;
  @JsonKey(name: "skip-cert-verify")
  bool skipCertVerify;
  @JsonKey(name: "client-fingerprint")
  String? clientFingerprint;
  bool? udp;
  bool? tfo;
  String? sni;
  String? network;
  int? up;
  int? down;
  @JsonKey(name: "auth_str")
  String? authStr;
  List<String>? alpn;
  String? protocol;
  @JsonKey(name: "fast-open")
  bool? fastOpen;
  @JsonKey(name: "disable_mtu_discovery")
  bool? disableMtuDiscovery;
  /// 用于 TUIC V5 的用户唯一识别码,使用TUIC V4时不可书写
  String? uuid;
  /// 是否在客户端启用 QUIC 的 0-RTT 握手这可以减少连接建立时间，但可能增加重放攻击的风险
  @JsonKey(name: "reduce-rtt")
  bool? reduceRtt;
  /// QUIC 拥塞控制算法，可选项为 cubic/new_reno/bbr
  @JsonKey(name: "congestion-control")
  String? congestionControl;
  /// UDP数据包中继模式，可以是 native/quic
  @JsonKey(name: "udp-relay-mode")
  String? udpRelayMode;

  ClashProxy({
    required this.name,
    required this.type,
    required this.server,
    required this.port,
    this.ports,
    this.password,
    required this.skipCertVerify,
    this.clientFingerprint,
    this.udp,
    this.tfo,
    this.sni,
    this.network,
    this.up,
    this.down,
    this.authStr,
    this.alpn,
    this.protocol,
    this.fastOpen,
    this.disableMtuDiscovery,
    this.uuid,
    this.reduceRtt,
    this.congestionControl,
    this.udpRelayMode,
  });

  factory ClashProxy.fromJson(Map<String, dynamic> json) => _$ClashProxyFromJson(json);

  Map<String, dynamic> toJson() => _$ClashProxyToJson(this);
}
