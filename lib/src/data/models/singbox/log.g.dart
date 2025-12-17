// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'log.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Log _$LogFromJson(Map<String, dynamic> json) => Log(
  disabled: json['disabled'] as bool,
  level: json['level'] as String,
  output: json['output'] as String?,
  timestamp: json['timestamp'] as bool,
);

Map<String, dynamic> _$LogToJson(Log instance) => <String, dynamic>{
  'disabled': instance.disabled,
  'level': instance.level,
  'output': ?instance.output,
  'timestamp': instance.timestamp,
};
