import 'package:json_annotation/json_annotation.dart';

part 'inbound.g.dart';

@JsonSerializable(explicitToJson: true)
class Inbound {
  String tag;
  String type;
  List<String>? address;
  int? mtu;
  String? stack;
  @JsonKey(name: "auto_route")
  bool? autoRoute;
  @JsonKey(name: "strict_route")
  bool? strictRoute;
  bool sniff;
  @JsonKey(name: "sniff_override_destination")
  bool? sniffOverrideDestination;
  Platform? platform;
  String? listen;
  @JsonKey(name: "listen_port")
  int? listenPort;

  Inbound({
    required this.tag,
    required this.type,
    this.address,
    this.mtu,
    this.stack,
    this.autoRoute,
    this.strictRoute,
    required this.sniff,
    this.sniffOverrideDestination,
    this.platform,
    this.listen,
    this.listenPort,
  });

  factory Inbound.fromJson(Map<String, dynamic> json) => _$InboundFromJson(json);

  Map<String, dynamic> toJson() => _$InboundToJson(this);
}


@JsonSerializable(explicitToJson: true)
class Platform {
  @JsonKey(name: "http_proxy")
  HttpProxy httpProxy;

  Platform({
    required this.httpProxy,
  });

  factory Platform.fromJson(Map<String, dynamic> json) => _$PlatformFromJson(json);

  Map<String, dynamic> toJson() => _$PlatformToJson(this);
}


@JsonSerializable()
class HttpProxy {
  bool enabled;
  String server;
  @JsonKey(name: "server_port")
  int serverPort;

  HttpProxy({
    required this.enabled,
    required this.server,
    required this.serverPort,
  });

  factory HttpProxy.fromJson(Map<String, dynamic> json) => _$HttpProxyFromJson(json);

  Map<String, dynamic> toJson() => _$HttpProxyToJson(this);
}