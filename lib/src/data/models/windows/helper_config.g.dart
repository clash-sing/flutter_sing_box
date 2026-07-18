// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'helper_config.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

HelperConfig _$HelperConfigFromJson(Map<String, dynamic> json) => HelperConfig(
  helperServiceName: json['helperName'] as String,
  helperServiceDisplayName: json['helperDisplayName'] as String,
  helperServiceDescription: json['helperDescription'] as String,
  singBoxExecute: json['execute'] as String,
  singBoxConfig: json['config'] as String,
  helperPort: (json['port'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$HelperConfigToJson(HelperConfig instance) =>
    <String, dynamic>{
      'helperName': instance.helperServiceName,
      'helperDisplayName': instance.helperServiceDisplayName,
      'helperDescription': instance.helperServiceDescription,
      'execute': instance.singBoxExecute,
      'config': instance.singBoxConfig,
      'port': instance.helperPort,
    };
