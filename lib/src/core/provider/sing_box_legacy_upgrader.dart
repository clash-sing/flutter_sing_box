import 'dart:convert';

import 'package:flutter/foundation.dart' show debugPrint;

import '../../data/models/singbox/gen/outbound/outbound.dart' show Outbound;

/// 在解析之前，把原生 sing-box 订阅里的旧版写法升级成当前内核认的写法。
///
/// 面板下发的订阅常常停在旧格式（例如 1.12 之前的 DNS 服务器写法），而内核
/// 1.14 已经删除了这些写法，整份配置会被拒收。这里按 [_migrations] 逐项升级
/// 原始 JSON，每一项对应官方迁移文档（https://sing-box.sagernet.org/migration/）
/// 的一节；以后要兼容别的旧写法，往列表里加一项即可。
///
/// 转换目标是让 1.14 运行升级后的配置时，行为与 1.13 运行旧写法时相同；新写法
/// 表达不了的部分（例如服务器级的 strategy）不迁移，各迁移项的注释写明了取舍。
///
/// 只改认得出的旧写法，其余内容原样保留；认不出的写法不抛异常，交给内核报错。
/// 升级过程本身出错时返回原配置，不挡导入。
class SingBoxLegacyUpgrader {
  SingBoxLegacyUpgrader._();

  /// 迁移项按顺序执行：rcode 服务器改写规则在前，outbound 条件的规则在后。
  static const List<void Function(Map<String, dynamic>)> _migrations = [
    _migrateLegacyDnsServers,
    _migrateOutboundDnsRuleItems,
  ];

  /// 返回升级后的副本，不改 [config] 本身。
  static Map<String, dynamic> upgrade(Map<String, dynamic> config) {
    try {
      final copy = jsonDecode(jsonEncode(config)) as Map<String, dynamic>;
      for (final migrate in _migrations) {
        migrate(copy);
      }
      return copy;
    } catch (e) {
      debugPrint('旧写法升级失败，按原配置继续: $e');
      return config;
    }
  }

  // ---------------------------------------------------------------------------
  // 迁移项 1：DNS 服务器的旧写法（address）→ 新写法（type + server）
  // 迁移文档「Migrate to new DNS server formats」。地址与类型的转换参照 sing-box
  // 1.12–1.13 内部的升级逻辑（option/dns.go 的 DNSServerOptions.Upgrade）。
  // 与它不同的地方：
  // - 服务器级的 strategy、client_subnet 不迁移：新写法把它们放在 dns 全局或
  //   规则上，按服务器无法等价表达；
  // - 1.13 对旧写法服务器有拨号豁免，新写法没有，所以 detour 按 1.13 的实际
  //   拨号改写（见 [_upgradeDetour]）；
  // - 没有 tag 的服务器补上 tag（见 [_migrateLegacyDnsServers]）。
  // ---------------------------------------------------------------------------

  /// rcode:// 的主机名 → 新写法 predefined 动作的 rcode 字符串。
  static const Map<String, String> _rcodeNames = {
    'success': 'NOERROR',
    'format_error': 'FORMERR',
    'server_failure': 'SERVFAIL',
    'name_error': 'NXDOMAIN',
    'not_implemented': 'NOTIMP',
    'refused': 'REFUSED',
  };

  /// 各类型的默认端口，等于默认值时不写 server_port。
  static const Map<String, int> _defaultPorts = {
    'udp': 53,
    'tcp': 53,
    'tls': 853,
    'quic': 853,
    'https': 443,
    'h3': 443,
  };

  /// route 动作有、predefined 动作没有的字段（取自 assets/schemas/singbox_schema.json
  /// 的 DNSRuleAction）。改写成 predefined 时要去掉，否则内核按未知字段拒收。
  static const Set<String> _routeOnlyActionFields = {
    'server',
    'speculative',
    'timeout',
    'disable_cache',
    'disable_optimistic_cache',
    'rewrite_ttl',
    'client_subnet',
    'remove_client_subnet',
  };

