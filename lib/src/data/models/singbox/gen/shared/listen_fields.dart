// 本文件由 tool/gen_models.dart 生成，勿手改。
import 'package:json_annotation/json_annotation.dart';

/// 监听共享字段（白名单入站分支共有属性），字段一律可空。
mixin ListenFields {
  String? netns;
  @JsonKey(name: 'udp_timeout')
  Object? udpTimeout;
}
