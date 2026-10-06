// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'outbound.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AnytlsOutbound _$AnytlsOutboundFromJson(Map<String, dynamic> json) =>
    AnytlsOutbound(tag: json['tag'] as String)
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
      ..password = json['password'] as String?
      ..idleSessionCheckInterval =
          json['idle_session_check_interval'] as String?
      ..idleSessionTimeout = json['idle_session_timeout'] as String?
      ..minIdleSession = (json['min_idle_session'] as num?)?.toInt()
      ..clientMetadata = json['client_metadata'] as String?;

Map<String, dynamic> _$AnytlsOutboundToJson(AnytlsOutbound instance) =>
    <String, dynamic>{
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
      'tag': instance.tag,
      'server': ?instance.server,
      'server_port': ?instance.serverPort,
      'tls': ?instance.tls?.toJson(),
      'password': ?instance.password,
      'idle_session_check_interval': ?instance.idleSessionCheckInterval,
      'idle_session_timeout': ?instance.idleSessionTimeout,
      'min_idle_session': ?instance.minIdleSession,
      'client_metadata': ?instance.clientMetadata,
    };

BlockOutbound _$BlockOutboundFromJson(Map<String, dynamic> json) =>
    BlockOutbound(tag: json['tag'] as String);

Map<String, dynamic> _$BlockOutboundToJson(BlockOutbound instance) =>
    <String, dynamic>{'tag': instance.tag};

DirectOutbound _$DirectOutboundFromJson(Map<String, dynamic> json) =>
    DirectOutbound(tag: json['tag'] as String)
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

Map<String, dynamic> _$DirectOutboundToJson(DirectOutbound instance) =>
    <String, dynamic>{
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
      'tag': instance.tag,
    };

HttpOutbound _$HttpOutboundFromJson(Map<String, dynamic> json) =>
    HttpOutbound(tag: json['tag'] as String)
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
      ..username = json['username'] as String?
      ..password = json['password'] as String?
      ..tls = json['tls'] == null
          ? null
          : OutboundTLSOptions.fromJson(json['tls'] as Map<String, dynamic>)
      ..path = json['path'] as String?
      ..headers = json['headers'] == null
          ? null
          : HTTPHeader.fromJson(json['headers'] as Map<String, dynamic>)
      ..version = (json['version'] as num?)?.toInt()
      ..disableVersionFallback = json['disable_version_fallback'] as bool?
      ..idleTimeout = json['idle_timeout'] as String?
      ..keepAlivePeriod = json['keep_alive_period'] as String?
      ..streamReceiveWindow = json['stream_receive_window']
      ..connectionReceiveWindow = json['connection_receive_window']
      ..maxConcurrentStreams = (json['max_concurrent_streams'] as num?)?.toInt()
      ..initialPacketSize = (json['initial_packet_size'] as num?)?.toInt()
      ..disablePathMtuDiscovery = json['disable_path_mtu_discovery'] as bool?;

Map<String, dynamic> _$HttpOutboundToJson(HttpOutbound instance) =>
    <String, dynamic>{
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
      'tag': instance.tag,
      'server': ?instance.server,
      'server_port': ?instance.serverPort,
      'username': ?instance.username,
      'password': ?instance.password,
      'tls': ?instance.tls?.toJson(),
      'path': ?instance.path,
      'headers': ?instance.headers?.toJson(),
      'version': ?instance.version,
      'disable_version_fallback': ?instance.disableVersionFallback,
      'idle_timeout': ?instance.idleTimeout,
      'keep_alive_period': ?instance.keepAlivePeriod,
      'stream_receive_window': ?instance.streamReceiveWindow,
      'connection_receive_window': ?instance.connectionReceiveWindow,
      'max_concurrent_streams': ?instance.maxConcurrentStreams,
      'initial_packet_size': ?instance.initialPacketSize,
      'disable_path_mtu_discovery': ?instance.disablePathMtuDiscovery,
    };

