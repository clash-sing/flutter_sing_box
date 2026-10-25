// 本文件由 tool/gen_models.dart 生成，勿手改。
part of 'dns_server.dart';

/// `type` 判别值为 `openvpn` 的DNS服务器配置。
@JsonSerializable(explicitToJson: true, includeIfNull: false)
class OpenvpnDNSServer extends DNSServer {
  /// 本类的 `type` 判别值。
  static const typeName = 'openvpn';

  /// 对应 JSON 键 `tag`，必填。
  @override
  String tag;
  /// 对应 JSON 键 `endpoint`，可空（null 不参与序列化）。
  String? endpoint;
  /// 对应 JSON 键 `accept_default_resolvers`，可空（null 不参与序列化）。
  @JsonKey(name: 'accept_default_resolvers')
  bool? acceptDefaultResolvers;
  /// 对应 JSON 键 `accept_search_domain`，可空（null 不参与序列化）。
  @JsonKey(name: 'accept_search_domain')
  bool? acceptSearchDomain;

  /// 以 [tag] 构造；可空字段省略时为 `null`。
  OpenvpnDNSServer({
    required this.tag,
    // 可空字段省略（默认 null）
  });

  /// `type` 判别值，固定为 [typeName]。
  @override
  String get type => typeName;

  /// 从 JSON 对象反序列化为本类型。
  factory OpenvpnDNSServer.fromJson(Map<String, dynamic> json) =>
      _$OpenvpnDNSServerFromJson(json);

  /// 序列化为 JSON；输出携带 `type` 判别键。
  @override
  Map<String, dynamic> toJson() =>
      {'type': typeName, ..._$OpenvpnDNSServerToJson(this)};
}
