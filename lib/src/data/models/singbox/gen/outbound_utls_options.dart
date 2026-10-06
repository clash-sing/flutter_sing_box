// 本文件由 tool/gen_models.dart 生成，勿手改。
import 'package:json_annotation/json_annotation.dart';

part 'outbound_utls_options.g.dart';

@JsonSerializable(explicitToJson: true, includeIfNull: false)
class OutboundUTLSOptions {
  bool? enabled;
  String? fingerprint;

  OutboundUTLSOptions();

  factory OutboundUTLSOptions.fromJson(Map<String, dynamic> json) =>
      _$OutboundUTLSOptionsFromJson(json);

  Map<String, dynamic> toJson() => _$OutboundUTLSOptionsToJson(this);
}
