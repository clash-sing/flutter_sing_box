// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'inbound_ech_options.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

InboundECHOptions _$InboundECHOptionsFromJson(Map<String, dynamic> json) =>
    InboundECHOptions()
      ..enabled = json['enabled'] as bool?
      ..key = json['key']
      ..keyPath = json['key_path'] as String?;

Map<String, dynamic> _$InboundECHOptionsToJson(InboundECHOptions instance) =>
    <String, dynamic>{
      'enabled': ?instance.enabled,
      'key': ?instance.key,
      'key_path': ?instance.keyPath,
    };
