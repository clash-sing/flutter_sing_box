// 本文件由 tool/gen_models.dart 生成，勿手改。
import 'package:json_annotation/json_annotation.dart';

part 'outbound_utls_options.g.dart';

/// 由官方 JSON schema `$defs/OutboundUTLSOptions` 定义的配置模型。
@JsonSerializable(explicitToJson: true, includeIfNull: false)
class OutboundUTLSOptions {
  /// 对应 JSON 键 `enabled`，可空（null 不参与序列化）。
  bool? enabled;
  /// 对应 JSON 键 `fingerprint`，可空（null 不参与序列化）。
  String? fingerprint;

  /// 构造实例；可空字段省略时为 `null`。
  OutboundUTLSOptions();

  /// 从 JSON 对象反序列化为本类型。
  factory OutboundUTLSOptions.fromJson(Map<String, dynamic> json) =>
      _$OutboundUTLSOptionsFromJson(json);

  /// 序列化为 JSON 对象。
  Map<String, dynamic> toJson() => _$OutboundUTLSOptionsToJson(this);
}
