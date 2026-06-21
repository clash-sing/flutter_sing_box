import 'package:json_annotation/json_annotation.dart';

part 'tls.g.dart';

@JsonSerializable(explicitToJson: true)
class Tls {
  List<String>? alpn;
  bool? enabled;
  @JsonKey(name: "disable_sni")
  bool? disableSni;
  bool? insecure;
  @JsonKey(name: "server_name")
  String? serverName;
  Utls? utls;

  Tls({this.alpn, this.enabled, this.disableSni, this.insecure, this.serverName, this.utls});

  factory Tls.fromJson(Map<String, dynamic> json) => _$TlsFromJson(json);

  Map<String, dynamic> toJson() => _$TlsToJson(this);
}

@JsonSerializable(explicitToJson: true)
class Utls {
  bool? enabled;
  String? fingerprint;

  Utls({this.enabled, this.fingerprint});

  factory Utls.fromJson(Map<String, dynamic> json) => _$UtlsFromJson(json);

  Map<String, dynamic> toJson() => _$UtlsToJson(this);
}
