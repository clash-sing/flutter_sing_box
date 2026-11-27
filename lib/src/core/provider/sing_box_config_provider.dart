import 'dart:convert';

import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
// 旧拍平模型已删除，gen 生成模型经包级 barrel 导出，直接引入即可
import 'package:flutter_sing_box/flutter_sing_box.dart';
import 'package:yaml/yaml.dart';

import 'sing_box_legacy_upgrader.dart';

/// Builds a normalized [SingBox] config from raw subscription content.
class SingBoxConfigProvider {

  /// Parses [data] into a [SingBox] config.
  ///
  /// [data] may be a [Map], a JSON string, a YAML string, or a Base64 string.
  /// Throws an [Exception] if the content cannot be parsed.
  static Future<SingBox> provide(final dynamic data) async {
    SingBox? singBox;
    Exception? exception;
    try {
      if (data is Map<String, dynamic>) {
        // 先把旧版写法升级成当前内核认的写法，主路径与回退路径都用升级后的配置
        final config = SingBoxLegacyUpgrader.upgrade(data);
        try {
          singBox = SingBox.fromJson(config);
        } catch (e) {
          exception = e is Error ? Exception('Error: $e') : e as Exception;
          singBox = await _fixSingBoxConfig(config);
        }
      } else if (data is String) {
        final String content = data.trim();
        if (content.startsWith("{") && content.endsWith("}")) {
          // 可能是 json (sing-box) 格式
          final Map<String, dynamic> singBoxMap = SingBoxLegacyUpgrader.upgrade(jsonDecode(data));
          try {
            singBox = SingBox.fromJson(singBoxMap);
          } catch (e) {
            exception = e is Error ? Exception('Error: $e') : e as Exception;
            singBox = await _fixSingBoxConfig(singBoxMap);
          }
        } else if (content.split(RegExp(r'\r?\n')).first.contains(':')) {
          // 可能是 yaml 格式
          final YamlMap yamlMap = loadYaml(data);
          final (outbounds, dns) = ClashProvider.provide(yamlMap);
          final List<Map<String, dynamic>> outboundsMap = outbounds
              .map((element) => element.toJson())
              .toList();
          final Map<String, dynamic> singBoxMap = {
            "outbounds": outboundsMap,
            if (dns != null) "dns": dns.toJson(),
          };
          singBox = await _fixSingBoxConfig(singBoxMap);
        } else {
          // 可能是 base64 格式
          final outbounds = Base64Provider.provide(data);
          if (outbounds.isEmpty) {
            throw Exception("Invalid base64 string");
          }
          outbounds.insert(
            0,
            UrltestOutbound(tag: 'Auto')
              ..outbounds = outbounds.map((element) => element.tag).toList(),
          );
          outbounds.insert(
            0,
            SelectorOutbound(tag: FlutterSingBoxConstants.defaultGroup)
              ..outbounds = outbounds.map((element) => element.tag).toList(),
          );
          final List<Map<String, dynamic>> listMap = outbounds
              .map((element) => element.toJson())
              .toList();
          singBox = await _fixSingBoxConfig({"outbounds": listMap});
        }
      }
    } catch (e) {
      exception = e is Error ? Exception('Error: $e') : e as Exception;
      debugPrint(e.toString());
    }
    if (singBox != null) {
      // 导入即校验：三路格式（JSON/YAML/Base64）在此汇合，放行式记日志
      await validateOrLog(singBox);
      return singBox;
    } else {
      singBox = throw exception ?? Exception("Invalid content");
    }
  }

  /// 导入订阅后对生成的配置做 schema 校验，问题只记日志、不阻断导入。
  ///
  /// 故意放行而非报错：schema 的 additionalProperties 很严格，订阅携带
  /// 新版内核字段或订阅商私有扩展字段时会被判不合法，而内核本身宽容
  /// 忽略这些字段——校验的价值在于暴露结构问题，不应挡住现在能用的
  /// 订阅。校验器自身故障（asset 加载失败等）同样只记日志跳过。
  ///
  /// [validatorSource] 仅供测试注入校验器构建方式。
  @visibleForTesting
  static Future<void> validateOrLog(
    SingBox singBox, {
    Future<SingBoxSchemaValidator> Function()? validatorSource,
  }) async {
    try {
      final validator = await (validatorSource?.call() ?? SingBoxSchemaValidator.instance());
      final config = singBox.toJson();
      final errors = validator.validateSync(config);
      if (errors.isNotEmpty) {
        // 节点多的订阅错误可能成片，截断输出避免刷屏
        const maxShown = 10;
        debugPrint(
          '订阅配置未通过 sing-box schema 校验'
          '（共 ${errors.length} 处，仅记录不阻断）:',
        );
        for (final error in errors.take(maxShown)) {
          debugPrint('  ${error.toErrorString()}');
          // oneOf/anyOf 汇总错误只有一句 "matched 0"，附二次诊断展开原因
          for (final line in validator.diagnoseCombinatorError(config, error)) {
            debugPrint('      ↳ $line');
          }
        }
        if (errors.length > maxShown) {
          debugPrint('  ...其余 ${errors.length - maxShown} 处略');
        }
      }
    } catch (e) {
      debugPrint('schema 校验器不可用，跳过校验: $e');
    }
  }

