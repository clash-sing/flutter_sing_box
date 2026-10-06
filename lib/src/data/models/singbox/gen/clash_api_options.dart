// 本文件由 tool/gen_models.dart 生成，勿手改。
import 'package:json_annotation/json_annotation.dart';

part 'clash_api_options.g.dart';

@JsonSerializable(explicitToJson: true, includeIfNull: false)
class ClashAPIOptions {
  @JsonKey(name: 'external_controller')
  String? externalController;
  @JsonKey(name: 'external_ui')
  String? externalUi;
  @JsonKey(name: 'external_ui_download_url')
  String? externalUiDownloadUrl;
  @JsonKey(name: 'external_ui_download_detour')
  String? externalUiDownloadDetour;
  String? secret;
  @JsonKey(name: 'default_mode')
  String? defaultMode;
  @JsonKey(name: 'access_control_allow_origin')
  Object? accessControlAllowOrigin;
  @JsonKey(name: 'access_control_allow_private_network')
  bool? accessControlAllowPrivateNetwork;

  ClashAPIOptions();

  factory ClashAPIOptions.fromJson(Map<String, dynamic> json) =>
      _$ClashAPIOptionsFromJson(json);

  Map<String, dynamic> toJson() => _$ClashAPIOptionsToJson(this);
}
