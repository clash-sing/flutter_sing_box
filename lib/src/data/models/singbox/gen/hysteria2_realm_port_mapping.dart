// 本文件由 tool/gen_models.dart 生成，勿手改。
import 'package:json_annotation/json_annotation.dart';

part 'hysteria2_realm_port_mapping.g.dart';

/// 由官方 JSON schema `$defs/Hysteria2RealmPortMapping` 定义的配置模型。
@JsonSerializable(explicitToJson: true, includeIfNull: false)
class Hysteria2RealmPortMapping {
  /// 对应 JSON 键 `enabled`，可空（null 不参与序列化）。
  bool? enabled;
  /// 对应 JSON 键 `timeout`，可空（null 不参与序列化）。
  String? timeout;
  /// 对应 JSON 键 `lifetime`，可空（null 不参与序列化）。
  String? lifetime;

  /// 构造实例；可空字段省略时为 `null`。
  Hysteria2RealmPortMapping();

  /// 从 JSON 对象反序列化为本类型。
  factory Hysteria2RealmPortMapping.fromJson(Map<String, dynamic> json) =>
      _$Hysteria2RealmPortMappingFromJson(json);

  /// 序列化为 JSON 对象。
  Map<String, dynamic> toJson() => _$Hysteria2RealmPortMappingToJson(this);
}
