// 本文件由 tool/gen_models.dart 生成，勿手改。
import 'package:json_annotation/json_annotation.dart';

part 'http_proxy_options.g.dart';

/// 由官方 JSON schema `$defs/HTTPProxyOptions` 定义的配置模型。
@JsonSerializable(explicitToJson: true, includeIfNull: false)
class HTTPProxyOptions {
  /// 对应 JSON 键 `enabled`，可空（null 不参与序列化）。
  bool? enabled;
  /// 对应 JSON 键 `server`，可空（null 不参与序列化）。
  String? server;
  /// 对应 JSON 键 `server_port`，可空（null 不参与序列化）。
  @JsonKey(name: 'server_port')
  int? serverPort;
  /// 对应 JSON 键 `bypass_domain`，可空（null 不参与序列化）。
  @JsonKey(name: 'bypass_domain')
  Object? bypassDomain;
  /// 对应 JSON 键 `match_domain`，可空（null 不参与序列化）。
  @JsonKey(name: 'match_domain')
  Object? matchDomain;

  /// 构造实例；可空字段省略时为 `null`。
  HTTPProxyOptions();

  /// 从 JSON 对象反序列化为本类型。
  factory HTTPProxyOptions.fromJson(Map<String, dynamic> json) =>
      _$HTTPProxyOptionsFromJson(json);

  /// 序列化为 JSON 对象。
  Map<String, dynamic> toJson() => _$HTTPProxyOptionsToJson(this);
}
