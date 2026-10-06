// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'outbound_reality_options.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OutboundRealityOptions _$OutboundRealityOptionsFromJson(
  Map<String, dynamic> json,
) => OutboundRealityOptions()
  ..enabled = json['enabled'] as bool?
  ..publicKey = json['public_key'] as String?
  ..shortId = json['short_id'] as String?;

Map<String, dynamic> _$OutboundRealityOptionsToJson(
  OutboundRealityOptions instance,
) => <String, dynamic>{
  'enabled': ?instance.enabled,
  'public_key': ?instance.publicKey,
  'short_id': ?instance.shortId,
};
