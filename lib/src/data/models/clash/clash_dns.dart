import 'package:json_annotation/json_annotation.dart';

part 'clash_dns.g.dart';

/// Clash DNS 配置段。
@JsonSerializable(explicitToJson: true)
class ClashDns {
  /// 域名到上游 DNS 列表的分流策略（对应 JSON 键 `nameserver-policy`）。
  @JsonKey(name: 'nameserver-policy')
  final Map<String, List<String>>? nameserverPolicy;
  /// 构造 DNS 配置段。
  ClashDns({this.nameserverPolicy});

  /// 从 JSON 反序列化。
  factory ClashDns.fromJson(Map<String, dynamic> json) => _$ClashDnsFromJson(json);

  /// 序列化为 JSON。
  Map<String, dynamic> toJson() => _$ClashDnsToJson(this);
}
