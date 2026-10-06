// 本文件由 tool/gen_models.dart 生成，勿手改。
import 'package:json_annotation/json_annotation.dart';

part 'outbound_ech_options.g.dart';

@JsonSerializable(explicitToJson: true, includeIfNull: false)
class OutboundECHOptions {
  bool? enabled;
  Object? config;
  @JsonKey(name: 'config_path')
  String? configPath;
  @JsonKey(name: 'query_server_name')
  String? queryServerName;

  OutboundECHOptions();

  factory OutboundECHOptions.fromJson(Map<String, dynamic> json) =>
      _$OutboundECHOptionsFromJson(json);

  Map<String, dynamic> toJson() => _$OutboundECHOptionsToJson(this);
}
