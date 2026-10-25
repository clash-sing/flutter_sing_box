// 本文件由 tool/gen_models.dart 生成，勿手改。
import 'package:json_annotation/json_annotation.dart';

import 'brutal_options.dart';

part 'outbound_multiplex_options.g.dart';

/// 由官方 JSON schema `$defs/OutboundMultiplexOptions` 定义的配置模型。
@JsonSerializable(explicitToJson: true, includeIfNull: false)
class OutboundMultiplexOptions {
  /// 对应 JSON 键 `enabled`，可空（null 不参与序列化）。
  bool? enabled;
  /// 对应 JSON 键 `protocol`，可空（null 不参与序列化）。
  String? protocol;
  /// 对应 JSON 键 `max_connections`，可空（null 不参与序列化）。
  @JsonKey(name: 'max_connections')
  int? maxConnections;
  /// 对应 JSON 键 `min_streams`，可空（null 不参与序列化）。
  @JsonKey(name: 'min_streams')
  int? minStreams;
  /// 对应 JSON 键 `max_streams`，可空（null 不参与序列化）。
  @JsonKey(name: 'max_streams')
  int? maxStreams;
  /// 对应 JSON 键 `padding`，可空（null 不参与序列化）。
  bool? padding;
  /// 对应 JSON 键 `brutal`，可空（null 不参与序列化）。
  BrutalOptions? brutal;

  /// 构造实例；可空字段省略时为 `null`。
  OutboundMultiplexOptions();

  /// 从 JSON 对象反序列化为本类型。
  factory OutboundMultiplexOptions.fromJson(Map<String, dynamic> json) =>
      _$OutboundMultiplexOptionsFromJson(json);

  /// 序列化为 JSON 对象。
  Map<String, dynamic> toJson() => _$OutboundMultiplexOptionsToJson(this);
}
