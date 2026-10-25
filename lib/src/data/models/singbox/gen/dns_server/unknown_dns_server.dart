// 本文件由 tool/gen_models.dart 生成，勿手改。
part of 'dns_server.dart';

/// 未建模 DNS 服务器类型：持有原始 JSON 原样透传（保真读写）。
class UnknownDnsServer extends DNSServer {
  /// 原始 JSON 键值表（保真读写）。
  final Map<String, dynamic> raw;
  /// 以原始 JSON 构造。
  UnknownDnsServer(this.raw);

  /// 标签，取 `raw` 的 `tag` 键，缺失时空串兜底。
  @override
  String get tag => raw['tag'] as String? ?? '';
  /// 原始 `type` 值，缺失时空串兜底。
  @override
  String get type => raw['type'] as String? ?? '';

  /// 从 JSON 对象反序列化（整表透传收存）。
  factory UnknownDnsServer.fromJson(Map<String, dynamic> json) =>
      UnknownDnsServer(Map<String, dynamic>.from(json));

  /// 原样输出 `raw` 全部键值。
  @override
  Map<String, dynamic> toJson() => Map<String, dynamic>.from(raw);
}
