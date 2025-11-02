// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'client_clash_mode.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ClientClashMode _$ClientClashModeFromJson(Map<String, dynamic> json) =>
    ClientClashMode(
      modes: (json['modes'] as List<dynamic>).map((e) => e as String).toList(),
      currentMode: json['currentMode'] as String,
    );

Map<String, dynamic> _$ClientClashModeToJson(ClientClashMode instance) =>
    <String, dynamic>{
      'modes': instance.modes,
      'currentMode': instance.currentMode,
    };
