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
  defaultTag: json['default'] as String?,
  url: json['url'] as String?,
  interval: json['interval'] as String?,
  tolerance: (json['tolerance'] as num?)?.toInt(),
  server: json['server'] as String?,
  serverPort: (json['server_port'] as num?)?.toInt(),
  username: json['username'] as String?,
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
  zeroRttHandshake: json['zero_rtt_handshake'] as bool?,
  congestionControl: json['congestion_control'] as String?,
  udpRelayMode: json['udp_relay_mode'] as String?,
  udpOverStream: json['udp_over_stream'] as bool?,
  heartbeat: json['heartbeat'] as String?,
  method: json['method'] as String?,
  network: json['network'] as String?,
  quic: json['quic'] as bool?,
  quicCongestionControl: json['quic_congestion_control'] as String?,
  udpOverTcp: json['udp_over_tcp'],
  interruptExistConnections: json['interrupt_exist_connections'] as bool?,
);

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
  'username': ?instance.username,
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
  'zero_rtt_handshake': ?instance.zeroRttHandshake,
  'congestion_control': ?instance.congestionControl,
  'udp_relay_mode': ?instance.udpRelayMode,
  'udp_over_stream': ?instance.udpOverStream,
  'heartbeat': ?instance.heartbeat,
  'method': ?instance.method,
  'network': ?instance.network,
  'quic': ?instance.quic,
  'quic_congestion_control': ?instance.quicCongestionControl,
  'udp_over_tcp': ?instance.udpOverTcp,
  'interrupt_exist_connections': ?instance.interruptExistConnections,
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
    Multiplex(enabled: json['enabled'] as bool?);

Map<String, dynamic> _$MultiplexToJson(Multiplex instance) => <String, dynamic>{
  'enabled': ?instance.enabled,
};