  /// 是否为旧写法的服务器：type 为 null、空字符串或 legacy（1.13 都当旧写法），
  /// 且 address 是字符串。
  static bool _isLegacyServer(dynamic server) {
    if (server is! Map<String, dynamic> || server['address'] is! String) return false;
    final type = server['type'];
    return type == null || type == '' || type == 'legacy';
  }

  static void _migrateLegacyDnsServers(Map<String, dynamic> config) {
    final dns = config['dns'];
    if (dns is! Map<String, dynamic>) return;
    final servers = dns['servers'];
    if (servers is! List) return;

    // 旧写法的 fakeip 地址段放在 dns.fakeip，新写法放进 fakeip 服务器本身；
    // dns.fakeip 在新写法里已不存在
    final legacyFakeip = dns.remove('fakeip');
    final fakeipRanges = legacyFakeip is Map && legacyFakeip['enabled'] == true
        ? {
            if (legacyFakeip['inet4_range'] != null) 'inet4_range': legacyFakeip['inet4_range'],
            if (legacyFakeip['inet6_range'] != null) 'inet6_range': legacyFakeip['inet6_range'],
          }
        : const <String, dynamic>{};

    // 迁移项 2 补 domain_resolver 时按 1.13 的来源顺序取值，第一个来源是订阅
    // 原文的默认解析器（迁移项 2 可能会写入这个键，所以先记下）
    final route = config['route'];
    final routeResolver = route is Map ? route['default_domain_resolver'] : null;

    final rcodeServers = <String, String>{};
    final upgraded = <dynamic>[];
    final untagged = <Map<String, dynamic>>[];
    for (final server in servers) {
      if (!_isLegacyServer(server)) {
        upgraded.add(server);
        continue;
      }
      final (scheme, host, _) = _splitAddress(server['address'] as String);
      // rcode:// 在新写法里不是服务器，而是规则的 predefined 动作：
      // 服务器去掉，指向它的规则在下面改写。没有 tag 的同样去掉，
      // 没有规则能按名字指向它
      final rcode = scheme == 'rcode' ? _rcodeNames[host] : null;
      if (rcode != null) {
        final tag = server['tag'];
        if (tag is String) rcodeServers[tag] = rcode;
        continue;
      }
      final result = _upgradeDnsServer(server, fakeipRanges, config);
      if (result != null && (result['tag'] == null || result['tag'] == '')) untagged.add(result);
      // 写了 detour 而升级后没有：detour 指向空 direct，被去掉了（见 [_upgradeDetour]）
      final detour = server['detour'];
      if (result != null && result['server'] is String && detour is String && detour.isNotEmpty &&
          !result.containsKey('detour')) {
        _droppedDetours[result] = (detour, routeResolver);
      }
      upgraded.add(result ?? server);
    }
    // 1.14 对没有 tag 的服务器按它在 dns.servers 里的下标命名；这里先写上，
    // 生成的模型要求 tag 是字符串。下标与已有 tag 重名时加后缀
    final usedTags = {
      for (final server in upgraded)
        if (server is Map && server['tag'] is String) server['tag'] as String,
    };
    for (final server in untagged) {
      final index = upgraded.indexOf(server);
      var tag = '$index';
      for (var n = 1; usedTags.contains(tag); n++) {
        tag = '$index-$n';
      }
      usedTags.add(tag);
      server['tag'] = tag;
    }
    dns['servers'] = upgraded;

    final rules = dns['rules'];
    if (rcodeServers.isEmpty || rules is! List) return;
    for (final rule in rules) {
      if (rule is! Map<String, dynamic>) continue;
      final action = rule['action'];
      final rcode = rcodeServers[rule['server']];
      if ((action == null || action == 'route') && rcode != null) {
        rule
          ..removeWhere((key, _) => _routeOnlyActionFields.contains(key))
          ..['action'] = 'predefined'
          ..['rcode'] = rcode;
      }
    }
  }

