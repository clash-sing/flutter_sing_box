// 本文件由 tool/gen_models.dart 生成，勿手改。
import 'package:json_annotation/json_annotation.dart';

import 'dns.dart';
import 'experimental_options.dart';
import 'inbound/inbound.dart';
import 'log_options.dart';
import 'outbound/outbound.dart';
import 'route_options.dart';

part 'sing_box.g.dart';

/// sing-box 配置顶层模型，对应整份配置 JSON。
@JsonSerializable(explicitToJson: true, includeIfNull: false)
class SingBox {
  static const _knownKeys = {'log', 'dns', 'inbounds', 'outbounds', 'route', 'experimental'};

  /// 顶层 `log` 配置段（可空）。
  LogOptions? log;
  /// 顶层 `dns` 配置段（必填）。
  DNS dns;
  /// 顶层 `inbounds` 列表（必填）。
  List<Inbound> inbounds;
  /// 顶层 `outbounds` 列表（必填）。
  List<Outbound> outbounds;
  /// 顶层 `route` 配置段（必填）。
  RouteOptions route;
  /// 顶层 `experimental` 配置段（可空）。
  ExperimentalOptions? experimental;

  /// 未建模顶层段（ntp 等）原样透传：读入收存、输出合并。
  @JsonKey(includeFromJson: false, includeToJson: false)
  final Map<String, dynamic> unknownSections = {};

  /// 构造顶层配置；可空段省略时为 `null`。
  SingBox({
    this.log,
    required this.dns,
    required this.inbounds,
    required this.outbounds,
    required this.route,
    this.experimental,
  });

  /// 从整份配置 JSON 反序列化；未建模顶层段收入 [unknownSections]。
  factory SingBox.fromJson(Map<String, dynamic> json) {
    final result = _$SingBoxFromJson(json);
    json.forEach((key, value) {
      if (!_knownKeys.contains(key)) result.unknownSections[key] = value;
    });
    return result;
  }

  /// 序列化为 JSON；[unknownSections] 原样合并输出。
  Map<String, dynamic> toJson() {
    final result = _$SingBoxToJson(this);
    result.addAll(unknownSections);
    return result;
  }
}