  /// DNS 规则（含逻辑规则的子规则）引用到的规则集标签。
  static Iterable<String> _referencedRuleSets(dynamic rule) sync* {
    if (rule is! Map) return;
    final ruleSet = rule['rule_set'];
    if (ruleSet is String) yield ruleSet;
    if (ruleSet is List) yield* ruleSet.whereType<String>();
    final subRules = rule['rules'];
    if (subRules is List) {
      for (final subRule in subRules) {
        yield* _referencedRuleSets(subRule);
      }
    }
  }

  static Future<SingBox?> _fixSingBoxConfig(Map<String, dynamic> data) async {
    final defaultConfig = await rootBundle.loadString(FlutterSingBoxConstants.templateConfig);
    final jsonConfig = jsonDecode(defaultConfig);
    final defaultSingBox = SingBox.fromJson(jsonConfig);
    // 内置远程规则集本地兜底（clash_sing_app#27）：模板里的 geoip-cn /
    // geosite-cn 无缓存时会被内核同步下载，失败则整份配置起不来。
    // 这里给可识别的官方规则集写上本地 initial_path；失败静默跳过。
    await RuleSetAssets.applyInitialPaths(defaultSingBox);
    if (data.containsKey("dns")) {
      final List<DNSServer> subscriptionServers = (data['dns']['servers'] as List<dynamic>)
          .map((e) => DNSServer.fromJson(e as Map<String, dynamic>))
          .toList();
      // 与模板按 tag 合并去重，订阅同名时顶替模板项（即 sing-box 1.14.2
      // “后加覆盖前一个”的历史行为）：1.14.3 起内核对重名 tag 直接报
      // duplicate DNS server tag，不去重会让整份配置起不来。
      defaultSingBox.dns.servers = <String, DNSServer>{
        for (final server in [...?defaultSingBox.dns.servers, ...subscriptionServers])
          server.tag: server,
      }.values.toList();
      // 回退路径用模板的 route，订阅自己定义的规则集不会带过来：引用了模板里
      // 没有的规则集的 DNS 规则不并入，否则内核报 rule-set not found 拒收整份配置
      final ruleSetTags = {...?defaultSingBox.route.ruleSet?.map((ruleSet) => ruleSet.tag)};
      (defaultSingBox.dns.rules ??= []).insertAll(
        0,
        (data['dns']['rules'] as List<dynamic>)
            .where((e) => _referencedRuleSets(e).every(ruleSetTags.contains))
            .map((e) => DNSRule.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
    }
    // 回退路径用模板的 route；订阅的 route 里指定了默认域名解析器（例如旧写法
    // outbound: any 的 DNS 规则迁移得到的），且它指向的服务器在合并后存在时，
    // 用它顶替模板的值。指向不存在的服务器时保留模板的值，避免内核报找不到服务器
    final route = data['route'];
    final resolver = route is Map ? route['default_domain_resolver'] : null;
    final resolverServer = resolver is Map ? resolver['server'] : resolver;
    if (resolverServer is String &&
        (defaultSingBox.dns.servers ?? []).any((server) => server.tag == resolverServer)) {
      defaultSingBox.route.defaultDomainResolver = resolver;
    }

    final List<String> errorTags = [];
    List<dynamic> outbounds = data['outbounds'];
    for (var outbound in outbounds) {
      Outbound? sbOutbound;
      try {
        // 以 gen 注册表 kOutboundTypeNames（与 OutboundType 常量表经对齐测试
        // 锁定同步）为放行依据：已建模类型全量放行，未建模类型仍静默丢弃
        // （不透传 UnknownOutbound 进配置）；block 已被 sing-box 废弃，显式排除
        final type = outbound['type'];
        if (type is String &&
            type != OutboundType.block &&
            kOutboundTypeNames.contains(type)) {
          sbOutbound = Outbound.fromJson(outbound);
        }
      } catch (e) {
        errorTags.add(outbound["tag"]);
      }
      if (sbOutbound != null) {
        defaultSingBox.outbounds.add(sbOutbound);
      }
    }
    final allTags = defaultSingBox.outbounds.map((outbound) => outbound.tag).toList();
    final groups = defaultSingBox.outbounds.takeWhile(_isGroupOutbound).toList();
    final List<String> emptyGroups = [];
    for (var group in groups) {
      if (group is SelectorOutbound) {
        final defaultTag = group.default_;
        if (defaultTag?.isNotEmpty == true && errorTags.contains(defaultTag)) {
          // 移除错误的 默认 tag
          group.default_ = null;
        }
      }
      final members = _groupMembers(group);
      members?.removeWhere((tag) => !allTags.contains(tag));
      // sing-box 不支持只有一个出站的代理组 ！！
      if (members?.isEmpty == true || members?.length == 1) {
        emptyGroups.add(group.tag);
      }
    }
    if (emptyGroups.isNotEmpty) {
      _removeEmptyGroup(emptyGroups: emptyGroups, allGroups: groups, singBox: defaultSingBox);
    }

    if (defaultSingBox.outbounds.indexWhere((outbound) => outbound.type == OutboundType.direct) ==
        -1) {
      // 查找最后一个 group 的索引
      final index = defaultSingBox.outbounds.lastIndexWhere(_isGroupOutbound);
      final directOutbound = DirectOutbound(tag: OutboundType.direct);
      defaultSingBox.outbounds.insert(index + 1, directOutbound);
    }
    _fixOutboundInRoute(defaultSingBox);
    _fixDnsServerDetour(defaultSingBox);
    return defaultSingBox;
  }

  /// 删除空代理组
  static void _removeEmptyGroup({
    required List<String> emptyGroups,
    required List<Outbound> allGroups,
    required SingBox singBox,
  }) {
    final List<String> tempEmptyGroups = [];
    allGroups.removeWhere((group) => emptyGroups.contains(group.tag));
    singBox.outbounds.removeWhere((group) => emptyGroups.contains(group.tag));
    for (var group in allGroups) {
      final members = _groupMembers(group);
      members?.removeWhere((tag) => emptyGroups.contains(tag));
      // sing-box 不支持只有一个出站的代理组 ！！
      if (members?.isEmpty == true || members?.length == 1) {
        tempEmptyGroups.add(group.tag);
      }
    }
    if (tempEmptyGroups.isNotEmpty) {
      emptyGroups.clear();
      emptyGroups.addAll(tempEmptyGroups);
      // 递归删除空代理组，直到没有空代理组为止
      _removeEmptyGroup(emptyGroups: emptyGroups, allGroups: allGroups, singBox: singBox);
    }
  }

  /// 修复路由中的默认出站
  static void _fixOutboundInRoute(SingBox singBox) {
    List<String> tags = singBox.outbounds.map((element) => element.tag).toList();
    if (!tags.contains(singBox.route.final_)) {
      final firstOutbound = singBox.outbounds.firstWhere(
        (element) => element.type == OutboundType.selector,
      );
      singBox.route.final_ = firstOutbound.tag;
    }
    for (var routeRule in singBox.route.rules ?? []) {
      if (routeRule.outbound?.isNotEmpty ?? false) {
        if (routeRule.outbound != OutboundType.direct &&
            routeRule.outbound != singBox.route.final_) {
          routeRule.outbound = singBox.route.final_;
        }
      }
    }
  }

  /// 修正 DNS 服务器的 detour：删组后订阅原文写的、或升级器补写的 detour 可能
  /// 指向已不存在的出站，内核启动时报 outbound detour not found。与路由规则的
  /// 处理一致，改为修正后的 route.final；route.final 是空 direct 时去掉 detour
  /// （内核对指向空 direct 的 detour 报错，不写 detour 就是直连）。detour 指向的
  /// 出站存在、但是空 direct（例如订阅没有 direct，回退时补进来的那个）时同样去掉。
  static void _fixDnsServerDetour(SingBox singBox) {
    final byTag = {for (final outbound in singBox.outbounds) outbound.tag: outbound};
    bool isEmptyDirect(Outbound? outbound) =>
        outbound != null && SingBoxLegacyUpgrader.isEmptyDirect(outbound.toJson());
    final finalTag = singBox.route.final_;
    final dropDetour = isEmptyDirect(byTag[finalTag]);
    singBox.dns.servers = singBox.dns.servers?.map((server) {
      final json = server.toJson();
      final detour = json['detour'];
      if (detour is! String || detour.isEmpty) return server;
      if (byTag.containsKey(detour)) {
        if (!isEmptyDirect(byTag[detour])) return server;
        json.remove('detour');
        return DNSServer.fromJson(json);
      }
      if (dropDetour) {
        json.remove('detour');
      } else {
        json['detour'] = finalTag;
      }
      return DNSServer.fromJson(json);
    }).toList();
  }

  /// 组出站（selector/urltest）的成员列表；判别基类未收敛 outbounds 字段，
  /// 经模式收窄读取，非组出站返回 null。
  static List<String>? _groupMembers(Outbound outbound) => switch (outbound) {
    SelectorOutbound(:final outbounds) => outbounds,
    UrltestOutbound(:final outbounds) => outbounds,
    _ => null,
  };

  /// 是否为带非空成员列表的组出站。
  static bool _isGroupOutbound(Outbound outbound) => _groupMembers(outbound)?.isNotEmpty == true;
}
