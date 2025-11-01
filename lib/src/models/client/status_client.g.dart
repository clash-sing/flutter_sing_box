// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'status_client.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

StatusClient _$StatusClientFromJson(Map<String, dynamic> json) => StatusClient(
  memory: (json['memory'] as num).toInt(),
  goroutines: (json['goroutines'] as num).toInt(),
  connectionsIn: (json['connectionsIn'] as num).toInt(),
  connectionsOut: (json['connectionsOut'] as num).toInt(),
  trafficAvailable: json['trafficAvailable'] as bool,
  uplink: (json['uplink'] as num).toInt(),
  downlink: (json['downlink'] as num).toInt(),
  uplinkTotal: (json['uplinkTotal'] as num).toInt(),
  downlinkTotal: (json['downlinkTotal'] as num).toInt(),
);

Map<String, dynamic> _$StatusClientToJson(StatusClient instance) =>
    <String, dynamic>{
      'memory': instance.memory,
      'goroutines': instance.goroutines,
      'connectionsIn': instance.connectionsIn,
      'connectionsOut': instance.connectionsOut,
      'trafficAvailable': instance.trafficAvailable,
      'uplink': instance.uplink,
      'downlink': instance.downlink,
      'uplinkTotal': instance.uplinkTotal,
      'downlinkTotal': instance.downlinkTotal,
    };
