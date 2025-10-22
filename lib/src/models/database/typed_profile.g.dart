// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'typed_profile.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TypedProfile _$TypedProfileFromJson(Map<String, dynamic> json) => TypedProfile(
  type: $enumDecode(_$ProfileTypeEnumMap, json['type']),
  path: json['path'] as String,
  lastUpdated: (json['lastUpdated'] as num).toInt(),
  autoUpdate: json['autoUpdate'] as bool,
  autoUpdateInterval: (json['autoUpdateInterval'] as num?)?.toInt(),
  remoteUrl: json['remoteUrl'] as String?,
  webPageUrl: json['webPageUrl'] as String?,
);

Map<String, dynamic> _$TypedProfileToJson(TypedProfile instance) =>
    <String, dynamic>{
      'type': _$ProfileTypeEnumMap[instance.type]!,
      'path': instance.path,
      'lastUpdated': instance.lastUpdated,
      'autoUpdate': instance.autoUpdate,
      'autoUpdateInterval': ?instance.autoUpdateInterval,
      'remoteUrl': ?instance.remoteUrl,
      'webPageUrl': ?instance.webPageUrl,
    };

const _$ProfileTypeEnumMap = {
  ProfileType.local: 'local',
  ProfileType.remote: 'remote',
};
