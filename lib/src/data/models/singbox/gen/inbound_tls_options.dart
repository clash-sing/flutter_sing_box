// 本文件由 tool/gen_models.dart 生成，勿手改。
import 'package:json_annotation/json_annotation.dart';

import 'inbound_ech_options.dart';
import 'inbound_reality_options.dart';

part 'inbound_tls_options.g.dart';

@JsonSerializable(explicitToJson: true, includeIfNull: false)
class InboundTLSOptions {
  bool? enabled;
  @JsonKey(name: 'server_name')
  String? serverName;
  bool? insecure;
  Object? alpn;
  @JsonKey(name: 'min_version')
  String? minVersion;
  @JsonKey(name: 'max_version')
  String? maxVersion;
  @JsonKey(name: 'cipher_suites')
  List<String>? cipherSuites;
  @JsonKey(name: 'curve_preferences')
  List<String>? curvePreferences;
  Object? certificate;
  @JsonKey(name: 'certificate_path')
  String? certificatePath;
  @JsonKey(name: 'client_authentication')
  String? clientAuthentication;
  @JsonKey(name: 'client_certificate')
  Object? clientCertificate;
  @JsonKey(name: 'client_certificate_path')
  Object? clientCertificatePath;
  @JsonKey(name: 'client_certificate_sha256')
  Object? clientCertificateSha256;
  @JsonKey(name: 'client_certificate_public_key_sha256')
  Object? clientCertificatePublicKeySha256;
  Object? key;
  @JsonKey(name: 'key_path')
  String? keyPath;
  @JsonKey(name: 'kernel_tx')
  bool? kernelTx;
  @JsonKey(name: 'kernel_rx')
  bool? kernelRx;
  @JsonKey(name: 'handshake_timeout')
  String? handshakeTimeout;
  @JsonKey(name: 'certificate_provider')
  Object? certificateProvider;
  InboundECHOptions? ech;
  InboundRealityOptions? reality;

  InboundTLSOptions();

  factory InboundTLSOptions.fromJson(Map<String, dynamic> json) =>
      _$InboundTLSOptionsFromJson(json);

  Map<String, dynamic> toJson() => _$InboundTLSOptionsToJson(this);
}
