// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'log_options.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LogOptions _$LogOptionsFromJson(Map<String, dynamic> json) => LogOptions()
  ..disabled = json['disabled'] as bool?
  ..level = json['level'] as String?
  ..output = json['output'] as String?
  ..timestamp = json['timestamp'] as bool?;

Map<String, dynamic> _$LogOptionsToJson(LogOptions instance) =>
    <String, dynamic>{
      'disabled': ?instance.disabled,
      'level': ?instance.level,
      'output': ?instance.output,
      'timestamp': ?instance.timestamp,
    };
