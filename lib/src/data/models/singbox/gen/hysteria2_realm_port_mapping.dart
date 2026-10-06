// 本文件由 tool/gen_models.dart 生成，勿手改。
import 'package:json_annotation/json_annotation.dart';

part 'hysteria2_realm_port_mapping.g.dart';

@JsonSerializable(explicitToJson: true, includeIfNull: false)
class Hysteria2RealmPortMapping {
  bool? enabled;
  String? timeout;
  String? lifetime;

  Hysteria2RealmPortMapping();

  factory Hysteria2RealmPortMapping.fromJson(Map<String, dynamic> json) =>
      _$Hysteria2RealmPortMappingFromJson(json);

  Map<String, dynamic> toJson() => _$Hysteria2RealmPortMappingToJson(this);
}
