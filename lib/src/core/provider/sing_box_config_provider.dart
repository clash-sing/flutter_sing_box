import 'dart:convert';

import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import 'package:flutter_sing_box/flutter_sing_box.dart';
import 'package:yaml/yaml.dart';

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
        try {
          singBox = SingBox.fromJson(data);
        } catch (e) {
          exception = e is Error ? Exception('Error: $e') : e as Exception;
          singBox = await _fixSingBoxConfig(data);
        }
      } else if (data is String) {
        final String content = data.trim();
        if (content.startsWith("{") && content.endsWith("}")) {
          // 可能是 json (sing-box) 格式
          final Map<String, dynamic> singBoxMap = jsonDecode(data);
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
            Outbound(
              tag: 'Auto',
              type: OutboundType.urltest,
              outbounds: outbounds.map((element) => element.tag).toList(),
            ),
          );
          outbounds.insert(
            0,
            Outbound(
              tag: FlutterSingBoxConstants.defaultGroup,
              type: OutboundType.selector,
              outbounds: outbounds.map((element) => element.tag).toList(),
            ),
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

  static Future<SingBox?> _fixSingBoxConfig(Map<String, dynamic> data) async {
    final defaultConfig = await rootBundle.loadString(FlutterSingBoxConstants.templateConfig);
    final jsonConfig = jsonDecode(defaultConfig);
    final defaultSingBox = SingBox.fromJson(jsonConfig);
    if (data.containsKey("dns")) {
      defaultSingBox.dns.servers.addAll(
        (data['dns']['servers'] as List<dynamic>)
            .map((e) => Server.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
      defaultSingBox.dns.rules.insertAll(
        0,
        (data['dns']['rules'] as List<dynamic>)
            .map((e) => DnsRule.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
    }

    final List<String> errorTags = [];
    List<dynamic> outbounds = data['outbounds'];
    for (var outbound in outbounds) {
      Outbound? sbOutbound;
      try {
        switch (outbound['type']) {
          case OutboundType.selector:
            sbOutbound = Outbound.fromJson(outbound);
            break;
          case OutboundType.urltest:
            sbOutbound = Outbound.fromJson(outbound);
            break;
          case OutboundType.direct:
            sbOutbound = Outbound.fromJson(outbound);
            break;
          case OutboundType.hysteria2:
            sbOutbound = Outbound.fromJson(outbound);
            break;
          case OutboundType.hysteria:
            sbOutbound = Outbound.fromJson(outbound);
            break;
          case OutboundType.trojan:
            sbOutbound = Outbound.fromJson(outbound);
            break;
          case OutboundType.anytls:
            sbOutbound = Outbound.fromJson(outbound);
            break;
          case OutboundType.vmess:
            sbOutbound = Outbound.fromJson(outbound);
            break;
          case OutboundType.vless:
            sbOutbound = Outbound.fromJson(outbound);
            break;
          case OutboundType.tuic:
            sbOutbound = Outbound.fromJson(outbound);
            break;
          case OutboundType.naive:
            sbOutbound = Outbound.fromJson(outbound);
            break;
          default:
            break;
        }
      } catch (e) {
        errorTags.add(outbound["tag"]);
      }
      if (sbOutbound != null) {
        defaultSingBox.outbounds.add(sbOutbound);
      }
    }
    final allTags = defaultSingBox.outbounds.map((outbound) => outbound.tag).toList();
    final groups = defaultSingBox.outbounds
        .takeWhile((outbound) => outbound.outbounds?.isNotEmpty == true)
        .toList();
    final List<String> emptyGroups = [];
    for (var group in groups) {
      if (group.defaultTag?.isNotEmpty == true && errorTags.contains(group.defaultTag)) {
        // 移除错误的 默认 tag
        group.defaultTag = null;
      }
      group.outbounds?.removeWhere((tag) => !allTags.contains(tag));
      // sing-box 不支持只有一个出站的代理组 ！！
      if (group.outbounds?.isEmpty == true || group.outbounds?.length == 1) {
        emptyGroups.add(group.tag);
      }
    }
    if (emptyGroups.isNotEmpty) {
      _removeEmptyGroup(emptyGroups: emptyGroups, allGroups: groups, singBox: defaultSingBox);
    }

    if (defaultSingBox.outbounds.indexWhere((outbound) => outbound.type == OutboundType.direct) ==
        -1) {
      // 查找最后一个 group 的索引
      final index = defaultSingBox.outbounds.lastIndexWhere(
        (outbound) => outbound.outbounds?.isNotEmpty == true,
      );
      final directOutbound = Outbound(tag: OutboundType.direct, type: OutboundType.direct);
      defaultSingBox.outbounds.insert(index + 1, directOutbound);
    }
    _fixOutboundInRoute(defaultSingBox);
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
      group.outbounds?.removeWhere((tag) => emptyGroups.contains(tag));
      // sing-box 不支持只有一个出站的代理组 ！！
      if (group.outbounds?.isEmpty == true || group.outbounds?.length == 1) {
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
    if (!tags.contains(singBox.route.routeFinal)) {
      final firstOutbound = singBox.outbounds.firstWhere(
        (element) => element.type == OutboundType.selector,
      );
      singBox.route.routeFinal = firstOutbound.tag;
    }
    for (var routeRule in singBox.route.rules) {
      if (routeRule.outbound?.isNotEmpty ?? false) {
        if (routeRule.outbound != OutboundType.direct &&
            routeRule.outbound != singBox.route.routeFinal) {
          routeRule.outbound = singBox.route.routeFinal;
        }
      }
    }
  }
}
