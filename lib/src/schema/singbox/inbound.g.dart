// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'inbound.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Inbound _$InboundFromJson(Map<String, dynamic> json) => Inbound(
  tag: json['tag'] as String,
  type: json['type'] as String,
  address: (json['address'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
  mtu: (json['mtu'] as num?)?.toInt(),
  stack: json['stack'] as String?,
  autoRoute: json['auto_route'] as bool?,
  strictRoute: json['strict_route'] as bool?,
  sniff: json['sniff'] as bool,
  sniffOverrideDestination: json['sniff_override_destination'] as bool?,
  platform: json['platform'] == null
      ? null
      : Platform.fromJson(json['platform'] as Map<String, dynamic>),
  listen: json['listen'] as String?,
  listenPort: (json['listen_port'] as num?)?.toInt(),
);

Map<String, dynamic> _$InboundToJson(Inbound instance) => <String, dynamic>{
  'tag': instance.tag,
  'type': instance.type,
  'address': ?instance.address,
  'mtu': ?instance.mtu,
  'stack': ?instance.stack,
  'auto_route': ?instance.autoRoute,
  'strict_route': ?instance.strictRoute,
  'sniff': instance.sniff,
  'sniff_override_destination': ?instance.sniffOverrideDestination,
  'platform': ?instance.platform?.toJson(),
  'listen': ?instance.listen,
  'listen_port': ?instance.listenPort,
};

Platform _$PlatformFromJson(Map<String, dynamic> json) => Platform(
  httpProxy: HttpProxy.fromJson(json['http_proxy'] as Map<String, dynamic>),
);

Map<String, dynamic> _$PlatformToJson(Platform instance) => <String, dynamic>{
  'http_proxy': instance.httpProxy.toJson(),
};

HttpProxy _$HttpProxyFromJson(Map<String, dynamic> json) => HttpProxy(
  enabled: json['enabled'] as bool,
  server: json['server'] as String,
  serverPort: (json['server_port'] as num).toInt(),
);

Map<String, dynamic> _$HttpProxyToJson(HttpProxy instance) => <String, dynamic>{
  'enabled': instance.enabled,
  'server': instance.server,
  'server_port': instance.serverPort,
};
