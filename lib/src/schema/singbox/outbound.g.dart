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
);

Map<String, dynamic> _$OutboundToJson(Outbound instance) => <String, dynamic>{
  'tag': instance.tag,
  'type': instance.type,
  'outbounds': instance.outbounds,
  'url': instance.url,
  'interval': instance.interval,
  'tolerance': instance.tolerance,
  'server': instance.server,
  'server_port': instance.serverPort,
  'password': instance.password,
  'tls': instance.tls,
  'server_ports': instance.serverPorts,
  'transport': instance.transport,
  'up_mbps': instance.upMbps,
  'down_mbps': instance.downMbps,
  'auth_str': instance.authStr,
  'disable_mtu_discovery': instance.disableMtuDiscovery,
};

Tls _$TlsFromJson(Map<String, dynamic> json) => Tls(
  alpn: (json['alpn'] as List<dynamic>?)?.map((e) => e as String).toList(),
  enabled: json['enabled'] as bool,
  disableSni: json['disable_sni'] as bool,
  insecure: json['insecure'] as bool,
  serverName: json['server_name'] as String?,
  utls: json['utls'] == null
      ? null
      : Utls.fromJson(json['utls'] as Map<String, dynamic>),
);

Map<String, dynamic> _$TlsToJson(Tls instance) => <String, dynamic>{
  'alpn': instance.alpn,
  'enabled': instance.enabled,
  'disable_sni': instance.disableSni,
  'insecure': instance.insecure,
  'server_name': instance.serverName,
  'utls': instance.utls,
};

Utls _$UtlsFromJson(Map<String, dynamic> json) => Utls(
  enabled: json['enabled'] as bool,
  fingerprint: json['fingerprint'] as String,
);

Map<String, dynamic> _$UtlsToJson(Utls instance) => <String, dynamic>{
  'enabled': instance.enabled,
  'fingerprint': instance.fingerprint,
};

Transport _$TransportFromJson(Map<String, dynamic> json) =>
    Transport(type: json['type'] as String);

Map<String, dynamic> _$TransportToJson(Transport instance) => <String, dynamic>{
  'type': instance.type,
};
