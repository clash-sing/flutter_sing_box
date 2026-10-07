// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'clash_proxy.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ClashProxy _$ClashProxyFromJson(Map<String, dynamic> json) => ClashProxy(
  name: json['name'] as String,
  type: json['type'] as String,
  server: json['server'] as String?,
  port: (json['port'] as num?)?.toInt(),
  ports: json['ports'] as String?,
  username: json['username'] as String?,
  password: json['password'] as String?,
  skipCertVerify: json['skip-cert-verify'] as bool?,
  clientFingerprint: json['client-fingerprint'] as String?,
  udp: json['udp'] as bool?,
  tfo: json['tfo'] as bool?,
  sni: json['sni'] as String?,
  servername: json['servername'] as String?,
  network: json['network'] as String?,
  up: (json['up'] as num?)?.toInt(),
  down: (json['down'] as num?)?.toInt(),
  authStr: json['auth_str'] as String?,
  alpn: (json['alpn'] as List<dynamic>?)?.map((e) => e as String).toList(),
  protocol: json['protocol'] as String?,
  fastOpen: json['fast-open'] as bool?,
  disableMtuDiscovery: json['disable_mtu_discovery'] as bool?,
  uuid: json['uuid'] as String?,
  reduceRtt: json['reduce-rtt'] as bool?,
  congestionController: json['congestion-controller'] as String?,
  udpRelayMode: json['udp-relay-mode'] as String?,
  bbrProfile: json['bbr-profile'] as String?,
  obfs: json['obfs'] as String?,
  obfsPassword: json['obfs-password'] as String?,
  obfsMinPacketSize: (json['obfs-min-packet-size'] as num?)?.toInt(),
  obfsMaxPacketSize: (json['obfs-max-packet-size'] as num?)?.toInt(),
  fingerprint: json['fingerprint'] as String?,
  idleSessionCheckInterval: (json['idle-session-check-interval'] as num?)
      ?.toInt(),
  idleSessionTimeout: (json['idle-session-timeout'] as num?)?.toInt(),
  minIdleSession: (json['min-idle-session'] as num?)?.toInt(),
  clientMetadata: json['client-metadata'] as String?,
  disableSni: json['disable-sni'] as bool?,
  heartbeatInterval: (json['heartbeat-interval'] as num?)?.toInt(),
  tls: json['tls'] as bool?,
  cipher: json['cipher'] as String?,
  alterId: (json['alterId'] as num?)?.toInt(),
  globalPadding: json['global-padding'] as bool?,
  authenticatedLength: json['authenticated-length'] as bool?,
  flow: json['flow'] as String?,
  plugin: json['plugin'] as String?,
  pluginOpts: json['plugin-opts'] == null
      ? null
      : PluginOpts.fromJson(json['plugin-opts'] as Map<String, dynamic>),
  udpOverTcp: json['udp-over-tcp'] as bool?,
  udpOverTcpVersion: (json['udp-over-tcp-version'] as num?)?.toInt(),
  realmOpts: json['realm-opts'] == null
      ? null
      : RealmOpts.fromJson(json['realm-opts'] as Map<String, dynamic>),
  realityOpts: json['reality-opts'] == null
      ? null
      : RealityOpts.fromJson(json['reality-opts'] as Map<String, dynamic>),
  wsOpts: json['ws-opts'] == null
      ? null
      : WsOpts.fromJson(json['ws-opts'] as Map<String, dynamic>),
  grpcOpts: json['grpc-opts'] == null
      ? null
      : GrpcOpts.fromJson(json['grpc-opts'] as Map<String, dynamic>),
  httpOpts: json['http-opts'] == null
      ? null
      : HttpOpts.fromJson(json['http-opts'] as Map<String, dynamic>),
  h2Opts: json['h2-opts'] == null
      ? null
      : H2Opts.fromJson(json['h2-opts'] as Map<String, dynamic>),
)..packetEncoding = json['packet-encoding'] as String?;

