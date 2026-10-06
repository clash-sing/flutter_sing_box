// 本文件由 tool/gen_models.dart 生成，勿手改。
import 'package:json_annotation/json_annotation.dart';

import 'outbound_ech_options.dart';
import 'outbound_reality_options.dart';
import 'outbound_utls_options.dart';

part 'outbound_tls_options.g.dart';

@JsonSerializable(explicitToJson: true, includeIfNull: false)
class OutboundTLSOptions {
  bool? enabled;
  String? engine;
  @JsonKey(name: 'disable_sni')
  bool? disableSni;
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
  @JsonKey(name: 'certificate_sha256')
  Object? certificateSha256;
  @JsonKey(name: 'certificate_public_key_sha256')
  Object? certificatePublicKeySha256;
  @JsonKey(name: 'client_certificate')
  Object? clientCertificate;
  @JsonKey(name: 'client_certificate_path')
  String? clientCertificatePath;
  @JsonKey(name: 'client_key')
  Object? clientKey;
  @JsonKey(name: 'client_key_path')
  String? clientKeyPath;
  bool? fragment;
  @JsonKey(name: 'fragment_fallback_delay')
  String? fragmentFallbackDelay;
  @JsonKey(name: 'record_fragment')
  bool? recordFragment;
  String? spoof;
  @JsonKey(name: 'spoof_method')
  String? spoofMethod;
  @JsonKey(name: 'kernel_tx')
  bool? kernelTx;
  @JsonKey(name: 'kernel_rx')
  bool? kernelRx;
  @JsonKey(name: 'handshake_timeout')
  String? handshakeTimeout;
  OutboundECHOptions? ech;
  OutboundUTLSOptions? utls;
  OutboundRealityOptions? reality;

  OutboundTLSOptions();

  factory OutboundTLSOptions.fromJson(Map<String, dynamic> json) =>
      _$OutboundTLSOptionsFromJson(json);

  Map<String, dynamic> toJson() => _$OutboundTLSOptionsToJson(this);
}
