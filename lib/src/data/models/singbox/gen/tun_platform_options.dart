// 本文件由 tool/gen_models.dart 生成，勿手改。
import 'package:json_annotation/json_annotation.dart';

import 'http_proxy_options.dart';

part 'tun_platform_options.g.dart';

@JsonSerializable(explicitToJson: true, includeIfNull: false)
class TunPlatformOptions {
  @JsonKey(name: 'http_proxy')
  HTTPProxyOptions? httpProxy;

  TunPlatformOptions();

  factory TunPlatformOptions.fromJson(Map<String, dynamic> json) =>
      _$TunPlatformOptionsFromJson(json);

  Map<String, dynamic> toJson() => _$TunPlatformOptionsToJson(this);
}
