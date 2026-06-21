// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tls.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Tls _$TlsFromJson(Map<String, dynamic> json) => Tls(
  alpn: (json['alpn'] as List<dynamic>?)?.map((e) => e as String).toList(),
  enabled: json['enabled'] as bool?,
  disableSni: json['disable_sni'] as bool?,
  insecure: json['insecure'] as bool?,
  serverName: json['server_name'] as String?,
  utls: json['utls'] == null
      ? null
      : Utls.fromJson(json['utls'] as Map<String, dynamic>),
);

Map<String, dynamic> _$TlsToJson(Tls instance) => <String, dynamic>{
  'alpn': ?instance.alpn,
  'enabled': ?instance.enabled,
  'disable_sni': ?instance.disableSni,
  'insecure': ?instance.insecure,
  'server_name': ?instance.serverName,
  'utls': ?instance.utls?.toJson(),
};

Utls _$UtlsFromJson(Map<String, dynamic> json) => Utls(
  enabled: json['enabled'] as bool?,
  fingerprint: json['fingerprint'] as String?,
);

Map<String, dynamic> _$UtlsToJson(Utls instance) => <String, dynamic>{
  'enabled': ?instance.enabled,
  'fingerprint': ?instance.fingerprint,
};
