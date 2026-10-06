// 本文件由 tool/gen_models.dart 生成，勿手改。
part of 'inbound.dart';

/// 未建模入站类型：持有原始 JSON 原样透传（保真读写）。
class UnknownInbound extends Inbound {
  final Map<String, dynamic> raw;
  UnknownInbound(this.raw);

  @override
  String get tag => raw['tag'] as String? ?? '';
  @override
  String get type => raw['type'] as String? ?? '';

  factory UnknownInbound.fromJson(Map<String, dynamic> json) =>
      UnknownInbound(Map<String, dynamic>.from(json));

  @override
  Map<String, dynamic> toJson() => Map<String, dynamic>.from(raw);
}
