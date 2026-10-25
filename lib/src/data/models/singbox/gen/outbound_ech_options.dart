// 本文件由 tool/gen_models.dart 生成，勿手改。
import 'package:json_annotation/json_annotation.dart';

part 'outbound_ech_options.g.dart';

/// 由官方 JSON schema `$defs/OutboundECHOptions` 定义的配置模型。
@JsonSerializable(explicitToJson: true, includeIfNull: false)
class OutboundECHOptions {
  /// 对应 JSON 键 `enabled`，可空（null 不参与序列化）。
  bool? enabled;
  /// 对应 JSON 键 `config`，可空（null 不参与序列化）。
  Object? config;
  /// 对应 JSON 键 `config_path`，可空（null 不参与序列化）。
  @JsonKey(name: 'config_path')
  String? configPath;
  /// 对应 JSON 键 `query_server_name`，可空（null 不参与序列化）。
  @JsonKey(name: 'query_server_name')
  String? queryServerName;

  /// 构造实例；可空字段省略时为 `null`。
  OutboundECHOptions();

  /// 从 JSON 对象反序列化为本类型。
  factory OutboundECHOptions.fromJson(Map<String, dynamic> json) =>
      _$OutboundECHOptionsFromJson(json);

  /// 序列化为 JSON 对象。
  Map<String, dynamic> toJson() => _$OutboundECHOptionsToJson(this);
}
