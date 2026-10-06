// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'outbound_tls_options.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OutboundTLSOptions _$OutboundTLSOptionsFromJson(Map<String, dynamic> json) =>
    OutboundTLSOptions()
      ..enabled = json['enabled'] as bool?
      ..engine = json['engine'] as String?
      ..disableSni = json['disable_sni'] as bool?
      ..serverName = json['server_name'] as String?
      ..insecure = json['insecure'] as bool?
      ..alpn = json['alpn']
      ..minVersion = json['min_version'] as String?
      ..maxVersion = json['max_version'] as String?
      ..cipherSuites = (json['cipher_suites'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList()
      ..curvePreferences = (json['curve_preferences'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList()
      ..certificate = json['certificate']
      ..certificatePath = json['certificate_path'] as String?
      ..certificateSha256 = json['certificate_sha256']
      ..certificatePublicKeySha256 = json['certificate_public_key_sha256']
      ..clientCertificate = json['client_certificate']
      ..clientCertificatePath = json['client_certificate_path'] as String?
      ..clientKey = json['client_key']
      ..clientKeyPath = json['client_key_path'] as String?
      ..fragment = json['fragment'] as bool?
      ..fragmentFallbackDelay = json['fragment_fallback_delay'] as String?
      ..recordFragment = json['record_fragment'] as bool?
      ..spoof = json['spoof'] as String?
      ..spoofMethod = json['spoof_method'] as String?
      ..kernelTx = json['kernel_tx'] as bool?
      ..kernelRx = json['kernel_rx'] as bool?
      ..handshakeTimeout = json['handshake_timeout'] as String?
      ..ech = json['ech'] == null
          ? null
          : OutboundECHOptions.fromJson(json['ech'] as Map<String, dynamic>)
      ..utls = json['utls'] == null
          ? null
          : OutboundUTLSOptions.fromJson(json['utls'] as Map<String, dynamic>)
      ..reality = json['reality'] == null
          ? null
          : OutboundRealityOptions.fromJson(
              json['reality'] as Map<String, dynamic>,
            );

Map<String, dynamic> _$OutboundTLSOptionsToJson(OutboundTLSOptions instance) =>
    <String, dynamic>{
      'enabled': ?instance.enabled,
      'engine': ?instance.engine,
      'disable_sni': ?instance.disableSni,
      'server_name': ?instance.serverName,
      'insecure': ?instance.insecure,
      'alpn': ?instance.alpn,
      'min_version': ?instance.minVersion,
      'max_version': ?instance.maxVersion,
      'cipher_suites': ?instance.cipherSuites,
      'curve_preferences': ?instance.curvePreferences,
      'certificate': ?instance.certificate,
      'certificate_path': ?instance.certificatePath,
      'certificate_sha256': ?instance.certificateSha256,
      'certificate_public_key_sha256': ?instance.certificatePublicKeySha256,
      'client_certificate': ?instance.clientCertificate,
      'client_certificate_path': ?instance.clientCertificatePath,
      'client_key': ?instance.clientKey,
      'client_key_path': ?instance.clientKeyPath,
      'fragment': ?instance.fragment,
      'fragment_fallback_delay': ?instance.fragmentFallbackDelay,
      'record_fragment': ?instance.recordFragment,
      'spoof': ?instance.spoof,
      'spoof_method': ?instance.spoofMethod,
      'kernel_tx': ?instance.kernelTx,
      'kernel_rx': ?instance.kernelRx,
      'handshake_timeout': ?instance.handshakeTimeout,
      'ech': ?instance.ech?.toJson(),
      'utls': ?instance.utls?.toJson(),
      'reality': ?instance.reality?.toJson(),
    };
