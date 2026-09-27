import 'package:json_annotation/json_annotation.dart';

part 'tls.g.dart';

@JsonSerializable(explicitToJson: true)
class Tls {
  Object? alpn;
  bool? enabled;
  @JsonKey(name: "disable_sni")
  bool? disableSni;
  bool? insecure;
  @JsonKey(name: "server_name")
  String? serverName;
  Utls? utls;
  Reality? reality;

  Tls({this.alpn, this.enabled, this.disableSni, this.insecure, this.serverName, this.utls, this.reality});

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

/// Reality TLS 配置（VLESS Reality 所需）。
@JsonSerializable(explicitToJson: true)
class Reality {
  bool? enabled;

  /// 服务器 x25519 公钥（分享链接的 pbk 参数）。
  @JsonKey(name: "public_key")
  String? publicKey;

  /// 服务器 short_id（分享链接的 sid 参数），可为空字符串。
  @JsonKey(name: "short_id")
  String? shortId;

  Reality({this.enabled, this.publicKey, this.shortId});

  factory Reality.fromJson(Map<String, dynamic> json) => _$RealityFromJson(json);

  Map<String, dynamic> toJson() => _$RealityToJson(this);
}
