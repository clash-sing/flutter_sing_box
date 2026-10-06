// 本文件由 tool/gen_models.dart 生成，勿手改。
part of 'outbound.dart';

/// 未建模出站类型：持有原始 JSON 原样透传（保真读写）。
class UnknownOutbound extends Outbound {
  final Map<String, dynamic> raw;
  UnknownOutbound(this.raw);

  @override
  String get tag => raw['tag'] as String? ?? '';
  @override
  String get type => raw['type'] as String? ?? '';

  factory UnknownOutbound.fromJson(Map<String, dynamic> json) =>
      UnknownOutbound(Map<String, dynamic>.from(json));

  @override
  Map<String, dynamic> toJson() => Map<String, dynamic>.from(raw);
}
