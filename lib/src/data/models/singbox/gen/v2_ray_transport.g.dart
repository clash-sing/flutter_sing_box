// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'v2_ray_transport.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

V2RayTransport _$V2RayTransportFromJson(Map<String, dynamic> json) =>
    V2RayTransport(type: json['type'] as String)
      ..host = json['host']
      ..path = json['path'] as String?
      ..method = json['method'] as String?
      ..headers = json['headers'] == null
          ? null
          : HTTPHeader.fromJson(json['headers'] as Map<String, dynamic>)
      ..idleTimeout = json['idle_timeout'] as String?
      ..pingTimeout = json['ping_timeout'] as String?
      ..maxEarlyData = (json['max_early_data'] as num?)?.toInt()
      ..earlyDataHeaderName = json['early_data_header_name'] as String?
      ..serviceName = json['service_name'] as String?
      ..permitWithoutStream = json['permit_without_stream'] as bool?;

Map<String, dynamic> _$V2RayTransportToJson(V2RayTransport instance) =>
    <String, dynamic>{
      'type': instance.type,
      'host': ?instance.host,
      'path': ?instance.path,
      'method': ?instance.method,
      'headers': ?instance.headers?.toJson(),
      'idle_timeout': ?instance.idleTimeout,
      'ping_timeout': ?instance.pingTimeout,
      'max_early_data': ?instance.maxEarlyData,
      'early_data_header_name': ?instance.earlyDataHeaderName,
      'service_name': ?instance.serviceName,
      'permit_without_stream': ?instance.permitWithoutStream,
    };
