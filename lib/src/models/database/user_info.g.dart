// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_info.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

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
