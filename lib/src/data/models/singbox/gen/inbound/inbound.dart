// 本文件由 tool/gen_models.dart 生成，勿手改。
import 'package:json_annotation/json_annotation.dart';

import '../inbound_tls_options.dart';
import '../shared/dialer_fields.dart';
import '../shared/listen_fields.dart';
import '../tun_platform_options.dart';
import '../user.dart';

part 'mixed_inbound.dart';
part 'tun_inbound.dart';
part 'unknown_inbound.dart';

part 'inbound.g.dart';

/// 入站配置，按 type 判别的密封类层级。
sealed class Inbound {
  const Inbound();

  String get tag;
  String get type;

  /// 子类输出须带 type 判别键（round-trip 保真的关键）。
  Map<String, dynamic> toJson();

  /// 按 type 判别反序列化；未知类型进 [UnknownInbound] 透传。
  factory Inbound.fromJson(Map<String, dynamic> json) {
    final type = json['type'] as String?;
    return switch (type) {
      'mixed' => MixedInbound.fromJson(json),
      'tun' => TunInbound.fromJson(json),
      _ => UnknownInbound.fromJson(json),
    };
  }
}

/// 白名单内全部入站类型名（对齐测试的数据源）。
const Set<String> kInboundTypeNames = {'mixed', 'tun'};
