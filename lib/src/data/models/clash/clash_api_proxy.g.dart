// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'clash_api_proxy.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ClashApiProxy _$ClashApiProxyFromJson(Map<String, dynamic> json) =>
    ClashApiProxy(
      type: json['type'] as String,
      name: json['name'] as String,
      udp: json['udp'] as bool,
      histories: (json['history'] as List<dynamic>)
          .map((e) => ClashApiProxyHistory.fromJson(e as Map<String, dynamic>))
          .toList(),
      now: json['now'] as String?,
      all: (json['all'] as List<dynamic>?)?.map((e) => e as String).toList(),
    );

Map<String, dynamic> _$ClashApiProxyToJson(ClashApiProxy instance) =>
    <String, dynamic>{
      'type': instance.type,
      'name': instance.name,
      'udp': instance.udp,
      'history': instance.histories.map((e) => e.toJson()).toList(),
      'now': ?instance.now,
      'all': ?instance.all,
    };

ClashApiProxyHistory _$ClashApiProxyHistoryFromJson(
  Map<String, dynamic> json,
) => ClashApiProxyHistory(
  time: json['time'] as String,
  delay: (json['delay'] as num).toInt(),
);

Map<String, dynamic> _$ClashApiProxyHistoryToJson(
  ClashApiProxyHistory instance,
) => <String, dynamic>{'time': instance.time, 'delay': instance.delay};
