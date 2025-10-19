// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'profile.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Profile _$ProfileFromJson(Map<String, dynamic> json) => Profile(
  id: (json['id'] as num).toInt(),
  userOrder: (json['userOrder'] as num).toInt(),
  name: json['name'] as String,
  typed: TypedProfile.fromJson(json['typed'] as Map<String, dynamic>),
);

Map<String, dynamic> _$ProfileToJson(Profile instance) => <String, dynamic>{
  'id': instance.id,
  'userOrder': instance.userOrder,
  'name': instance.name,
  'typed': instance.typed.toJson(),
};

TypedProfile _$TypedProfileFromJson(Map<String, dynamic> json) => TypedProfile(
  path: json['path'] as String?,
  type: $enumDecode(_$ProfileTypeEnumMap, json['type']),
  remoteURL: json['remoteURL'] as String?,
  lastUpdated: (json['lastUpdated'] as num?)?.toInt(),
  autoUpdate: json['autoUpdate'] as bool,
  autoUpdateInterval: (json['autoUpdateInterval'] as num?)?.toInt(),
);

Map<String, dynamic> _$TypedProfileToJson(TypedProfile instance) =>
    <String, dynamic>{
      'path': ?instance.path,
      'type': _$ProfileTypeEnumMap[instance.type]!,
      'remoteURL': ?instance.remoteURL,
      'lastUpdated': ?instance.lastUpdated,
      'autoUpdate': instance.autoUpdate,
      'autoUpdateInterval': ?instance.autoUpdateInterval,
    };

const _$ProfileTypeEnumMap = {
  ProfileType.local: 'local',
  ProfileType.remote: 'remote',
};
