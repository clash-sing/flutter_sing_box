// 本文件由 tool/gen_models.dart 生成，勿手改。
import 'package:json_annotation/json_annotation.dart';

part 'inbound_ech_options.g.dart';

@JsonSerializable(explicitToJson: true, includeIfNull: false)
class InboundECHOptions {
  bool? enabled;
  Object? key;
  @JsonKey(name: 'key_path')
  String? keyPath;

  InboundECHOptions();

  factory InboundECHOptions.fromJson(Map<String, dynamic> json) =>
      _$InboundECHOptionsFromJson(json);

  Map<String, dynamic> toJson() => _$InboundECHOptionsToJson(this);
}
