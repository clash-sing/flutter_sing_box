// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

User _$UserFromJson(Map<String, dynamic> json) => User()
  ..username = json['Username'] as String?
  ..password = json['Password'] as String?;

Map<String, dynamic> _$UserToJson(User instance) => <String, dynamic>{
  'Username': ?instance.username,
  'Password': ?instance.password,
};
