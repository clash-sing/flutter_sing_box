// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'client_log.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ClientLog _$ClientLogFromJson(Map<String, dynamic> json) => ClientLog(
  level: (json['level'] as num).toInt(),
  message: json['message'] as String,
);

Map<String, dynamic> _$ClientLogToJson(ClientLog instance) => <String, dynamic>{
  'level': instance.level,
  'message': instance.message,
};
