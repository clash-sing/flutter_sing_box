// 本文件由 tool/gen_models.dart 生成，勿手改。
import 'package:json_annotation/json_annotation.dart';

import 'dns.dart';
import 'experimental_options.dart';
import 'inbound/inbound.dart';
import 'log_options.dart';
import 'outbound/outbound.dart';
import 'route_options.dart';

part 'sing_box.g.dart';

@JsonSerializable(explicitToJson: true, includeIfNull: false)
class SingBox {
  static const _knownKeys = {'log', 'dns', 'inbounds', 'outbounds', 'route', 'experimental'};

  LogOptions? log;
  DNS dns;
  List<Inbound> inbounds;
  List<Outbound> outbounds;
  RouteOptions route;
  ExperimentalOptions? experimental;

  /// 未建模顶层段（ntp 等）原样透传：读入收存、输出合并。
  @JsonKey(includeFromJson: false, includeToJson: false)
  final Map<String, dynamic> unknownSections = {};

  SingBox({
    this.log,
    required this.dns,
    required this.inbounds,
    required this.outbounds,
    required this.route,
    this.experimental,
  });

  factory SingBox.fromJson(Map<String, dynamic> json) {
    final result = _$SingBoxFromJson(json);
    json.forEach((key, value) {
      if (!_knownKeys.contains(key)) result.unknownSections[key] = value;
    });
    return result;
  }

  Map<String, dynamic> toJson() {
    final result = _$SingBoxToJson(this);
    result.addAll(unknownSections);
    return result;
  }
}