HysteriaOutbound _$HysteriaOutboundFromJson(Map<String, dynamic> json) =>
    HysteriaOutbound(tag: json['tag'] as String)
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
      ..serverPorts = (json['server_ports'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList()
      ..hopInterval = json['hop_interval'] as String?
      ..up = json['up']
      ..upMbps = (json['up_mbps'] as num?)?.toInt()
      ..down = json['down']
      ..downMbps = (json['down_mbps'] as num?)?.toInt()
      ..obfs = json['obfs'] as String?
      ..auth = json['auth']
      ..authStr = json['auth_str'] as String?
      ..network = json['network']
      ..tls = json['tls'] == null
          ? null
          : OutboundTLSOptions.fromJson(json['tls'] as Map<String, dynamic>)
      ..idleTimeout = json['idle_timeout'] as String?
      ..keepAlivePeriod = json['keep_alive_period'] as String?
      ..streamReceiveWindow = json['stream_receive_window']
      ..connectionReceiveWindow = json['connection_receive_window']
      ..maxConcurrentStreams = (json['max_concurrent_streams'] as num?)?.toInt()
      ..initialPacketSize = (json['initial_packet_size'] as num?)?.toInt()
      ..disablePathMtuDiscovery = json['disable_path_mtu_discovery'] as bool?;

Map<String, dynamic> _$HysteriaOutboundToJson(HysteriaOutbound instance) =>
    <String, dynamic>{
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
      'tag': instance.tag,
      'server': ?instance.server,
      'server_port': ?instance.serverPort,
      'server_ports': ?instance.serverPorts,
      'hop_interval': ?instance.hopInterval,
      'up': ?instance.up,
      'up_mbps': ?instance.upMbps,
      'down': ?instance.down,
      'down_mbps': ?instance.downMbps,
      'obfs': ?instance.obfs,
      'auth': ?instance.auth,
      'auth_str': ?instance.authStr,
      'network': ?instance.network,
      'tls': ?instance.tls?.toJson(),
      'idle_timeout': ?instance.idleTimeout,
      'keep_alive_period': ?instance.keepAlivePeriod,
      'stream_receive_window': ?instance.streamReceiveWindow,
      'connection_receive_window': ?instance.connectionReceiveWindow,
      'max_concurrent_streams': ?instance.maxConcurrentStreams,
      'initial_packet_size': ?instance.initialPacketSize,
      'disable_path_mtu_discovery': ?instance.disablePathMtuDiscovery,
    };

Hysteria2Outbound _$Hysteria2OutboundFromJson(Map<String, dynamic> json) =>
    Hysteria2Outbound(tag: json['tag'] as String)
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
      ..serverPorts = (json['server_ports'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList()
      ..hopInterval = json['hop_interval'] as String?
      ..hopIntervalMax = json['hop_interval_max'] as String?
      ..upMbps = (json['up_mbps'] as num?)?.toInt()
      ..downMbps = (json['down_mbps'] as num?)?.toInt()
      ..obfs = json['obfs']
      ..password = json['password'] as String?
      ..network = json['network']
      ..tls = json['tls'] == null
          ? null
          : OutboundTLSOptions.fromJson(json['tls'] as Map<String, dynamic>)
      ..idleTimeout = json['idle_timeout'] as String?
      ..keepAlivePeriod = json['keep_alive_period'] as String?
      ..streamReceiveWindow = json['stream_receive_window']
      ..connectionReceiveWindow = json['connection_receive_window']
      ..maxConcurrentStreams = (json['max_concurrent_streams'] as num?)?.toInt()
      ..initialPacketSize = (json['initial_packet_size'] as num?)?.toInt()
      ..disablePathMtuDiscovery = json['disable_path_mtu_discovery'] as bool?
      ..bbrProfile = json['bbr_profile'] as String?
      ..brutalDebug = json['brutal_debug'] as bool?
      ..disableChromeParrot = json['disable_chrome_parrot'] as bool?
      ..realm = json['realm'] == null
          ? null
          : Hysteria2Realm.fromJson(json['realm'] as Map<String, dynamic>);

Map<String, dynamic> _$Hysteria2OutboundToJson(Hysteria2Outbound instance) =>
    <String, dynamic>{
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
      'tag': instance.tag,
      'server': ?instance.server,
      'server_port': ?instance.serverPort,
      'server_ports': ?instance.serverPorts,
      'hop_interval': ?instance.hopInterval,
      'hop_interval_max': ?instance.hopIntervalMax,
      'up_mbps': ?instance.upMbps,
      'down_mbps': ?instance.downMbps,
      'obfs': ?instance.obfs,
      'password': ?instance.password,
      'network': ?instance.network,
      'tls': ?instance.tls?.toJson(),
      'idle_timeout': ?instance.idleTimeout,
      'keep_alive_period': ?instance.keepAlivePeriod,
      'stream_receive_window': ?instance.streamReceiveWindow,
      'connection_receive_window': ?instance.connectionReceiveWindow,
      'max_concurrent_streams': ?instance.maxConcurrentStreams,
      'initial_packet_size': ?instance.initialPacketSize,
      'disable_path_mtu_discovery': ?instance.disablePathMtuDiscovery,
      'bbr_profile': ?instance.bbrProfile,
      'brutal_debug': ?instance.brutalDebug,
      'disable_chrome_parrot': ?instance.disableChromeParrot,
      'realm': ?instance.realm?.toJson(),
    };

NaiveOutbound _$NaiveOutboundFromJson(Map<String, dynamic> json) =>
    NaiveOutbound(tag: json['tag'] as String)
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
      ..username = json['username'] as String?
      ..password = json['password'] as String?
      ..insecureConcurrency = (json['insecure_concurrency'] as num?)?.toInt()
      ..extraHeaders = json['extra_headers'] == null
          ? null
          : HTTPHeader.fromJson(json['extra_headers'] as Map<String, dynamic>)
      ..streamReceiveWindow = json['stream_receive_window']
      ..udpOverTcp = json['udp_over_tcp']
      ..quic = json['quic'] as bool?
      ..quicCongestionControl = json['quic_congestion_control'] as String?
      ..quicSessionReceiveWindow = json['quic_session_receive_window']
      ..tls = json['tls'] == null
          ? null
          : OutboundTLSOptions.fromJson(json['tls'] as Map<String, dynamic>);

Map<String, dynamic> _$NaiveOutboundToJson(NaiveOutbound instance) =>
    <String, dynamic>{
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
      'tag': instance.tag,
      'server': ?instance.server,
      'server_port': ?instance.serverPort,
      'username': ?instance.username,
      'password': ?instance.password,
      'insecure_concurrency': ?instance.insecureConcurrency,
      'extra_headers': ?instance.extraHeaders?.toJson(),
      'stream_receive_window': ?instance.streamReceiveWindow,
      'udp_over_tcp': ?instance.udpOverTcp,
      'quic': ?instance.quic,
      'quic_congestion_control': ?instance.quicCongestionControl,
      'quic_session_receive_window': ?instance.quicSessionReceiveWindow,
      'tls': ?instance.tls?.toJson(),
    };

SelectorOutbound _$SelectorOutboundFromJson(Map<String, dynamic> json) =>
    SelectorOutbound(tag: json['tag'] as String)
      ..outbounds = (json['outbounds'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList()
      ..default_ = json['default'] as String?
      ..interruptExistConnections =
          json['interrupt_exist_connections'] as bool?;

Map<String, dynamic> _$SelectorOutboundToJson(SelectorOutbound instance) =>
    <String, dynamic>{
      'tag': instance.tag,
      'outbounds': ?instance.outbounds,
      'default': ?instance.default_,
      'interrupt_exist_connections': ?instance.interruptExistConnections,
    };

ShadowsocksOutbound _$ShadowsocksOutboundFromJson(Map<String, dynamic> json) =>
    ShadowsocksOutbound(tag: json['tag'] as String)
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
      ..method = json['method'] as String?
      ..password = json['password'] as String?
      ..plugin = json['plugin'] as String?
      ..pluginOpts = json['plugin_opts'] as String?
      ..network = json['network']
      ..udpOverTcp = json['udp_over_tcp']
      ..multiplex = json['multiplex'] == null
          ? null
          : OutboundMultiplexOptions.fromJson(
              json['multiplex'] as Map<String, dynamic>,
            );

Map<String, dynamic> _$ShadowsocksOutboundToJson(
  ShadowsocksOutbound instance,
) => <String, dynamic>{
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
  'tag': instance.tag,
  'server': ?instance.server,
  'server_port': ?instance.serverPort,
  'method': ?instance.method,
  'password': ?instance.password,
  'plugin': ?instance.plugin,
  'plugin_opts': ?instance.pluginOpts,
  'network': ?instance.network,
  'udp_over_tcp': ?instance.udpOverTcp,
  'multiplex': ?instance.multiplex?.toJson(),
};

ShadowtlsOutbound _$ShadowtlsOutboundFromJson(Map<String, dynamic> json) =>
    ShadowtlsOutbound(tag: json['tag'] as String)
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
      ..version = (json['version'] as num?)?.toInt()
      ..password = json['password'] as String?
      ..tls = json['tls'] == null
          ? null
          : OutboundTLSOptions.fromJson(json['tls'] as Map<String, dynamic>);

Map<String, dynamic> _$ShadowtlsOutboundToJson(ShadowtlsOutbound instance) =>
    <String, dynamic>{
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
      'tag': instance.tag,
      'server': ?instance.server,
      'server_port': ?instance.serverPort,
      'version': ?instance.version,
      'password': ?instance.password,
      'tls': ?instance.tls?.toJson(),
    };

SnellOutbound _$SnellOutboundFromJson(Map<String, dynamic> json) =>
    SnellOutbound(
        tag: json['tag'] as String,
        version: (json['version'] as num).toInt(),
      )
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
      ..psk = json['psk'] as String?
      ..userkey = json['userkey'] as String?
      ..reuse = json['reuse'] as bool?
      ..network = json['network']
      ..obfsMode = json['obfs_mode'] as String?
      ..obfsHost = json['obfs_host'] as String?
      ..mode = json['mode'] as String?;

Map<String, dynamic> _$SnellOutboundToJson(SnellOutbound instance) =>
    <String, dynamic>{
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
      'tag': instance.tag,
      'version': instance.version,
      'server': ?instance.server,
      'server_port': ?instance.serverPort,
      'psk': ?instance.psk,
      'userkey': ?instance.userkey,
      'reuse': ?instance.reuse,
      'network': ?instance.network,
      'obfs_mode': ?instance.obfsMode,
      'obfs_host': ?instance.obfsHost,
      'mode': ?instance.mode,
    };

SocksOutbound _$SocksOutboundFromJson(Map<String, dynamic> json) =>
    SocksOutbound(tag: json['tag'] as String)
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
      ..version = json['version'] as String?
      ..username = json['username'] as String?
      ..password = json['password'] as String?
      ..network = json['network']
      ..udpOverTcp = json['udp_over_tcp'];

Map<String, dynamic> _$SocksOutboundToJson(SocksOutbound instance) =>
    <String, dynamic>{
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
      'tag': instance.tag,
      'server': ?instance.server,
      'server_port': ?instance.serverPort,
      'version': ?instance.version,
      'username': ?instance.username,
      'password': ?instance.password,
      'network': ?instance.network,
      'udp_over_tcp': ?instance.udpOverTcp,
    };

TrojanOutbound _$TrojanOutboundFromJson(Map<String, dynamic> json) =>
    TrojanOutbound(tag: json['tag'] as String)
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
      ..password = json['password'] as String?
      ..network = json['network']
      ..tls = json['tls'] == null
          ? null
          : OutboundTLSOptions.fromJson(json['tls'] as Map<String, dynamic>)
      ..multiplex = json['multiplex'] == null
          ? null
          : OutboundMultiplexOptions.fromJson(
              json['multiplex'] as Map<String, dynamic>,
            )
      ..transport = json['transport'] == null
          ? null
          : V2RayTransport.fromJson(json['transport'] as Map<String, dynamic>);

Map<String, dynamic> _$TrojanOutboundToJson(TrojanOutbound instance) =>
    <String, dynamic>{
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
      'tag': instance.tag,
      'server': ?instance.server,
      'server_port': ?instance.serverPort,
      'password': ?instance.password,
      'network': ?instance.network,
      'tls': ?instance.tls?.toJson(),
      'multiplex': ?instance.multiplex?.toJson(),
      'transport': ?instance.transport?.toJson(),
    };

TuicOutbound _$TuicOutboundFromJson(Map<String, dynamic> json) =>
    TuicOutbound(tag: json['tag'] as String)
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
      ..uuid = json['uuid'] as String?
      ..password = json['password'] as String?
      ..congestionControl = json['congestion_control'] as String?
      ..udpRelayMode = json['udp_relay_mode'] as String?
      ..udpOverStream = json['udp_over_stream'] as bool?
      ..zeroRttHandshake = json['zero_rtt_handshake'] as bool?
      ..heartbeat = json['heartbeat'] as String?
      ..network = json['network']
      ..tls = json['tls'] == null
          ? null
          : OutboundTLSOptions.fromJson(json['tls'] as Map<String, dynamic>)
      ..idleTimeout = json['idle_timeout'] as String?
      ..keepAlivePeriod = json['keep_alive_period'] as String?
      ..streamReceiveWindow = json['stream_receive_window']
      ..connectionReceiveWindow = json['connection_receive_window']
      ..maxConcurrentStreams = (json['max_concurrent_streams'] as num?)?.toInt()
      ..initialPacketSize = (json['initial_packet_size'] as num?)?.toInt()
      ..disablePathMtuDiscovery = json['disable_path_mtu_discovery'] as bool?;

Map<String, dynamic> _$TuicOutboundToJson(TuicOutbound instance) =>
    <String, dynamic>{
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
      'tag': instance.tag,
      'server': ?instance.server,
      'server_port': ?instance.serverPort,
      'uuid': ?instance.uuid,
      'password': ?instance.password,
      'congestion_control': ?instance.congestionControl,
      'udp_relay_mode': ?instance.udpRelayMode,
      'udp_over_stream': ?instance.udpOverStream,
      'zero_rtt_handshake': ?instance.zeroRttHandshake,
      'heartbeat': ?instance.heartbeat,
      'network': ?instance.network,
      'tls': ?instance.tls?.toJson(),
      'idle_timeout': ?instance.idleTimeout,
      'keep_alive_period': ?instance.keepAlivePeriod,
      'stream_receive_window': ?instance.streamReceiveWindow,
      'connection_receive_window': ?instance.connectionReceiveWindow,
      'max_concurrent_streams': ?instance.maxConcurrentStreams,
      'initial_packet_size': ?instance.initialPacketSize,
      'disable_path_mtu_discovery': ?instance.disablePathMtuDiscovery,
    };

UrltestOutbound _$UrltestOutboundFromJson(Map<String, dynamic> json) =>
    UrltestOutbound(tag: json['tag'] as String)
      ..outbounds = (json['outbounds'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList()
      ..url = json['url'] as String?
      ..interval = json['interval'] as String?
      ..tolerance = (json['tolerance'] as num?)?.toInt()
      ..idleTimeout = json['idle_timeout'] as String?
      ..interruptExistConnections =
          json['interrupt_exist_connections'] as bool?;

Map<String, dynamic> _$UrltestOutboundToJson(UrltestOutbound instance) =>
    <String, dynamic>{
      'tag': instance.tag,
      'outbounds': ?instance.outbounds,
      'url': ?instance.url,
      'interval': ?instance.interval,
      'tolerance': ?instance.tolerance,
      'idle_timeout': ?instance.idleTimeout,
      'interrupt_exist_connections': ?instance.interruptExistConnections,
    };

VlessOutbound _$VlessOutboundFromJson(Map<String, dynamic> json) =>
    VlessOutbound(tag: json['tag'] as String)
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
      ..uuid = json['uuid'] as String?
      ..flow = json['flow'] as String?
      ..network = json['network']
      ..tls = json['tls'] == null
          ? null
          : OutboundTLSOptions.fromJson(json['tls'] as Map<String, dynamic>)
      ..multiplex = json['multiplex'] == null
          ? null
          : OutboundMultiplexOptions.fromJson(
              json['multiplex'] as Map<String, dynamic>,
            )
      ..transport = json['transport'] == null
          ? null
          : V2RayTransport.fromJson(json['transport'] as Map<String, dynamic>)
      ..packetEncoding = json['packet_encoding'] as String?;

Map<String, dynamic> _$VlessOutboundToJson(VlessOutbound instance) =>
    <String, dynamic>{
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
      'tag': instance.tag,
      'server': ?instance.server,
      'server_port': ?instance.serverPort,
      'uuid': ?instance.uuid,
      'flow': ?instance.flow,
      'network': ?instance.network,
      'tls': ?instance.tls?.toJson(),
      'multiplex': ?instance.multiplex?.toJson(),
      'transport': ?instance.transport?.toJson(),
      'packet_encoding': ?instance.packetEncoding,
    };

VmessOutbound _$VmessOutboundFromJson(Map<String, dynamic> json) =>
    VmessOutbound(tag: json['tag'] as String)
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
      ..uuid = json['uuid'] as String?
      ..security = json['security'] as String?
      ..alterId = (json['alter_id'] as num?)?.toInt()
      ..globalPadding = json['global_padding'] as bool?
      ..authenticatedLength = json['authenticated_length'] as bool?
      ..network = json['network']
      ..tls = json['tls'] == null
          ? null
          : OutboundTLSOptions.fromJson(json['tls'] as Map<String, dynamic>)
      ..packetEncoding = json['packet_encoding'] as String?
      ..multiplex = json['multiplex'] == null
          ? null
          : OutboundMultiplexOptions.fromJson(
              json['multiplex'] as Map<String, dynamic>,
            )
      ..transport = json['transport'] == null
          ? null
          : V2RayTransport.fromJson(json['transport'] as Map<String, dynamic>);

Map<String, dynamic> _$VmessOutboundToJson(VmessOutbound instance) =>
    <String, dynamic>{
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
      'tag': instance.tag,
      'server': ?instance.server,
      'server_port': ?instance.serverPort,
      'uuid': ?instance.uuid,
      'security': ?instance.security,
      'alter_id': ?instance.alterId,
      'global_padding': ?instance.globalPadding,
      'authenticated_length': ?instance.authenticatedLength,
      'network': ?instance.network,
      'tls': ?instance.tls?.toJson(),
      'packet_encoding': ?instance.packetEncoding,
      'multiplex': ?instance.multiplex?.toJson(),
      'transport': ?instance.transport?.toJson(),
    };
