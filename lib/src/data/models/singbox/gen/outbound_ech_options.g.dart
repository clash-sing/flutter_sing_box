// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'outbound_ech_options.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OutboundECHOptions _$OutboundECHOptionsFromJson(Map<String, dynamic> json) =>
    OutboundECHOptions()
      ..enabled = json['enabled'] as bool?
      ..config = json['config']
      ..configPath = json['config_path'] as String?
      ..queryServerName = json['query_server_name'] as String?;

Map<String, dynamic> _$OutboundECHOptionsToJson(OutboundECHOptions instance) =>
    <String, dynamic>{
      'enabled': ?instance.enabled,
      'config': ?instance.config,
      'config_path': ?instance.configPath,
      'query_server_name': ?instance.queryServerName,
    };
