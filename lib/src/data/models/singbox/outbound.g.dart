// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'outbound.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Outbound _$OutboundFromJson(Map<String, dynamic> json) => Outbound(
  tag: json['tag'] as String,
  type: json['type'] as String,
  outbounds: (json['outbounds'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
  url: json['url'] as String?,
  interval: json['interval'] as String?,
  tolerance: (json['tolerance'] as num?)?.toInt(),
  server: json['server'] as String?,
  serverPort: (json['server_port'] as num?)?.toInt(),
  password: json['password'] as String?,
  uuid: json['uuid'] as String?,
  security: json['security'] as String?,
  alterId: (json['alter_id'] as num?)?.toInt(),
  packetEncoding: json['packet_encoding'] as String?,
  tls: json['tls'] == null
      ? null
      : Tls.fromJson(json['tls'] as Map<String, dynamic>),
  serverPorts: (json['server_ports'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
  transport: json['transport'] == null
      ? null
      : Transport.fromJson(json['transport'] as Map<String, dynamic>),
  upMbps: (json['up_mbps'] as num?)?.toInt(),
  downMbps: (json['down_mbps'] as num?)?.toInt(),
  authStr: json['auth_str'] as String?,
  disableMtuDiscovery: json['disable_mtu_discovery'] as bool?,
  multiplex: json['multiplex'] == null
      ? null
      : Multiplex.fromJson(json['multiplex'] as Map<String, dynamic>),
)..defaultTag = json['default'] as String?;

Map<String, dynamic> _$OutboundToJson(Outbound instance) => <String, dynamic>{
  'tag': instance.tag,
  'type': instance.type,
  'outbounds': ?instance.outbounds,
  'default': ?instance.defaultTag,
  'url': ?instance.url,
  'interval': ?instance.interval,
  'tolerance': ?instance.tolerance,
  'server': ?instance.server,
  'server_port': ?instance.serverPort,
  'password': ?instance.password,
  'uuid': ?instance.uuid,
  'security': ?instance.security,
  'alter_id': ?instance.alterId,
  'packet_encoding': ?instance.packetEncoding,
  'tls': ?instance.tls?.toJson(),
  'server_ports': ?instance.serverPorts,
  'transport': ?instance.transport?.toJson(),
  'up_mbps': ?instance.upMbps,
  'down_mbps': ?instance.downMbps,
  'auth_str': ?instance.authStr,
  'disable_mtu_discovery': ?instance.disableMtuDiscovery,
  'multiplex': ?instance.multiplex?.toJson(),
};

Tls _$TlsFromJson(Map<String, dynamic> json) => Tls(
  alpn: (json['alpn'] as List<dynamic>?)?.map((e) => e as String).toList(),
  enabled: json['enabled'] as bool,
  disableSni: json['disable_sni'] as bool?,
  insecure: json['insecure'] as bool,
  serverName: json['server_name'] as String?,
  utls: json['utls'] == null
      ? null
      : Utls.fromJson(json['utls'] as Map<String, dynamic>),
);

Map<String, dynamic> _$TlsToJson(Tls instance) => <String, dynamic>{
  'alpn': ?instance.alpn,
  'enabled': instance.enabled,
  'disable_sni': ?instance.disableSni,
  'insecure': instance.insecure,
  'server_name': ?instance.serverName,
  'utls': ?instance.utls?.toJson(),
};

Utls _$UtlsFromJson(Map<String, dynamic> json) => Utls(
  enabled: json['enabled'] as bool,
  fingerprint: json['fingerprint'] as String,
);

Map<String, dynamic> _$UtlsToJson(Utls instance) => <String, dynamic>{
  'enabled': instance.enabled,
  'fingerprint': instance.fingerprint,
};

Transport _$TransportFromJson(Map<String, dynamic> json) => Transport(
  type: json['type'] as String,
  path: json['path'] as String?,
  headers: json['headers'] as Map<String, dynamic>?,
  maxEarlyData: (json['max_early_data'] as num?)?.toInt(),
  earlyDataHeaderName: json['early_data_header_name'] as String?,
);

Map<String, dynamic> _$TransportToJson(Transport instance) => <String, dynamic>{
  'type': instance.type,
  'path': ?instance.path,
  'headers': ?instance.headers,
  'max_early_data': ?instance.maxEarlyData,
  'early_data_header_name': ?instance.earlyDataHeaderName,
};

Multiplex _$MultiplexFromJson(Map<String, dynamic> json) =>
    Multiplex(enabled: json['enabled'] as bool);

Map<String, dynamic> _$MultiplexToJson(Multiplex instance) => <String, dynamic>{
  'enabled': instance.enabled,
};
