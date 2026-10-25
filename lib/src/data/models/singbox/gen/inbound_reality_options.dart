// 本文件由 tool/gen_models.dart 生成，勿手改。
import 'package:json_annotation/json_annotation.dart';

import 'inbound_reality_handshake_options.dart';

part 'inbound_reality_options.g.dart';

/// 由官方 JSON schema `$defs/InboundRealityOptions` 定义的配置模型。
@JsonSerializable(explicitToJson: true, includeIfNull: false)
class InboundRealityOptions {
  /// 对应 JSON 键 `enabled`，可空（null 不参与序列化）。
  bool? enabled;
  /// 对应 JSON 键 `handshake`，可空（null 不参与序列化）。
  InboundRealityHandshakeOptions? handshake;
  /// 对应 JSON 键 `private_key`，可空（null 不参与序列化）。
  @JsonKey(name: 'private_key')
  String? privateKey;
  /// 对应 JSON 键 `short_id`，可空（null 不参与序列化）。
  @JsonKey(name: 'short_id')
  Object? shortId;
  /// 对应 JSON 键 `max_time_difference`，可空（null 不参与序列化）。
  @JsonKey(name: 'max_time_difference')
  String? maxTimeDifference;

  /// 构造实例；可空字段省略时为 `null`。
  InboundRealityOptions();

  /// 从 JSON 对象反序列化为本类型。
  factory InboundRealityOptions.fromJson(Map<String, dynamic> json) =>
      _$InboundRealityOptionsFromJson(json);

  /// 序列化为 JSON 对象。
  Map<String, dynamic> toJson() => _$InboundRealityOptionsToJson(this);
}
