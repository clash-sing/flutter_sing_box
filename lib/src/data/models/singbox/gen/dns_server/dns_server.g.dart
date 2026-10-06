// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dns_server.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DhcpDNSServer _$DhcpDNSServerFromJson(Map<String, dynamic> json) =>
    DhcpDNSServer(tag: json['tag'] as String)
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
      ..fallbackDelay = json['fallback_delay'] as String?
      ..preferGo = json['prefer_go'] as bool?
      ..neighborDomain = json['neighbor_domain']
      ..interface_ = json['interface'] as String?;

Map<String, dynamic> _$DhcpDNSServerToJson(DhcpDNSServer instance) =>
    <String, dynamic>{
      'tag': instance.tag,
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
      'prefer_go': ?instance.preferGo,
      'neighbor_domain': ?instance.neighborDomain,
      'interface': ?instance.interface_,
    };

FakeipDNSServer _$FakeipDNSServerFromJson(Map<String, dynamic> json) =>
    FakeipDNSServer(tag: json['tag'] as String)
      ..inet4Range = json['inet4_range']
      ..inet6Range = json['inet6_range'];

Map<String, dynamic> _$FakeipDNSServerToJson(FakeipDNSServer instance) =>
    <String, dynamic>{
      'tag': instance.tag,
      'inet4_range': ?instance.inet4Range,
      'inet6_range': ?instance.inet6Range,
    };

H3DNSServer _$H3DNSServerFromJson(Map<String, dynamic> json) =>
    H3DNSServer(tag: json['tag'] as String)
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
      ..fallbackDelay = json['fallback_delay'] as String?
      ..server = json['server'] as String?
      ..serverPort = (json['server_port'] as num?)?.toInt()
      ..tls = json['tls'] == null
          ? null
          : OutboundTLSOptions.fromJson(json['tls'] as Map<String, dynamic>)
      ..path = json['path'] as String?
      ..method = json['method'] as String?
      ..headers = json['headers'] == null
          ? null
          : HTTPHeader.fromJson(json['headers'] as Map<String, dynamic>);

Map<String, dynamic> _$H3DNSServerToJson(H3DNSServer instance) =>
    <String, dynamic>{
      'tag': instance.tag,
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
      'server': ?instance.server,
      'server_port': ?instance.serverPort,
      'tls': ?instance.tls?.toJson(),
      'path': ?instance.path,
      'method': ?instance.method,
      'headers': ?instance.headers?.toJson(),
    };

HostsDNSServer _$HostsDNSServerFromJson(Map<String, dynamic> json) =>
    HostsDNSServer(tag: json['tag'] as String)
      ..path = json['path']
      ..predefined = json['predefined'];

Map<String, dynamic> _$HostsDNSServerToJson(HostsDNSServer instance) =>
    <String, dynamic>{
      'tag': instance.tag,
      'path': ?instance.path,
      'predefined': ?instance.predefined,
    };

HttpsDNSServer _$HttpsDNSServerFromJson(Map<String, dynamic> json) =>
    HttpsDNSServer(tag: json['tag'] as String)
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
      ..fallbackDelay = json['fallback_delay'] as String?
      ..server = json['server'] as String?
      ..serverPort = (json['server_port'] as num?)?.toInt()
      ..tls = json['tls'] == null
          ? null
          : OutboundTLSOptions.fromJson(json['tls'] as Map<String, dynamic>)
      ..path = json['path'] as String?
      ..method = json['method'] as String?
      ..headers = json['headers'] == null
          ? null
          : HTTPHeader.fromJson(json['headers'] as Map<String, dynamic>);

Map<String, dynamic> _$HttpsDNSServerToJson(HttpsDNSServer instance) =>
    <String, dynamic>{
      'tag': instance.tag,
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
      'server': ?instance.server,
      'server_port': ?instance.serverPort,
      'tls': ?instance.tls?.toJson(),
      'path': ?instance.path,
      'method': ?instance.method,
      'headers': ?instance.headers?.toJson(),
    };

LocalDNSServer _$LocalDNSServerFromJson(Map<String, dynamic> json) =>
    LocalDNSServer(tag: json['tag'] as String)
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
      ..fallbackDelay = json['fallback_delay'] as String?
      ..preferGo = json['prefer_go'] as bool?
      ..neighborDomain = json['neighbor_domain'];

Map<String, dynamic> _$LocalDNSServerToJson(LocalDNSServer instance) =>
    <String, dynamic>{
      'tag': instance.tag,
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
      'prefer_go': ?instance.preferGo,
      'neighbor_domain': ?instance.neighborDomain,
    };

MdnsDNSServer _$MdnsDNSServerFromJson(Map<String, dynamic> json) =>
    MdnsDNSServer(tag: json['tag'] as String)
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
      ..fallbackDelay = json['fallback_delay'] as String?
      ..preferGo = json['prefer_go'] as bool?
      ..neighborDomain = json['neighbor_domain']
      ..interface_ = json['interface'];

Map<String, dynamic> _$MdnsDNSServerToJson(MdnsDNSServer instance) =>
    <String, dynamic>{
      'tag': instance.tag,
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
      'prefer_go': ?instance.preferGo,
      'neighbor_domain': ?instance.neighborDomain,
      'interface': ?instance.interface_,
    };

