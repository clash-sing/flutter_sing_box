// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'inbound.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MixedInbound _$MixedInboundFromJson(Map<String, dynamic> json) =>
    MixedInbound(tag: json['tag'] as String)
      ..detour = json['detour'] as String?
      ..udpTimeout = json['udp_timeout']
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
      ..listen = json['listen']
      ..listenPort = (json['listen_port'] as num?)?.toInt()
      ..users = (json['users'] as List<dynamic>?)
          ?.map((e) => User.fromJson(e as Map<String, dynamic>))
          .toList()
      ..setSystemProxy = json['set_system_proxy'] as bool?
      ..tls = json['tls'] == null
          ? null
          : InboundTLSOptions.fromJson(json['tls'] as Map<String, dynamic>);

Map<String, dynamic> _$MixedInboundToJson(MixedInbound instance) =>
    <String, dynamic>{
      'detour': ?instance.detour,
      'udp_timeout': ?instance.udpTimeout,
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
      'listen': ?instance.listen,
      'listen_port': ?instance.listenPort,
      'users': ?instance.users?.map((e) => e.toJson()).toList(),
      'set_system_proxy': ?instance.setSystemProxy,
      'tls': ?instance.tls?.toJson(),
    };

TunInbound _$TunInboundFromJson(Map<String, dynamic> json) =>
    TunInbound(tag: json['tag'] as String)
      ..detour = json['detour'] as String?
      ..udpTimeout = json['udp_timeout']
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
      ..interfaceName = json['interface_name'] as String?
      ..mtu = (json['mtu'] as num?)?.toInt()
      ..address = json['address']
      ..dnsMode = json['dns_mode'] as String?
      ..dnsAddress = json['dns_address']
      ..autoRoute = json['auto_route'] as bool?
      ..iproute2TableIndex = (json['iproute2_table_index'] as num?)?.toInt()
      ..iproute2RuleIndex = (json['iproute2_rule_index'] as num?)?.toInt()
      ..autoRedirect = json['auto_redirect'] as bool?
      ..autoRedirectInputMark = json['auto_redirect_input_mark']
      ..autoRedirectOutputMark = json['auto_redirect_output_mark']
      ..autoRedirectResetMark = json['auto_redirect_reset_mark']
      ..autoRedirectTproxyMark = json['auto_redirect_tproxy_mark']
      ..autoRedirectNfqueue = (json['auto_redirect_nfqueue'] as num?)?.toInt()
      ..autoRedirectIproute2FallbackRuleIndex =
          (json['auto_redirect_iproute2_fallback_rule_index'] as num?)?.toInt()
      ..excludeMptcp = json['exclude_mptcp'] as bool?
      ..loopbackAddress = json['loopback_address']
      ..strictRoute = json['strict_route'] as bool?
      ..routeAddress = json['route_address']
      ..routeAddressSet = json['route_address_set']
      ..routeExcludeAddress = json['route_exclude_address']
      ..routeExcludeAddressSet = json['route_exclude_address_set']
      ..includeInterface = json['include_interface']
      ..excludeInterface = json['exclude_interface']
      ..includeUid = json['include_uid']
      ..includeUidRange = json['include_uid_range']
      ..excludeUid = json['exclude_uid']
      ..excludeUidRange = json['exclude_uid_range']
      ..includeAndroidUser = json['include_android_user']
      ..includePackage = json['include_package']
      ..excludePackage = json['exclude_package']
      ..includeMacAddress = json['include_mac_address']
      ..excludeMacAddress = json['exclude_mac_address']
      ..udpMapping = json['udp_mapping'] as String?
      ..udpFiltering = json['udp_filtering'] as String?
      ..udpNatMax = (json['udp_nat_max'] as num?)?.toInt()
      ..multiQueue = json['multi_queue'] as bool?
      ..platform = json['platform'] == null
          ? null
          : TunPlatformOptions.fromJson(
              json['platform'] as Map<String, dynamic>,
            );

Map<String, dynamic> _$TunInboundToJson(TunInbound instance) =>
    <String, dynamic>{
      'detour': ?instance.detour,
      'udp_timeout': ?instance.udpTimeout,
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
      'interface_name': ?instance.interfaceName,
      'mtu': ?instance.mtu,
      'address': ?instance.address,
      'dns_mode': ?instance.dnsMode,
      'dns_address': ?instance.dnsAddress,
      'auto_route': ?instance.autoRoute,
      'iproute2_table_index': ?instance.iproute2TableIndex,
      'iproute2_rule_index': ?instance.iproute2RuleIndex,
      'auto_redirect': ?instance.autoRedirect,
      'auto_redirect_input_mark': ?instance.autoRedirectInputMark,
      'auto_redirect_output_mark': ?instance.autoRedirectOutputMark,
      'auto_redirect_reset_mark': ?instance.autoRedirectResetMark,
      'auto_redirect_tproxy_mark': ?instance.autoRedirectTproxyMark,
      'auto_redirect_nfqueue': ?instance.autoRedirectNfqueue,
      'auto_redirect_iproute2_fallback_rule_index':
          ?instance.autoRedirectIproute2FallbackRuleIndex,
      'exclude_mptcp': ?instance.excludeMptcp,
      'loopback_address': ?instance.loopbackAddress,
      'strict_route': ?instance.strictRoute,
      'route_address': ?instance.routeAddress,
      'route_address_set': ?instance.routeAddressSet,
      'route_exclude_address': ?instance.routeExcludeAddress,
      'route_exclude_address_set': ?instance.routeExcludeAddressSet,
      'include_interface': ?instance.includeInterface,
      'exclude_interface': ?instance.excludeInterface,
      'include_uid': ?instance.includeUid,
      'include_uid_range': ?instance.includeUidRange,
      'exclude_uid': ?instance.excludeUid,
      'exclude_uid_range': ?instance.excludeUidRange,
      'include_android_user': ?instance.includeAndroidUser,
      'include_package': ?instance.includePackage,
      'exclude_package': ?instance.excludePackage,
      'include_mac_address': ?instance.includeMacAddress,
      'exclude_mac_address': ?instance.excludeMacAddress,
      'udp_mapping': ?instance.udpMapping,
      'udp_filtering': ?instance.udpFiltering,
      'udp_nat_max': ?instance.udpNatMax,
      'multi_queue': ?instance.multiQueue,
      'platform': ?instance.platform?.toJson(),
    };
