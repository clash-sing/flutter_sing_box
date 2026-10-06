// 本文件由 tool/gen_models.dart 生成，勿手改。
import 'package:json_annotation/json_annotation.dart';

import '../http_header.dart';
import '../hysteria2_realm.dart';
import '../outbound_multiplex_options.dart';
import '../outbound_tls_options.dart';
import '../shared/dialer_fields.dart';
import '../v2_ray_transport.dart';

part 'anytls_outbound.dart';
part 'block_outbound.dart';
part 'direct_outbound.dart';
part 'http_outbound.dart';
part 'hysteria_outbound.dart';
part 'hysteria2_outbound.dart';
part 'naive_outbound.dart';
part 'selector_outbound.dart';
part 'shadowsocks_outbound.dart';
part 'shadowtls_outbound.dart';
part 'snell_outbound.dart';
part 'socks_outbound.dart';
part 'trojan_outbound.dart';
part 'tuic_outbound.dart';
part 'urltest_outbound.dart';
part 'vless_outbound.dart';
part 'vmess_outbound.dart';
part 'unknown_outbound.dart';

part 'outbound.g.dart';

/// 出站配置，按 type 判别的密封类层级。
sealed class Outbound {
  const Outbound();

  String get tag;
  String get type;

  /// 子类输出须带 type 判别键（round-trip 保真的关键）。
  Map<String, dynamic> toJson();

  /// 按 type 判别反序列化；未知类型进 [UnknownOutbound] 透传。
  factory Outbound.fromJson(Map<String, dynamic> json) {
    final type = json['type'] as String?;
    return switch (type) {
      'anytls' => AnytlsOutbound.fromJson(json),
      'block' => BlockOutbound.fromJson(json),
      'direct' => DirectOutbound.fromJson(json),
      'http' => HttpOutbound.fromJson(json),
      'hysteria' => HysteriaOutbound.fromJson(json),
      'hysteria2' => Hysteria2Outbound.fromJson(json),
      'naive' => NaiveOutbound.fromJson(json),
      'selector' => SelectorOutbound.fromJson(json),
      'shadowsocks' => ShadowsocksOutbound.fromJson(json),
      'shadowtls' => ShadowtlsOutbound.fromJson(json),
      'snell' => SnellOutbound.fromJson(json),
      'socks' => SocksOutbound.fromJson(json),
      'trojan' => TrojanOutbound.fromJson(json),
      'tuic' => TuicOutbound.fromJson(json),
      'urltest' => UrltestOutbound.fromJson(json),
      'vless' => VlessOutbound.fromJson(json),
      'vmess' => VmessOutbound.fromJson(json),
      _ => UnknownOutbound.fromJson(json),
    };
  }
}

/// 白名单内全部出站类型名（对齐测试的数据源）。
const Set<String> kOutboundTypeNames = {
  'anytls',
  'block',
  'direct',
  'http',
  'hysteria',
  'hysteria2',
  'naive',
  'selector',
  'shadowsocks',
  'shadowtls',
  'snell',
  'socks',
  'trojan',
  'tuic',
  'urltest',
  'vless',
  'vmess',
};
