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
  });

  factory ClashProxy.fromJson(Map<String, dynamic> json) => _$ClashProxyFromJson(json);

  Map<String, dynamic> toJson() => _$ClashProxyToJson(this);
}
