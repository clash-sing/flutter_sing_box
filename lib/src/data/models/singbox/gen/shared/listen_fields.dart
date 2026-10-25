// 本文件由 tool/gen_models.dart 生成，勿手改。
import 'package:json_annotation/json_annotation.dart';

/// 监听共享字段（白名单入站分支共有属性），字段一律可空。
mixin ListenFields {
  /// 对应 JSON 键 `netns`，可空（null 不参与序列化）。
  String? netns;
  /// 对应 JSON 键 `udp_timeout`，可空（null 不参与序列化）。
  @JsonKey(name: 'udp_timeout')
  Object? udpTimeout;
}
