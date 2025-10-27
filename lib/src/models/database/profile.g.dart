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
  selectedGroup: json['selectedGroup'] as String?,
  selectedOutbound: json['selectedOutbound'] as String?,
  userInfo: json['userInfo'] == null
      ? null
      : UserInfo.fromJson(json['userInfo'] as Map<String, dynamic>),
);

Map<String, dynamic> _$ProfileToJson(Profile instance) => <String, dynamic>{
  'id': instance.id,
  'userOrder': instance.userOrder,
  'name': instance.name,
  'typed': instance.typed.toJson(),
  'selectedGroup': ?instance.selectedGroup,
  'selectedOutbound': ?instance.selectedOutbound,
  'userInfo': ?instance.userInfo?.toJson(),
};
