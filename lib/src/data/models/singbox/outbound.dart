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