// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'inbound_tls_options.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

InboundTLSOptions _$InboundTLSOptionsFromJson(Map<String, dynamic> json) =>
    InboundTLSOptions()
      ..enabled = json['enabled'] as bool?
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
      ..clientAuthentication = json['client_authentication'] as String?
      ..clientCertificate = json['client_certificate']
      ..clientCertificatePath = json['client_certificate_path']
      ..clientCertificateSha256 = json['client_certificate_sha256']
      ..clientCertificatePublicKeySha256 =
          json['client_certificate_public_key_sha256']
      ..key = json['key']
      ..keyPath = json['key_path'] as String?
      ..kernelTx = json['kernel_tx'] as bool?
      ..kernelRx = json['kernel_rx'] as bool?
      ..handshakeTimeout = json['handshake_timeout'] as String?
      ..certificateProvider = json['certificate_provider']
      ..ech = json['ech'] == null
          ? null
          : InboundECHOptions.fromJson(json['ech'] as Map<String, dynamic>)
      ..reality = json['reality'] == null
          ? null
          : InboundRealityOptions.fromJson(
              json['reality'] as Map<String, dynamic>,
            );

Map<String, dynamic> _$InboundTLSOptionsToJson(InboundTLSOptions instance) =>
    <String, dynamic>{
      'enabled': ?instance.enabled,
      'server_name': ?instance.serverName,
      'insecure': ?instance.insecure,
      'alpn': ?instance.alpn,
      'min_version': ?instance.minVersion,
      'max_version': ?instance.maxVersion,
      'cipher_suites': ?instance.cipherSuites,
      'curve_preferences': ?instance.curvePreferences,
      'certificate': ?instance.certificate,
      'certificate_path': ?instance.certificatePath,
      'client_authentication': ?instance.clientAuthentication,
      'client_certificate': ?instance.clientCertificate,
      'client_certificate_path': ?instance.clientCertificatePath,
      'client_certificate_sha256': ?instance.clientCertificateSha256,
      'client_certificate_public_key_sha256':
          ?instance.clientCertificatePublicKeySha256,
      'key': ?instance.key,
      'key_path': ?instance.keyPath,
      'kernel_tx': ?instance.kernelTx,
      'kernel_rx': ?instance.kernelRx,
      'handshake_timeout': ?instance.handshakeTimeout,
      'certificate_provider': ?instance.certificateProvider,
      'ech': ?instance.ech?.toJson(),
      'reality': ?instance.reality?.toJson(),
    };