  /// 把旧写法的 address 拆成（类型、主机与端口、路径）；协议头不分大小写。
  static (String, String, String) _splitAddress(String address) {
    final schemeEnd = address.indexOf('://');
    if (schemeEnd > 0) {
      // 不用 Uri.parse：它会把主机名转成小写，dhcp:// 后面的网卡名要原样保留
      var rest = address.substring(schemeEnd + 3);
      final queryStart = rest.indexOf(RegExp(r'[?#]'));
      if (queryStart >= 0) rest = rest.substring(0, queryStart);
      final slash = rest.indexOf('/');
      return (
        address.substring(0, schemeEnd).toLowerCase(),
        slash < 0 ? rest : rest.substring(0, slash),
        slash < 0 ? '' : rest.substring(slash),
      );
    }
    if (address == 'local' || address == 'fakeip') return (address, '', '');
    // 不带协议头的地址按 udp 处理
    return ('udp', address, '');
  }

  /// 升级一个旧写法的 DNS 服务器；认不出时返回 null（调用方原样保留）。
  static Map<String, dynamic>? _upgradeDnsServer(
    Map<String, dynamic> legacy,
    Map<String, dynamic> fakeipRanges,
    Map<String, dynamic> config,
  ) {
    final (type, hostPort, path) = _splitAddress(legacy['address'] as String);

    final result = <String, dynamic>{
      if (legacy.containsKey('tag')) 'tag': legacy['tag'],
      'type': type,
    };

    switch (type) {
      case 'dhcp':
        if (hostPort.isNotEmpty && hostPort != 'auto') result['interface'] = hostPort;
        return result;
      case 'fakeip':
        return result..addAll(fakeipRanges);
      case 'local':
        return result..addAll(_dialerFields(legacy, config));
      case 'udp' || 'tcp' || 'tls' || 'quic' || 'https' || 'h3':
        final parsed = _splitHostPort(hostPort);
        if (parsed == null) return null;
        final (host, port) = parsed;
        result['server'] = host;
        if (port != null && port != 0 && port != _defaultPorts[type]) {
          result['server_port'] = port;
        }
        if ((type == 'https' || type == 'h3') && path.isNotEmpty && path != '/dns-query') {
          result['path'] = path;
        }
        // 服务器级的 strategy、client_subnet 不带过去：新写法把它们放在 dns 全局
        // 或规则上，按服务器无法等价迁移
        return result..addAll(_dialerFields(legacy, config));
      default:
        return null;
    }
  }

  /// 旧写法里属于拨号的字段 → 新写法的拨号字段。
  static Map<String, dynamic> _dialerFields(Map<String, dynamic> legacy, Map<String, dynamic> config) {
    final resolver = legacy['address_resolver'];
    final strategy = legacy['address_strategy'];
    final detour = _upgradeDetour(legacy['detour'], config);
    return {
      'detour': ?detour,
      if (resolver is String && resolver.isNotEmpty)
        'domain_resolver': strategy == null ? resolver : {'server': resolver, 'strategy': strategy},
      if (legacy['address_fallback_delay'] != null) 'fallback_delay': legacy['address_fallback_delay'],
    };
  }

