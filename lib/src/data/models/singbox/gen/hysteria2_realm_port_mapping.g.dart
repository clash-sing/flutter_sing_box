// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hysteria2_realm_port_mapping.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Hysteria2RealmPortMapping _$Hysteria2RealmPortMappingFromJson(
  Map<String, dynamic> json,
) => Hysteria2RealmPortMapping()
  ..enabled = json['enabled'] as bool?
  ..timeout = json['timeout'] as String?
  ..lifetime = json['lifetime'] as String?;

Map<String, dynamic> _$Hysteria2RealmPortMappingToJson(
  Hysteria2RealmPortMapping instance,
) => <String, dynamic>{
  'enabled': ?instance.enabled,
  'timeout': ?instance.timeout,
  'lifetime': ?instance.lifetime,
};
