// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'profile.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Profile _$ProfileFromJson(Map<String, dynamic> json) => Profile(
  id: (json['id'] as num?)?.toInt() ?? 0,
  userOrder: (json['userOrder'] as num?)?.toInt() ?? 0,
  name: json['name'] as String,
  typed: TypedProfile.fromJson(json['typed'] as Map<String, dynamic>),
  userInfo: json['userInfo'] == null
      ? null
      : UserInfo.fromJson(json['userInfo'] as Map<String, dynamic>),
);

Map<String, dynamic> _$ProfileToJson(Profile instance) => <String, dynamic>{
  'id': instance.id,
  'userOrder': instance.userOrder,
  'name': instance.name,
  'typed': instance.typed.toJson(),
  'userInfo': ?instance.userInfo?.toJson(),
};

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

UserInfo _$UserInfoFromJson(Map<String, dynamic> json) => UserInfo(
  upload: (json['upload'] as num?)?.toInt(),
  download: (json['download'] as num?)?.toInt(),
  total: (json['total'] as num?)?.toInt(),
  expire: (json['expire'] as num?)?.toInt(),
);

Map<String, dynamic> _$UserInfoToJson(UserInfo instance) => <String, dynamic>{
  'upload': ?instance.upload,
  'download': ?instance.download,
  'total': ?instance.total,
  'expire': ?instance.expire,
};