  /// 旧写法服务器的 detour → 新写法的 detour，使 1.14 的拨号与 1.13 一致。
  ///
  /// - 没写 detour（或为空字符串）：1.13 用默认出站拨号（route.final 指定的
  ///   出站或 endpoint，没指定时是第一个出站），新写法不写 detour 则是直连，
  ///   所以写上默认出站的 tag；确定不了默认出站时不写。
  /// - detour 指向空 direct（见 [isEmptyDirect]）：1.14 的 DNS 服务器启动时对这种
  ///   detour 报错，而不写 detour 就是直连，与它等价，所以去掉。
  /// - 其余（代理出站、带拨号字段的 direct、订阅里找不到的出站）原样保留。
  static Object? _upgradeDetour(Object? detour, Map<String, dynamic> config) {
    final outbounds = config['outbounds'];
    final list = outbounds is List ? outbounds : const [];
    Map<String, dynamic>? find(Object? tag) =>
        list.whereType<Map<String, dynamic>>().where((o) => o['tag'] == tag).firstOrNull;

    final Map<String, dynamic>? target;
    if (detour != null && detour != '') {
      if (detour is! String) return detour;
      target = find(detour);
      if (target == null) return detour;
    } else {
      final route = config['route'];
      final finalTag = route is Map ? route['final'] : null;
      // route.final 不在 outbounds 里而是 endpoint 的 tag 时，默认出站就是这个
      // endpoint（内核的出站管理器启动时从 endpoint 里取）；endpoint 不会是空 direct
      final endpoints = config['endpoints'];
      if (finalTag is String &&
          finalTag.isNotEmpty &&
          find(finalTag) == null &&
          endpoints is List &&
          endpoints.any((e) => e is Map && e['tag'] == finalTag)) {
        return finalTag;
      }
      final first = list.firstOrNull;
      final byFinal = finalTag is String ? find(finalTag) : null;
      target = byFinal ?? (first is Map<String, dynamic> ? first : null);
      final tag = target?['tag'];
      if (tag is! String || tag.isEmpty) return null;
    }
    return isEmptyDirect(_serialized(target!)) ? null : target['tag'];
  }

  /// 出站经生成模型读入再序列化后的样子：模型没有的字段（例如 direct 的
  /// domain_strategy）在最终产物里会消失，判断空 direct 要以它为准。模型读不进
  /// 时（字段类型不对等）按原始字段判断。
  static Map<String, dynamic> _serialized(Map<String, dynamic> outbound) {
    try {
      return Outbound.fromJson(outbound).toJson();
    } catch (_) {
      return outbound;
    }
  }

  /// direct 出站的拨号字段（不含 detour）。内核解码配置时把这些键的空列表当作没写。
  static const Set<String> _dialerKeys = {
    ..._scalarDialerKeys,
    'inet4_bind_address',
    'inet6_bind_address',
    'connect_timeout',
    'tcp_keep_alive',
    'tcp_keep_alive_interval',
    'udp_fragment',
    'domain_resolver',
    'network_strategy',
    'network_type',
    'fallback_network_type',
    'fallback_delay',
  };

  /// 拨号字段里取零值（空字符串、false、0）时内核按没写处理的键：它们在内核里
  /// 是非指针的标量字段。其余拨号字段是指针或列表，例如 udp_fragment 写 false、
  /// domain_resolver 写空字符串都算已设置。
  static const Set<String> _scalarDialerKeys = {
    'bind_interface',
    'bind_address_no_port',
    'protect_path',
    'routing_mark',
    'reuse_addr',
    'netns',
    'tcp_fast_open',
    'tcp_multi_path',
    'disable_tcp_keep_alive',
    'domain_strategy',
  };

  /// 拨号字段里的时长：内核里是非指针的 Duration，换算成 0 的写法（"0"、"0s"、
  /// "0h0m0s"）等于没写（判法见 [_isZeroDuration]）。
  static const Set<String> _durationDialerKeys = {
    'connect_timeout',
    'tcp_keep_alive',
    'tcp_keep_alive_interval',
    'fallback_delay',
  };

  /// 时长的一段：数字（可带小数点）加单位。小数点固定了整数与小数的分界，
  /// 从上一段的结尾接着匹配（matchAsPrefix），第一次匹配失败就返回，耗时与长度线性。
  static final RegExp _durationSegment = RegExp(r'([0-9]+(?:\.[0-9]*)?|\.[0-9]+)(ns|us|µs|μs|ms|s|m|h)');

