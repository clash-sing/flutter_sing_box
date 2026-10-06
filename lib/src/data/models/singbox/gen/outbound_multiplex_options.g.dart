// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'outbound_multiplex_options.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OutboundMultiplexOptions _$OutboundMultiplexOptionsFromJson(
  Map<String, dynamic> json,
) => OutboundMultiplexOptions()
  ..enabled = json['enabled'] as bool?
  ..protocol = json['protocol'] as String?
  ..maxConnections = (json['max_connections'] as num?)?.toInt()
  ..minStreams = (json['min_streams'] as num?)?.toInt()
  ..maxStreams = (json['max_streams'] as num?)?.toInt()
  ..padding = json['padding'] as bool?
  ..brutal = json['brutal'] == null
      ? null
      : BrutalOptions.fromJson(json['brutal'] as Map<String, dynamic>);

Map<String, dynamic> _$OutboundMultiplexOptionsToJson(
  OutboundMultiplexOptions instance,
) => <String, dynamic>{
  'enabled': ?instance.enabled,
  'protocol': ?instance.protocol,
  'max_connections': ?instance.maxConnections,
  'min_streams': ?instance.minStreams,
  'max_streams': ?instance.maxStreams,
  'padding': ?instance.padding,
  'brutal': ?instance.brutal?.toJson(),
};
