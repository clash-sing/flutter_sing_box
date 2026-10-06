// 本文件由 tool/gen_models.dart 生成，勿手改。
import 'package:json_annotation/json_annotation.dart';

import 'dns_rule.dart';
import 'dns_server/dns_server.dart';

part 'dns.g.dart';

@JsonSerializable(explicitToJson: true, includeIfNull: false)
class DNS {
  List<DNSServer>? servers;
  List<DNSRule>? rules;
  @JsonKey(name: 'final')
  String? final_;
  @JsonKey(name: 'reverse_mapping')
  bool? reverseMapping;
  Object? strategy;
  String? timeout;
  @JsonKey(name: 'disable_cache')
  bool? disableCache;
  @JsonKey(name: 'disable_expire')
  bool? disableExpire;
  @JsonKey(name: 'cache_capacity')
  int? cacheCapacity;
  Object? optimistic;
  @JsonKey(name: 'client_subnet')
  Object? clientSubnet;

  DNS();

  factory DNS.fromJson(Map<String, dynamic> json) =>
      _$DNSFromJson(json);

  Map<String, dynamic> toJson() => _$DNSToJson(this);
}