  /// 时长字符串是否等于 0：只认 "0" 或每段都是「零 + 单位」的常见写法
  /// （"0s"、"0h0m0s"、"0.0s"）。带正负号、d 单位、小数截断成 0 等罕见写法
  /// 不认，按已设置处理（detour 保留，交给内核报错）。
  static bool _isZeroDuration(String value) {
    if (value == '0') return true;
    var end = 0;
    while (end < value.length) {
      final match = _durationSegment.matchAsPrefix(value, end);
      if (match == null || double.tryParse(match.group(1)!) != 0) return false;
      end = match.end;
    }
    return end > 0;
  }

  /// routing_mark 写成字符串时内核按 Go 的 ParseUint(s, 0, 32) 解析（十进制、
  /// 0x 十六进制、0o 或 0 开头八进制、0b 二进制，数字之间可以有下划线）；
  /// 这里判断它是否解析为 0。解析不了的不算 0。
  static bool _isZeroMark(String s) {
    if (s.isEmpty) return false;
    var digits = s;
    var hasPrefix = false;
    if (s.startsWith('0')) {
      hasPrefix = s.length >= 3 && 'box'.contains(s[1].toLowerCase());
      digits = s.substring(hasPrefix ? 2 : 1);
    }
    // 除 0 与下划线外的字符要么是非零数字，要么解析报错
    if (!RegExp(r'^[0_]*$').hasMatch(digits)) return false;
    if (!digits.contains('_')) return true;
    // 下划线只能夹在数字之间，进制前缀算作数字
    final body = hasPrefix ? '0$digits' : s;
    return !body.startsWith('_') && !body.endsWith('_') && !body.contains('__');
  }

  /// 内核会把这个值当作没写：null（生成的模型序列化时丢掉 null）、拨号字段的
  /// 空列表、[_scalarDialerKeys] 里的键取零值、时长为 0、domain_strategy 为 as_is
  /// （它的零值）。
  static bool _isUnsetDialerValue(String key, Object? value) =>
      value == null ||
      (_dialerKeys.contains(key) && value is List && value.isEmpty) ||
      (key == 'routing_mark' && (value == 0 || value is String && _isZeroMark(value))) ||
      (_scalarDialerKeys.contains(key) && key != 'routing_mark' && (value == '' || value == false || value == 0)) ||
      (_durationDialerKeys.contains(key) && value is String && _isZeroDuration(value)) ||
      (key == 'domain_strategy' && value == 'as_is');

  /// 是否为内核判定的空 direct 出站：type 为 direct，除 type、tag 外的字段都
  /// 等于未设置。1.14 对指向空 direct 的 detour 报错并拒绝启动。
  static bool isEmptyDirect(Map<String, dynamic> outbound) =>
      outbound['type'] == 'direct' &&
      outbound.entries.every((e) => e.key == 'type' || e.key == 'tag' || _isUnsetDialerValue(e.key, e.value));

  /// 拆出主机与端口：`1.1.1.1`、`1.1.1.1:53`、`2001:db8::1`、`[2001:db8::1]:53`。
  static (String, int?)? _splitHostPort(String value) {
    String host = value;
    String? portText;
    if (value.startsWith('[')) {
      final close = value.indexOf(']');
      if (close < 0) return null;
      host = value.substring(1, close);
      final rest = value.substring(close + 1);
      if (rest.isNotEmpty) {
        if (!rest.startsWith(':')) return null;
        portText = rest.substring(1);
      }
    } else if (':'.allMatches(value).length == 1) {
      final colon = value.indexOf(':');
      host = value.substring(0, colon);
      portText = value.substring(colon + 1);
    }
    if (host.isEmpty) return null;
    if (portText == null) return (host, null);
    final port = int.tryParse(portText);
    if (port == null || port < 0 || port > 65535) return null;
    return (host, port);
  }

  // ---------------------------------------------------------------------------
  // 迁移项 2：DNS 规则的 outbound 条件 → domain_resolver
  // 迁移文档「Migrate outbound DNS rule items to domain resolver」。这类规则
  // 只用来指定「解析出站服务器域名时用哪个 DNS」，新写法改由出站的
  // domain_resolver 或 route.default_domain_resolver 指定。生成的模型没有
  // outbound 字段，不升级的话规则读进来只剩 server，变成匹配一切查询的规则。
  // ---------------------------------------------------------------------------

