// 本文件由 tool/gen_models.dart 生成，勿手改。
import 'package:json_annotation/json_annotation.dart';

part 'clash_api_options.g.dart';

/// 由官方 JSON schema `$defs/ClashAPIOptions` 定义的配置模型。
@JsonSerializable(explicitToJson: true, includeIfNull: false)
class ClashAPIOptions {
  /// 对应 JSON 键 `external_controller`，可空（null 不参与序列化）。
  @JsonKey(name: 'external_controller')
  String? externalController;
  /// 对应 JSON 键 `external_ui`，可空（null 不参与序列化）。
  @JsonKey(name: 'external_ui')
  String? externalUi;
  /// 对应 JSON 键 `external_ui_download_url`，可空（null 不参与序列化）。
  @JsonKey(name: 'external_ui_download_url')
  String? externalUiDownloadUrl;
  /// 对应 JSON 键 `external_ui_download_detour`，可空（null 不参与序列化）。
  @JsonKey(name: 'external_ui_download_detour')
  String? externalUiDownloadDetour;
  /// 对应 JSON 键 `secret`，可空（null 不参与序列化）。
  String? secret;
  /// 对应 JSON 键 `default_mode`，可空（null 不参与序列化）。
  @JsonKey(name: 'default_mode')
  String? defaultMode;
  /// 对应 JSON 键 `access_control_allow_origin`，可空（null 不参与序列化）。
  @JsonKey(name: 'access_control_allow_origin')
  Object? accessControlAllowOrigin;
  /// 对应 JSON 键 `access_control_allow_private_network`，可空（null 不参与序列化）。
  @JsonKey(name: 'access_control_allow_private_network')
  bool? accessControlAllowPrivateNetwork;

  /// 构造实例；可空字段省略时为 `null`。
  ClashAPIOptions();

  /// 从 JSON 对象反序列化为本类型。
  factory ClashAPIOptions.fromJson(Map<String, dynamic> json) =>
      _$ClashAPIOptionsFromJson(json);

  /// 序列化为 JSON 对象。
  Map<String, dynamic> toJson() => _$ClashAPIOptionsToJson(this);
}
