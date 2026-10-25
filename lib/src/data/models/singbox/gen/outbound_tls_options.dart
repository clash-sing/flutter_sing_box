// 本文件由 tool/gen_models.dart 生成，勿手改。
import 'package:json_annotation/json_annotation.dart';

import 'outbound_ech_options.dart';
import 'outbound_reality_options.dart';
import 'outbound_utls_options.dart';

part 'outbound_tls_options.g.dart';

/// 由官方 JSON schema `$defs/OutboundTLSOptions` 定义的配置模型。
@JsonSerializable(explicitToJson: true, includeIfNull: false)
class OutboundTLSOptions {
  /// 对应 JSON 键 `enabled`，可空（null 不参与序列化）。
  bool? enabled;
  /// 对应 JSON 键 `engine`，可空（null 不参与序列化）。
  String? engine;
  /// 对应 JSON 键 `disable_sni`，可空（null 不参与序列化）。
  @JsonKey(name: 'disable_sni')
  bool? disableSni;
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
  /// 对应 JSON 键 `certificate_sha256`，可空（null 不参与序列化）。
  @JsonKey(name: 'certificate_sha256')
  Object? certificateSha256;
  /// 对应 JSON 键 `certificate_public_key_sha256`，可空（null 不参与序列化）。
  @JsonKey(name: 'certificate_public_key_sha256')
  Object? certificatePublicKeySha256;
  /// 对应 JSON 键 `client_certificate`，可空（null 不参与序列化）。
  @JsonKey(name: 'client_certificate')
  Object? clientCertificate;
  /// 对应 JSON 键 `client_certificate_path`，可空（null 不参与序列化）。
  @JsonKey(name: 'client_certificate_path')
  String? clientCertificatePath;
  /// 对应 JSON 键 `client_key`，可空（null 不参与序列化）。
  @JsonKey(name: 'client_key')
  Object? clientKey;
  /// 对应 JSON 键 `client_key_path`，可空（null 不参与序列化）。
  @JsonKey(name: 'client_key_path')
  String? clientKeyPath;
  /// 对应 JSON 键 `fragment`，可空（null 不参与序列化）。
  bool? fragment;
  /// 对应 JSON 键 `fragment_fallback_delay`，可空（null 不参与序列化）。
  @JsonKey(name: 'fragment_fallback_delay')
  String? fragmentFallbackDelay;
  /// 对应 JSON 键 `record_fragment`，可空（null 不参与序列化）。
  @JsonKey(name: 'record_fragment')
  bool? recordFragment;
  /// 对应 JSON 键 `spoof`，可空（null 不参与序列化）。
  String? spoof;
  /// 对应 JSON 键 `spoof_method`，可空（null 不参与序列化）。
  @JsonKey(name: 'spoof_method')
  String? spoofMethod;
  /// 对应 JSON 键 `kernel_tx`，可空（null 不参与序列化）。
  @JsonKey(name: 'kernel_tx')
  bool? kernelTx;
  /// 对应 JSON 键 `kernel_rx`，可空（null 不参与序列化）。
  @JsonKey(name: 'kernel_rx')
  bool? kernelRx;
  /// 对应 JSON 键 `handshake_timeout`，可空（null 不参与序列化）。
  @JsonKey(name: 'handshake_timeout')
  String? handshakeTimeout;
  /// 对应 JSON 键 `ech`，可空（null 不参与序列化）。
  OutboundECHOptions? ech;
  /// 对应 JSON 键 `utls`，可空（null 不参与序列化）。
  OutboundUTLSOptions? utls;
  /// 对应 JSON 键 `reality`，可空（null 不参与序列化）。
  OutboundRealityOptions? reality;

  /// 构造实例；可空字段省略时为 `null`。
  OutboundTLSOptions();

  /// 从 JSON 对象反序列化为本类型。
  factory OutboundTLSOptions.fromJson(Map<String, dynamic> json) =>
      _$OutboundTLSOptionsFromJson(json);

  /// 序列化为 JSON 对象。
  Map<String, dynamic> toJson() => _$OutboundTLSOptionsToJson(this);
}
