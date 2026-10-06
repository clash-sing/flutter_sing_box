// 本文件由 tool/gen_models.dart 生成，勿手改。

/// 开放映射（schema：object + additionalProperties）：任意键值表，
/// 读入全收、输出全出（round-trip 保真）。
class HTTPHeader {
  final Map<String, dynamic> entries;

  HTTPHeader([this.entries = const {}]);

  factory HTTPHeader.fromJson(Map<String, dynamic> json) =>
      HTTPHeader(Map<String, dynamic>.from(json));

  Map<String, dynamic> toJson() => Map<String, dynamic>.from(entries);
}