Map<String, dynamic> _$ClashProxyToJson(ClashProxy instance) =>
    <String, dynamic>{
      'name': instance.name,
      'type': instance.type,
      'server': ?instance.server,
      'port': ?instance.port,
      'ports': ?instance.ports,
      'username': ?instance.username,
      'password': ?instance.password,
      'skip-cert-verify': ?instance.skipCertVerify,
      'client-fingerprint': ?instance.clientFingerprint,
      'udp': ?instance.udp,
      'tfo': ?instance.tfo,
      'sni': ?instance.sni,
      'servername': ?instance.servername,
      'network': ?instance.network,
      'up': ?instance.up,
      'down': ?instance.down,
      'auth_str': ?instance.authStr,
      'alpn': ?instance.alpn,
      'protocol': ?instance.protocol,
      'fast-open': ?instance.fastOpen,
      'disable_mtu_discovery': ?instance.disableMtuDiscovery,
      'uuid': ?instance.uuid,
      'reduce-rtt': ?instance.reduceRtt,
      'congestion-controller': ?instance.congestionController,
      'udp-relay-mode': ?instance.udpRelayMode,
      'bbr-profile': ?instance.bbrProfile,
      'obfs': ?instance.obfs,
      'obfs-password': ?instance.obfsPassword,
      'obfs-min-packet-size': ?instance.obfsMinPacketSize,
      'obfs-max-packet-size': ?instance.obfsMaxPacketSize,
      'fingerprint': ?instance.fingerprint,
      'idle-session-check-interval': ?instance.idleSessionCheckInterval,
      'idle-session-timeout': ?instance.idleSessionTimeout,
      'min-idle-session': ?instance.minIdleSession,
      'client-metadata': ?instance.clientMetadata,
      'disable-sni': ?instance.disableSni,
      'heartbeat-interval': ?instance.heartbeatInterval,
      'tls': ?instance.tls,
      'cipher': ?instance.cipher,
      'alterId': ?instance.alterId,
      'global-padding': ?instance.globalPadding,
      'authenticated-length': ?instance.authenticatedLength,
      'packet-encoding': ?instance.packetEncoding,
      'flow': ?instance.flow,
      'plugin': ?instance.plugin,
      'plugin-opts': ?instance.pluginOpts?.toJson(),
      'udp-over-tcp': ?instance.udpOverTcp,
      'udp-over-tcp-version': ?instance.udpOverTcpVersion,
      'realm-opts': ?instance.realmOpts?.toJson(),
      'reality-opts': ?instance.realityOpts?.toJson(),
      'ws-opts': ?instance.wsOpts?.toJson(),
      'grpc-opts': ?instance.grpcOpts?.toJson(),
      'http-opts': ?instance.httpOpts?.toJson(),
      'h2-opts': ?instance.h2Opts?.toJson(),
    };

PluginOpts _$PluginOptsFromJson(Map<String, dynamic> json) =>
    PluginOpts(mode: json['mode'] as String?, host: json['host'] as String?);

Map<String, dynamic> _$PluginOptsToJson(PluginOpts instance) =>
    <String, dynamic>{'mode': ?instance.mode, 'host': ?instance.host};

RealmOpts _$RealmOptsFromJson(Map<String, dynamic> json) => RealmOpts(
  enable: json['enable'] as bool?,
  serverUrl: json['server-url'] as String?,
  token: json['token'] as String?,
  realmId: json['realm-id'] as String?,
  stunServers: (json['stun-servers'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
);

Map<String, dynamic> _$RealmOptsToJson(RealmOpts instance) => <String, dynamic>{
  'enable': ?instance.enable,
  'server-url': ?instance.serverUrl,
  'token': ?instance.token,
  'realm-id': ?instance.realmId,
  'stun-servers': ?instance.stunServers,
};

RealityOpts _$RealityOptsFromJson(Map<String, dynamic> json) => RealityOpts(
  publicKey: json['public-key'] as String?,
  shortId: json['short-id'] as String?,
);

Map<String, dynamic> _$RealityOptsToJson(RealityOpts instance) =>
    <String, dynamic>{
      'public-key': ?instance.publicKey,
      'short-id': ?instance.shortId,
    };

WsOpts _$WsOptsFromJson(Map<String, dynamic> json) => WsOpts(
  path: json['path'] as String?,
  headers: json['headers'] as Map<String, dynamic>?,
  maxEarlyData: (json['max-early-data'] as num?)?.toInt(),
  earlyDataHeaderName: json['early-data-header-name'] as String?,
  v2rayHttpUpgrade: json['v2ray-http-upgrade'] as bool?,
);

Map<String, dynamic> _$WsOptsToJson(WsOpts instance) => <String, dynamic>{
  'path': ?instance.path,
  'headers': ?instance.headers,
  'max-early-data': ?instance.maxEarlyData,
  'early-data-header-name': ?instance.earlyDataHeaderName,
  'v2ray-http-upgrade': ?instance.v2rayHttpUpgrade,
};

GrpcOpts _$GrpcOptsFromJson(Map<String, dynamic> json) =>
    GrpcOpts(grpcServiceName: json['grpc-service-name'] as String?);

Map<String, dynamic> _$GrpcOptsToJson(GrpcOpts instance) => <String, dynamic>{
  'grpc-service-name': ?instance.grpcServiceName,
};

HttpOpts _$HttpOptsFromJson(Map<String, dynamic> json) => HttpOpts(
  method: json['method'] as String?,
  path: (json['path'] as List<dynamic>?)?.map((e) => e as String).toList(),
  headers: json['headers'] as Map<String, dynamic>?,
);

Map<String, dynamic> _$HttpOptsToJson(HttpOpts instance) => <String, dynamic>{
  'method': ?instance.method,
  'path': ?instance.path,
  'headers': ?instance.headers,
};

H2Opts _$H2OptsFromJson(Map<String, dynamic> json) => H2Opts(
  host: (json['host'] as List<dynamic>?)?.map((e) => e as String).toList(),
  path: (json['path'] as List<dynamic>?)?.map((e) => e as String).toList(),
);

Map<String, dynamic> _$H2OptsToJson(H2Opts instance) => <String, dynamic>{
  'host': ?instance.host,
  'path': ?instance.path,
};
