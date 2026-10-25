// 本文件由 tool/gen_models.dart 生成，勿手改。
import 'package:json_annotation/json_annotation.dart';

import 'http_proxy_options.dart';

part 'tun_platform_options.g.dart';

/// 由官方 JSON schema `$defs/TunPlatformOptions` 定义的配置模型。
@JsonSerializable(explicitToJson: true, includeIfNull: false)
class TunPlatformOptions {
  /// 对应 JSON 键 `http_proxy`，可空（null 不参与序列化）。
  @JsonKey(name: 'http_proxy')
  HTTPProxyOptions? httpProxy;

  /// 构造实例；可空字段省略时为 `null`。
  TunPlatformOptions();

  /// 从 JSON 对象反序列化为本类型。
  factory TunPlatformOptions.fromJson(Map<String, dynamic> json) =>
      _$TunPlatformOptionsFromJson(json);

  /// 序列化为 JSON 对象。
  Map<String, dynamic> toJson() => _$TunPlatformOptionsToJson(this);
}
