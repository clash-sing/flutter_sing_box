// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hysteria2_realm.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Hysteria2Realm _$Hysteria2RealmFromJson(Map<String, dynamic> json) =>
    Hysteria2Realm()
      ..serverUrl = json['server_url'] as String?
      ..token = json['token'] as String?
      ..realmId = json['realm_id'] as String?
      ..stunServers = (json['stun_servers'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList()
      ..ipVersion = (json['ip_version'] as num?)?.toInt()
      ..portMapping = json['port_mapping'] == null
          ? null
          : Hysteria2RealmPortMapping.fromJson(
              json['port_mapping'] as Map<String, dynamic>,
            )
      ..httpClient = json['http_client'];

Map<String, dynamic> _$Hysteria2RealmToJson(Hysteria2Realm instance) =>
    <String, dynamic>{
      'server_url': ?instance.serverUrl,
      'token': ?instance.token,
      'realm_id': ?instance.realmId,
      'stun_servers': ?instance.stunServers,
      'ip_version': ?instance.ipVersion,
      'port_mapping': ?instance.portMapping?.toJson(),
      'http_client': ?instance.httpClient,
    };