OpenconnectDNSServer _$OpenconnectDNSServerFromJson(
  Map<String, dynamic> json,
) => OpenconnectDNSServer(tag: json['tag'] as String)
  ..endpoint = json['endpoint'] as String?
  ..acceptDefaultResolvers = json['accept_default_resolvers'] as bool?
  ..acceptSearchDomain = json['accept_search_domain'] as bool?;

Map<String, dynamic> _$OpenconnectDNSServerToJson(
  OpenconnectDNSServer instance,
) => <String, dynamic>{
  'tag': instance.tag,
  'endpoint': ?instance.endpoint,
  'accept_default_resolvers': ?instance.acceptDefaultResolvers,
  'accept_search_domain': ?instance.acceptSearchDomain,
};

OpenvpnDNSServer _$OpenvpnDNSServerFromJson(Map<String, dynamic> json) =>
    OpenvpnDNSServer(tag: json['tag'] as String)
      ..endpoint = json['endpoint'] as String?
      ..acceptDefaultResolvers = json['accept_default_resolvers'] as bool?
      ..acceptSearchDomain = json['accept_search_domain'] as bool?;

Map<String, dynamic> _$OpenvpnDNSServerToJson(OpenvpnDNSServer instance) =>
    <String, dynamic>{
      'tag': instance.tag,
      'endpoint': ?instance.endpoint,
      'accept_default_resolvers': ?instance.acceptDefaultResolvers,
      'accept_search_domain': ?instance.acceptSearchDomain,
    };

QuicDNSServer _$QuicDNSServerFromJson(Map<String, dynamic> json) =>
    QuicDNSServer(tag: json['tag'] as String)
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
      ..fallbackDelay = json['fallback_delay'] as String?
      ..server = json['server'] as String?
      ..serverPort = (json['server_port'] as num?)?.toInt()
      ..tls = json['tls'] == null
          ? null
          : OutboundTLSOptions.fromJson(json['tls'] as Map<String, dynamic>);

Map<String, dynamic> _$QuicDNSServerToJson(QuicDNSServer instance) =>
    <String, dynamic>{
      'tag': instance.tag,
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
      'server': ?instance.server,
      'server_port': ?instance.serverPort,
      'tls': ?instance.tls?.toJson(),
    };

ResolvedDNSServer _$ResolvedDNSServerFromJson(Map<String, dynamic> json) =>
    ResolvedDNSServer(tag: json['tag'] as String)
      ..service = json['service'] as String?
      ..acceptDefaultResolvers = json['accept_default_resolvers'] as bool?;

Map<String, dynamic> _$ResolvedDNSServerToJson(ResolvedDNSServer instance) =>
    <String, dynamic>{
      'tag': instance.tag,
      'service': ?instance.service,
      'accept_default_resolvers': ?instance.acceptDefaultResolvers,
    };

TailscaleDNSServer _$TailscaleDNSServerFromJson(Map<String, dynamic> json) =>
    TailscaleDNSServer(tag: json['tag'] as String)
      ..endpoint = json['endpoint'] as String?
      ..acceptDefaultResolvers = json['accept_default_resolvers'] as bool?
      ..acceptSearchDomain = json['accept_search_domain'] as bool?;

Map<String, dynamic> _$TailscaleDNSServerToJson(TailscaleDNSServer instance) =>
    <String, dynamic>{
      'tag': instance.tag,
      'endpoint': ?instance.endpoint,
      'accept_default_resolvers': ?instance.acceptDefaultResolvers,
      'accept_search_domain': ?instance.acceptSearchDomain,
    };

TcpDNSServer _$TcpDNSServerFromJson(Map<String, dynamic> json) =>
    TcpDNSServer(tag: json['tag'] as String)
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
      ..fallbackDelay = json['fallback_delay'] as String?
      ..server = json['server'] as String?
      ..serverPort = (json['server_port'] as num?)?.toInt();

Map<String, dynamic> _$TcpDNSServerToJson(TcpDNSServer instance) =>
    <String, dynamic>{
      'tag': instance.tag,
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
      'server': ?instance.server,
      'server_port': ?instance.serverPort,
    };

TlsDNSServer _$TlsDNSServerFromJson(Map<String, dynamic> json) =>
    TlsDNSServer(tag: json['tag'] as String)
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
      ..fallbackDelay = json['fallback_delay'] as String?
      ..server = json['server'] as String?
      ..serverPort = (json['server_port'] as num?)?.toInt()
      ..tls = json['tls'] == null
          ? null
          : OutboundTLSOptions.fromJson(json['tls'] as Map<String, dynamic>);

Map<String, dynamic> _$TlsDNSServerToJson(TlsDNSServer instance) =>
    <String, dynamic>{
      'tag': instance.tag,
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
      'server': ?instance.server,
      'server_port': ?instance.serverPort,
      'tls': ?instance.tls?.toJson(),
    };

UdpDNSServer _$UdpDNSServerFromJson(Map<String, dynamic> json) =>
    UdpDNSServer(tag: json['tag'] as String)
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
      ..fallbackDelay = json['fallback_delay'] as String?
      ..server = json['server'] as String?
      ..serverPort = (json['server_port'] as num?)?.toInt();

Map<String, dynamic> _$UdpDNSServerToJson(UdpDNSServer instance) =>
    <String, dynamic>{
      'tag': instance.tag,
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
      'server': ?instance.server,
      'server_port': ?instance.serverPort,
    };
