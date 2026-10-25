// 本文件由 tool/gen_models.dart 生成，勿手改。

/// 开放映射（schema：object + additionalProperties）：任意键值表，
/// 读入全收、输出全出（round-trip 保真）。
class HTTPHeader {
  /// 键值表本体。
  final Map<String, dynamic> entries;

  /// 以初始键值表构造，缺省为空表。
  HTTPHeader([this.entries = const {}]);

  /// 从 JSON 对象反序列化（任意键全收）。
  factory HTTPHeader.fromJson(Map<String, dynamic> json) =>
      HTTPHeader(Map<String, dynamic>.from(json));
  /// 序列化为 JSON（任意键全出）。

  Map<String, dynamic> toJson() => Map<String, dynamic>.from(entries);
}
