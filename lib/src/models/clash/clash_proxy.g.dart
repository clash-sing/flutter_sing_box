// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'clash_proxy.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ClashProxy _$ClashProxyFromJson(Map<String, dynamic> json) => ClashProxy(
  name: json['name'] as String,
  type: json['type'] as String,
  server: json['server'] as String,
  port: (json['port'] as num).toInt(),
  ports: json['ports'] as String?,
  password: json['password'] as String?,
  skipCertVerify: json['skip-cert-verify'] as bool,
  clientFingerprint: json['client-fingerprint'] as String?,
  udp: json['udp'] as bool?,
  tfo: json['tfo'] as bool?,
  sni: json['sni'] as String?,
  network: json['network'] as String?,
  up: (json['up'] as num?)?.toInt(),
  down: (json['down'] as num?)?.toInt(),
  authStr: json['auth_str'] as String?,
  alpn: (json['alpn'] as List<dynamic>?)?.map((e) => e as String).toList(),
  protocol: json['protocol'] as String?,
  fastOpen: json['fast-open'] as bool?,
  disableMtuDiscovery: json['disable_mtu_discovery'] as bool?,
);

Map<String, dynamic> _$ClashProxyToJson(ClashProxy instance) =>
    <String, dynamic>{
      'name': instance.name,
      'type': instance.type,
      'server': instance.server,
      'port': instance.port,
      'ports': ?instance.ports,
      'password': ?instance.password,
      'skip-cert-verify': instance.skipCertVerify,
      'client-fingerprint': ?instance.clientFingerprint,
      'udp': ?instance.udp,
      'tfo': ?instance.tfo,
      'sni': ?instance.sni,
      'network': ?instance.network,
      'up': ?instance.up,
      'down': ?instance.down,
      'auth_str': ?instance.authStr,
      'alpn': ?instance.alpn,
      'protocol': ?instance.protocol,
      'fast-open': ?instance.fastOpen,
      'disable_mtu_discovery': ?instance.disableMtuDiscovery,
    };
