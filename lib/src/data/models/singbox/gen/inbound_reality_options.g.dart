// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'inbound_reality_options.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

InboundRealityOptions _$InboundRealityOptionsFromJson(
  Map<String, dynamic> json,
) => InboundRealityOptions()
  ..enabled = json['enabled'] as bool?
  ..handshake = json['handshake'] == null
      ? null
      : InboundRealityHandshakeOptions.fromJson(
          json['handshake'] as Map<String, dynamic>,
        )
  ..privateKey = json['private_key'] as String?
  ..shortId = json['short_id']
  ..maxTimeDifference = json['max_time_difference'] as String?;

Map<String, dynamic> _$InboundRealityOptionsToJson(
  InboundRealityOptions instance,
) => <String, dynamic>{
  'enabled': ?instance.enabled,
  'handshake': ?instance.handshake?.toJson(),
  'private_key': ?instance.privateKey,
  'short_id': ?instance.shortId,
  'max_time_difference': ?instance.maxTimeDifference,
};
