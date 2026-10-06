// 本文件由 tool/gen_models.dart 生成，勿手改。
import 'package:json_annotation/json_annotation.dart';

part 'http_proxy_options.g.dart';

@JsonSerializable(explicitToJson: true, includeIfNull: false)
class HTTPProxyOptions {
  bool? enabled;
  String? server;
  @JsonKey(name: 'server_port')
  int? serverPort;
  @JsonKey(name: 'bypass_domain')
  Object? bypassDomain;
  @JsonKey(name: 'match_domain')
  Object? matchDomain;

  HTTPProxyOptions();

  factory HTTPProxyOptions.fromJson(Map<String, dynamic> json) =>
      _$HTTPProxyOptionsFromJson(json);

  Map<String, dynamic> toJson() => _$HTTPProxyOptionsToJson(this);
}
