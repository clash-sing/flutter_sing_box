// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'clash_configs.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ClashConfigs _$ClashConfigsFromJson(Map<String, dynamic> json) => ClashConfigs(
  port: (json['port'] as num).toInt(),
  socksPort: (json['socks-port'] as num).toInt(),
  redirPort: (json['redir-port'] as num).toInt(),
  tproxyPort: (json['tproxy-port'] as num).toInt(),
  mixedPort: (json['mixed-port'] as num).toInt(),
  allowLan: json['allow-lan'] as bool,
  bindAddress: json['bind-address'] as String,
  mode: json['mode'] as String,
  modeList: (json['mode-list'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  logLevel: json['log-level'] as String,
  ipv6: json['ipv6'] as bool,
);

Map<String, dynamic> _$ClashConfigsToJson(ClashConfigs instance) =>
    <String, dynamic>{
      'port': instance.port,
      'socks-port': instance.socksPort,
      'redir-port': instance.redirPort,
      'tproxy-port': instance.tproxyPort,
      'mixed-port': instance.mixedPort,
      'allow-lan': instance.allowLan,
      'bind-address': instance.bindAddress,
      'mode': instance.mode,
      'mode-list': instance.modeList,
      'log-level': instance.logLevel,
      'ipv6': instance.ipv6,
    };
