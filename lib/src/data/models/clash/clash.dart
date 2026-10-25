import 'package:flutter_sing_box/src/data/models/clash/clash_dns.dart';
import 'package:json_annotation/json_annotation.dart';

import 'clash_group.dart';
import 'clash_proxy.dart';

part 'clash.g.dart';

/// Clash 配置顶层模型（YAML 订阅解析后的中间形态，供转换为 sing-box 配置）。
@JsonSerializable(explicitToJson: true)
class Clash {
  /// DNS 配置段，可空。
  ClashDns? dns;
  /// 代理节点列表。
  List<ClashProxy> proxies;
  /// 代理分组列表（对应 JSON 键 `proxy-groups`）。
  @JsonKey(name: "proxy-groups")
  List<ClashGroup> proxyGroups;

  /// 构造 Clash 配置模型。
  Clash({this.dns, required this.proxies, required this.proxyGroups});

  /// 从 JSON 反序列化。
  factory Clash.fromJson(Map<String, dynamic> json) => _$ClashFromJson(json);

  /// 序列化为 JSON。
  Map<String, dynamic> toJson() => _$ClashToJson(this);
}
