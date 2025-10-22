// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'typed_profile.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TypedProfile _$TypedProfileFromJson(Map<String, dynamic> json) => TypedProfile(
  path: json['path'] as String?,
  type: $enumDecode(_$ProfileTypeEnumMap, json['type']),
  remoteUrl: json['remoteUrl'] as String?,
  webPageUrl: json['webPageUrl'] as String?,
  lastUpdated: (json['lastUpdated'] as num?)?.toInt(),
  autoUpdate: json['autoUpdate'] as bool,
  autoUpdateInterval: (json['autoUpdateInterval'] as num?)?.toInt(),
);

Map<String, dynamic> _$TypedProfileToJson(TypedProfile instance) =>
    <String, dynamic>{
      'path': ?instance.path,
      'type': _$ProfileTypeEnumMap[instance.type]!,
      'remoteUrl': ?instance.remoteUrl,
      'webPageUrl': ?instance.webPageUrl,
      'lastUpdated': ?instance.lastUpdated,
      'autoUpdate': instance.autoUpdate,
      'autoUpdateInterval': ?instance.autoUpdateInterval,
    };

const _$ProfileTypeEnumMap = {
  ProfileType.local: 'local',
  ProfileType.remote: 'remote',
};