  /// 纯 outbound 规则里除 outbound 外允许出现的键：动作与 route 动作的选项。
  /// 选项在新写法里随 domain_resolver 的对象形式保留。
  static const Set<String> _resolverOptionKeys = {'strategy', 'disable_cache', 'rewrite_ttl', 'client_subnet'};

  /// outbound 是 null 或空列表时不构成条件（1.13 只在非空时匹配出站）。
  static bool _isEmptyOutbound(Object? outbound) => outbound == null || (outbound is List && outbound.isEmpty);

  /// 逻辑规则的子规则（任意深度）里有没有非空的 outbound 条件；空的 outbound
  /// 键顺手去掉，它不构成条件。
  static bool _hasOutboundCondition(Object? subRules) {
    if (subRules is! List) return false;
    var found = false;
    for (final rule in subRules) {
      if (rule is! Map<String, dynamic>) continue;
      if (rule.containsKey('outbound')) {
        if (_isEmptyOutbound(rule['outbound'])) {
          rule.remove('outbound');
        } else {
          found = true;
        }
      }
      if (_hasOutboundCondition(rule['rules'])) found = true;
    }
    return found;
  }

  static void _migrateOutboundDnsRuleItems(Map<String, dynamic> config) {
    final anyResolver = _migrateOutboundRules(config);
    _assignResolverForDroppedDetours(config, anyResolver);
  }

  /// 迁移 outbound 规则，返回生效的 any 规则给出的解析器（没有时为 null）。
  static Object? _migrateOutboundRules(Map<String, dynamic> config) {
    final dns = config['dns'];
    if (dns is! Map<String, dynamic>) return null;
    final rules = dns['rules'];
    if (rules is! List) return null;

    // 旧规则按顺序首条命中：一条 any 规则之后，具体出站的规则再也命中不到
    var anyMatched = false;
    Object? anyResolver;
    final kept = <dynamic>[];
    for (final rule in rules) {
      if (rule is! Map<String, dynamic>) {
        kept.add(rule);
        continue;
      }
      if (rule['type'] == 'logical') {
        // 子规则的 outbound 条件新写法无法表达，生成的子规则模型也没有这个
        // 字段，留着会让条件消失、匹配范围扩大，所以整条去掉
        if (!_hasOutboundCondition(rule['rules'])) kept.add(rule);
        continue;
      }
      if (!rule.containsKey('outbound')) {
        kept.add(rule);
        continue;
      }
      if (_isEmptyOutbound(rule['outbound'])) {
        rule.remove('outbound');
        kept.add(rule);
        continue;
      }
      // 还带别的条件的规则只对部分查询生效，新写法没有等价表达：规则去掉，
      // 不写解析器（这些出站改用默认解析器，不扩大匹配范围）
      // type 为 default 与不写 type 是同一种规则
      final isPure = rule.entries.every(
        (e) =>
            e.key == 'outbound' ||
            e.key == 'server' ||
            e.key == 'action' ||
            (e.key == 'type' && e.value == 'default') ||
            _resolverOptionKeys.contains(e.key),
      );
      final server = rule['server'];
      final action = rule['action'];
      if (isPure && server is String && (action == null || action == 'route')) {
        final outbound = rule['outbound'];
        final targets = <String>{
          if (outbound is String) outbound,
          if (outbound is List) ...outbound.whereType<String>(),
        };
        final options = {
          for (final key in _resolverOptionKeys)
            if (rule[key] != null) key: rule[key],
        };
        final resolver = options.isEmpty ? server : {'server': server, ...options};
        if (!anyMatched) _assignDomainResolver(config, targets, resolver);
        if (targets.contains('any') && !anyMatched) {
          anyMatched = true;
          anyResolver = resolver;
        }
      }
      // 规则本身去掉：它在新写法里已不起作用
    }
    dns['rules'] = kept;
    return anyResolver;
  }

