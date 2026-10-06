// 本文件由 tool/gen_models.dart 生成，勿手改。
import 'package:json_annotation/json_annotation.dart';

part 'outbound_reality_options.g.dart';

@JsonSerializable(explicitToJson: true, includeIfNull: false)
class OutboundRealityOptions {
  bool? enabled;
  @JsonKey(name: 'public_key')
  String? publicKey;
  @JsonKey(name: 'short_id')
  String? shortId;

  OutboundRealityOptions();

  factory OutboundRealityOptions.fromJson(Map<String, dynamic> json) =>
      _$OutboundRealityOptionsFromJson(json);

  Map<String, dynamic> toJson() => _$OutboundRealityOptionsToJson(this);
}
