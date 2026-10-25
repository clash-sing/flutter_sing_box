// 本文件由 tool/gen_models.dart 生成，勿手改。
import 'package:json_annotation/json_annotation.dart';

import 'inbound_ech_options.dart';
import 'inbound_reality_options.dart';

part 'inbound_tls_options.g.dart';

/// 由官方 JSON schema `$defs/InboundTLSOptions` 定义的配置模型。
@JsonSerializable(explicitToJson: true, includeIfNull: false)
class InboundTLSOptions {
  /// 对应 JSON 键 `enabled`，可空（null 不参与序列化）。
  bool? enabled;
  /// 对应 JSON 键 `server_name`，可空（null 不参与序列化）。
  @JsonKey(name: 'server_name')
  String? serverName;
  /// 对应 JSON 键 `insecure`，可空（null 不参与序列化）。
  bool? insecure;
  /// 对应 JSON 键 `alpn`，可空（null 不参与序列化）。
  Object? alpn;
  /// 对应 JSON 键 `min_version`，可空（null 不参与序列化）。
  @JsonKey(name: 'min_version')
  String? minVersion;
  /// 对应 JSON 键 `max_version`，可空（null 不参与序列化）。
  @JsonKey(name: 'max_version')
  String? maxVersion;
  /// 对应 JSON 键 `cipher_suites`，可空（null 不参与序列化）。
  @JsonKey(name: 'cipher_suites')
  List<String>? cipherSuites;
  /// 对应 JSON 键 `curve_preferences`，可空（null 不参与序列化）。
  @JsonKey(name: 'curve_preferences')
  List<String>? curvePreferences;
  /// 对应 JSON 键 `certificate`，可空（null 不参与序列化）。
  Object? certificate;
  /// 对应 JSON 键 `certificate_path`，可空（null 不参与序列化）。
  @JsonKey(name: 'certificate_path')
  String? certificatePath;
  /// 对应 JSON 键 `client_authentication`，可空（null 不参与序列化）。
  @JsonKey(name: 'client_authentication')
  String? clientAuthentication;
  /// 对应 JSON 键 `client_certificate`，可空（null 不参与序列化）。
  @JsonKey(name: 'client_certificate')
  Object? clientCertificate;
  /// 对应 JSON 键 `client_certificate_path`，可空（null 不参与序列化）。
  @JsonKey(name: 'client_certificate_path')
  Object? clientCertificatePath;
  /// 对应 JSON 键 `client_certificate_sha256`，可空（null 不参与序列化）。
  @JsonKey(name: 'client_certificate_sha256')
  Object? clientCertificateSha256;
  /// 对应 JSON 键 `client_certificate_public_key_sha256`，可空（null 不参与序列化）。
  @JsonKey(name: 'client_certificate_public_key_sha256')
  Object? clientCertificatePublicKeySha256;
  /// 对应 JSON 键 `key`，可空（null 不参与序列化）。
  Object? key;
  /// 对应 JSON 键 `key_path`，可空（null 不参与序列化）。
  @JsonKey(name: 'key_path')
  String? keyPath;
  /// 对应 JSON 键 `kernel_tx`，可空（null 不参与序列化）。
  @JsonKey(name: 'kernel_tx')
  bool? kernelTx;
  /// 对应 JSON 键 `kernel_rx`，可空（null 不参与序列化）。
  @JsonKey(name: 'kernel_rx')
  bool? kernelRx;
  /// 对应 JSON 键 `handshake_timeout`，可空（null 不参与序列化）。
  @JsonKey(name: 'handshake_timeout')
  String? handshakeTimeout;
  /// 对应 JSON 键 `certificate_provider`，可空（null 不参与序列化）。
  @JsonKey(name: 'certificate_provider')
  Object? certificateProvider;
  /// 对应 JSON 键 `ech`，可空（null 不参与序列化）。
  InboundECHOptions? ech;
  /// 对应 JSON 键 `reality`，可空（null 不参与序列化）。
  InboundRealityOptions? reality;

  /// 构造实例；可空字段省略时为 `null`。
  InboundTLSOptions();

  /// 从 JSON 对象反序列化为本类型。
  factory InboundTLSOptions.fromJson(Map<String, dynamic> json) =>
      _$InboundTLSOptionsFromJson(json);

  /// 序列化为 JSON 对象。
  Map<String, dynamic> toJson() => _$InboundTLSOptionsToJson(this);
}
