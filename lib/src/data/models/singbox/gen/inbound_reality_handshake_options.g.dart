// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'inbound_reality_handshake_options.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

InboundRealityHandshakeOptions _$InboundRealityHandshakeOptionsFromJson(
  Map<String, dynamic> json,
) => InboundRealityHandshakeOptions()
  ..server = json['server'] as String?
  ..serverPort = (json['server_port'] as num?)?.toInt()
  ..detour = json['detour'] as String?
  ..bindInterface = json['bind_interface'] as String?
  ..inet4BindAddress = json['inet4_bind_address']
  ..inet6BindAddress = json['inet6_bind_address']
  ..bindAddressNoPort = json['bind_address_no_port'] as bool?
  ..protectPath = json['protect_path'] as String?
  ..routingMark = json['routing_mark']
  ..reuseAddr = json['reuse_addr'] as bool?
  ..netns = json['netns'] as String?
  ..connectTimeout = json['connect_timeout'] as String?
  ..tcpFastOpen = json['tcp_fast_open'] as bool?
  ..tcpMultiPath = json['tcp_multi_path'] as bool?
  ..disableTcpKeepAlive = json['disable_tcp_keep_alive'] as bool?
  ..tcpKeepAlive = json['tcp_keep_alive'] as String?
  ..tcpKeepAliveInterval = json['tcp_keep_alive_interval'] as String?
  ..udpFragment = json['udp_fragment'] as bool?
  ..domainResolver = json['domain_resolver']
  ..networkStrategy = json['network_strategy'] as String?
  ..networkType = json['network_type']
  ..fallbackNetworkType = json['fallback_network_type']
  ..fallbackDelay = json['fallback_delay'] as String?;

Map<String, dynamic> _$InboundRealityHandshakeOptionsToJson(
  InboundRealityHandshakeOptions instance,
) => <String, dynamic>{
  'server': ?instance.server,
  'server_port': ?instance.serverPort,
  'detour': ?instance.detour,
  'bind_interface': ?instance.bindInterface,
  'inet4_bind_address': ?instance.inet4BindAddress,
  'inet6_bind_address': ?instance.inet6BindAddress,
  'bind_address_no_port': ?instance.bindAddressNoPort,
  'protect_path': ?instance.protectPath,
  'routing_mark': ?instance.routingMark,
  'reuse_addr': ?instance.reuseAddr,
  'netns': ?instance.netns,
  'connect_timeout': ?instance.connectTimeout,
  'tcp_fast_open': ?instance.tcpFastOpen,
  'tcp_multi_path': ?instance.tcpMultiPath,
  'disable_tcp_keep_alive': ?instance.disableTcpKeepAlive,
  'tcp_keep_alive': ?instance.tcpKeepAlive,
  'tcp_keep_alive_interval': ?instance.tcpKeepAliveInterval,
  'udp_fragment': ?instance.udpFragment,
  'domain_resolver': ?instance.domainResolver,
  'network_strategy': ?instance.networkStrategy,
  'network_type': ?instance.networkType,
  'fallback_network_type': ?instance.fallbackNetworkType,
  'fallback_delay': ?instance.fallbackDelay,
};
