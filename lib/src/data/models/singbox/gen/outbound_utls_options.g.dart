// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'outbound_utls_options.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OutboundUTLSOptions _$OutboundUTLSOptionsFromJson(Map<String, dynamic> json) =>
    OutboundUTLSOptions()
      ..enabled = json['enabled'] as bool?
      ..fingerprint = json['fingerprint'] as String?;

Map<String, dynamic> _$OutboundUTLSOptionsToJson(
  OutboundUTLSOptions instance,
) => <String, dynamic>{
  'enabled': ?instance.enabled,
  'fingerprint': ?instance.fingerprint,
};