  /// 迁移项 1 去掉了 detour 的服务器（key 是升级后的服务器）→（被去掉的 detour、
  /// 订阅原文的 route.default_domain_resolver）。
  static final Expando<(String, Object?)> _droppedDetours = Expando();

  /// 去掉 detour 的服务器主机是域名时补上 domain_resolver。
  ///
  /// 1.13 里这台服务器经 direct 出站拨号，域名由 direct 出站解析；1.14 对没有
  /// detour 的域名服务器只认它自己的 domain_resolver，没有就报 missing domain
  /// resolver，也不读 route.default_domain_resolver。取值按 1.13 direct 出站解析
  /// 域名的来源顺序：订阅原文的 route.default_domain_resolver → outbound 规则给
  /// 这个 direct 的解析器（迁移后写在 direct 上）或 any 规则的解析器 → dns.servers
  /// 里唯一的另一台服务器。direct 自己写了 domain_resolver 时它不是空 direct，
  /// detour 不会被去掉。解析器不能是服务器自己；都取不到时不写（1.13 同样解析
  /// 不了，交给内核报错）。
  static void _assignResolverForDroppedDetours(Map<String, dynamic> config, Object? anyResolver) {
    final dns = config['dns'];
    if (dns is! Map<String, dynamic>) return;
    final servers = dns['servers'];
    if (servers is! List) return;
    final outbounds = config['outbounds'];
    for (final server in servers) {
      if (server is! Map<String, dynamic>) continue;
      final dropped = _droppedDetours[server];
      final host = server['server'];
      if (dropped == null || host is! String || _isIpLiteral(host) || server.containsKey('domain_resolver')) continue;
      final (directTag, routeResolver) = dropped;
      final direct = outbounds is List
          ? outbounds.whereType<Map<String, dynamic>>().where((o) => o['tag'] == directTag).firstOrNull
          : null;
      final others = servers.whereType<Map<String, dynamic>>().where((s) => !identical(s, server)).toList();
      final candidates = [
        routeResolver,
        direct?['domain_resolver'],
        anyResolver,
        if (others.length == 1) others.single['tag'],
      ];
      for (final candidate in candidates) {
        final target = candidate is Map ? candidate['server'] : candidate;
        if (target is String && target.isNotEmpty && target != server['tag']) {
          server['domain_resolver'] = candidate;
          break;
        }
      }
    }
  }

  /// 主机是 IPv4 或 IPv6 字面量（IPv6 可以带 % 网卡后缀）。
  static bool _isIpLiteral(String host) {
    try {
      Uri.parseIPv4Address(host);
      return true;
    } on FormatException {
      // 不是 IPv4，再看是不是 IPv6
    }
    if (!host.contains(':')) return false;
    try {
      Uri.parseIPv6Address(host.split('%').first);
      return true;
    } on FormatException {
      return false;
    }
  }

  /// 只在没写过的地方补 domain_resolver，前面的规则优先（与规则按顺序匹配一致）。
  /// [resolver] 是服务器 tag，或带 route 选项的对象形式。
  ///
  /// 订阅没有 route 段时不写默认解析器，也不为此新建 route：新建 route 会改变
  /// 主路径与回退路径的选择；回退路径此时用模板的默认解析器。
  static void _assignDomainResolver(
    Map<String, dynamic> config,
    Set<String> targets,
    Object resolver,
  ) {
    if (targets.contains('any')) {
      final route = config['route'];
      if (route is Map<String, dynamic> && !route.containsKey('default_domain_resolver')) {
        route['default_domain_resolver'] = resolver;
      }
      return;
    }
    final outbounds = config['outbounds'];
    if (outbounds is! List) return;
    for (final outbound in outbounds) {
      if (outbound is Map<String, dynamic> &&
          targets.contains(outbound['tag']) &&
          !outbound.containsKey('domain_resolver')) {
        outbound['domain_resolver'] = resolver;
      }
    }
  }
}
