// 本文件由 tool/gen_models.dart 生成，勿手改。
import 'package:json_annotation/json_annotation.dart';

import 'dns_rule.dart';
import 'dns_server/dns_server.dart';

part 'dns.g.dart';

/// 顶层 `dns` 配置段模型。
@JsonSerializable(explicitToJson: true, includeIfNull: false)
class DNS {
  /// 对应 JSON 键 `servers`，可空（null 不参与序列化）。
  List<DNSServer>? servers;
  /// 对应 JSON 键 `rules`，可空（null 不参与序列化）。
  List<DNSRule>? rules;
  /// 对应 JSON 键 `final`，可空（null 不参与序列化）。
  @JsonKey(name: 'final')
  String? final_;
  /// 对应 JSON 键 `reverse_mapping`，可空（null 不参与序列化）。
  @JsonKey(name: 'reverse_mapping')
  bool? reverseMapping;
  /// 对应 JSON 键 `strategy`，可空（null 不参与序列化）。
  Object? strategy;
  /// 对应 JSON 键 `timeout`，可空（null 不参与序列化）。
  String? timeout;
  /// 对应 JSON 键 `disable_cache`，可空（null 不参与序列化）。
  @JsonKey(name: 'disable_cache')
  bool? disableCache;
  /// 对应 JSON 键 `disable_expire`，可空（null 不参与序列化）。
  @JsonKey(name: 'disable_expire')
  bool? disableExpire;
  /// 对应 JSON 键 `cache_capacity`，可空（null 不参与序列化）。
  @JsonKey(name: 'cache_capacity')
  int? cacheCapacity;
  /// 对应 JSON 键 `optimistic`，可空（null 不参与序列化）。
  Object? optimistic;
  /// 对应 JSON 键 `client_subnet`，可空（null 不参与序列化）。
  @JsonKey(name: 'client_subnet')
  Object? clientSubnet;

  /// 构造实例；可空字段省略时为 `null`。
  DNS();

  /// 从 JSON 对象反序列化为本类型。
  factory DNS.fromJson(Map<String, dynamic> json) =>
      _$DNSFromJson(json);

  /// 序列化为 JSON 对象。
  Map<String, dynamic> toJson() => _$DNSToJson(this);
}
