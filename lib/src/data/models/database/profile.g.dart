// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'profile.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Profile _$ProfileFromJson(Map<String, dynamic> json) => Profile(
  id: (json['id'] as num).toInt(),
  order: (json['order'] as num).toInt(),
  name: json['name'] as String,
  typed: TypedProfile.fromJson(json['typed'] as Map<String, dynamic>),
  userInfo: json['userInfo'] == null
      ? null
      : UserInfo.fromJson(json['userInfo'] as Map<String, dynamic>),
);

Map<String, dynamic> _$ProfileToJson(Profile instance) => <String, dynamic>{
  'id': instance.id,
  'order': instance.order,
  'name': instance.name,
  'typed': instance.typed.toJson(),
  'userInfo': ?instance.userInfo?.toJson(),
};
