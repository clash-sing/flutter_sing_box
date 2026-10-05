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
  network: json['network'],
  quic: json['quic'] as bool?,
  quicCongestionControl: json['quic_congestion_control'] as String?,
  udpOverTcp: json['udp_over_tcp'],
  interruptExistConnections: json['interrupt_exist_connections'] as bool?,
  domainResolver: json['domain_resolver'],
  hopInterval: json['hop_interval'] as String?,
  hopIntervalMax: json['hop_interval_max'] as String?,
  bbrProfile: json['bbr_profile'] as String?,
  disableChromeParrot: json['disable_chrome_parrot'] as bool?,
  realm: json['realm'] == null
      ? null
      : Realm.fromJson(json['realm'] as Map<String, dynamic>),
  obfs: json['obfs'],
  idleSessionCheckInterval: json['idle_session_check_interval'] as String?,
  idleSessionTimeout: json['idle_session_timeout'] as String?,
  minIdleSession: (json['min_idle_session'] as num?)?.toInt(),
  clientMetadata: json['client_metadata'] as String?,
  globalPadding: json['global_padding'] as bool?,
  authenticatedLength: json['authenticated_length'] as bool?,
  flow: json['flow'] as String?,
  plugin: json['plugin'] as String?,
  pluginOpts: json['plugin_opts'] as String?,
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
  'domain_resolver': ?instance.domainResolver,
  'hop_interval': ?instance.hopInterval,
  'hop_interval_max': ?instance.hopIntervalMax,
  'bbr_profile': ?instance.bbrProfile,
  'disable_chrome_parrot': ?instance.disableChromeParrot,
  'realm': ?instance.realm?.toJson(),
  'obfs': ?instance.obfs,
  'idle_session_check_interval': ?instance.idleSessionCheckInterval,
  'idle_session_timeout': ?instance.idleSessionTimeout,
  'min_idle_session': ?instance.minIdleSession,
  'client_metadata': ?instance.clientMetadata,
  'global_padding': ?instance.globalPadding,
  'authenticated_length': ?instance.authenticatedLength,
  'flow': ?instance.flow,
  'plugin': ?instance.plugin,
  'plugin_opts': ?instance.pluginOpts,
};

Transport _$TransportFromJson(Map<String, dynamic> json) => Transport(
  type: json['type'] as String,
  host: json['host'],
  serviceName: json['service_name'] as String?,
  path: json['path'] as String?,
  method: json['method'] as String?,
  headers: json['headers'] as Map<String, dynamic>?,
  idleTimeout: json['idle_timeout'] as String?,
  pingTimeout: json['ping_timeout'] as String?,
  maxEarlyData: (json['max_early_data'] as num?)?.toInt(),
  earlyDataHeaderName: json['early_data_header_name'] as String?,
  permitWithoutStream: json['permit_without_stream'] as bool?,
);

Map<String, dynamic> _$TransportToJson(Transport instance) => <String, dynamic>{
  'type': instance.type,
  'host': ?instance.host,
  'service_name': ?instance.serviceName,
  'path': ?instance.path,
  'method': ?instance.method,
  'headers': ?instance.headers,
  'idle_timeout': ?instance.idleTimeout,
  'ping_timeout': ?instance.pingTimeout,
  'max_early_data': ?instance.maxEarlyData,
  'early_data_header_name': ?instance.earlyDataHeaderName,
  'permit_without_stream': ?instance.permitWithoutStream,
};

Multiplex _$MultiplexFromJson(Map<String, dynamic> json) =>
    Multiplex(enabled: json['enabled'] as bool?);

Map<String, dynamic> _$MultiplexToJson(Multiplex instance) => <String, dynamic>{
  'enabled': ?instance.enabled,
};

Realm _$RealmFromJson(Map<String, dynamic> json) => Realm(
  serverUrl: json['server_url'] as String?,
  token: json['token'] as String?,
  realmId: json['realm_id'] as String?,
  stunServers: json['stun_servers'],
  ipVersion: (json['ip_version'] as num?)?.toInt(),
  portMapping: json['port_mapping'] == null
      ? null
      : RealmPortMapping.fromJson(json['port_mapping'] as Map<String, dynamic>),
  httpClient: json['http_client'],
);

Map<String, dynamic> _$RealmToJson(Realm instance) => <String, dynamic>{
  'server_url': ?instance.serverUrl,
  'token': ?instance.token,
  'realm_id': ?instance.realmId,
  'stun_servers': ?instance.stunServers,
  'ip_version': ?instance.ipVersion,
  'port_mapping': ?instance.portMapping?.toJson(),
  'http_client': ?instance.httpClient,
};

RealmPortMapping _$RealmPortMappingFromJson(Map<String, dynamic> json) =>
    RealmPortMapping(
      enabled: json['enabled'] as bool?,
      timeout: json['timeout'] as String?,
      lifetime: json['lifetime'] as String?,
    );

Map<String, dynamic> _$RealmPortMappingToJson(RealmPortMapping instance) =>
    <String, dynamic>{
      'enabled': ?instance.enabled,
      'timeout': ?instance.timeout,
      'lifetime': ?instance.lifetime,
    };

Obfs _$ObfsFromJson(Map<String, dynamic> json) => Obfs(
  type: json['type'] as String,
  password: json['password'] as String?,
  minPacketSize: (json['min_packet_size'] as num?)?.toInt(),
  maxPacketSize: (json['max_packet_size'] as num?)?.toInt(),
);

Map<String, dynamic> _$ObfsToJson(Obfs instance) => <String, dynamic>{
  'type': instance.type,
  'password': ?instance.password,
  'min_packet_size': ?instance.minPacketSize,
  'max_packet_size': ?instance.maxPacketSize,
};

UdpOverTcp _$UdpOverTcpFromJson(Map<String, dynamic> json) => UdpOverTcp(
  enabled: json['enabled'] as bool?,
  version: (json['version'] as num?)?.toInt(),
);

Map<String, dynamic> _$UdpOverTcpToJson(UdpOverTcp instance) =>
    <String, dynamic>{
      'enabled': ?instance.enabled,
      'version': ?instance.version,
    };
