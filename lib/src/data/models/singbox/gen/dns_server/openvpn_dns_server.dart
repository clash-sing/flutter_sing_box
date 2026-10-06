// 本文件由 tool/gen_models.dart 生成，勿手改。
part of 'dns_server.dart';

@JsonSerializable(explicitToJson: true, includeIfNull: false)
class OpenvpnDNSServer extends DNSServer {
  static const typeName = 'openvpn';

  @override
  @JsonKey()
  String tag;
  String? endpoint;
  @JsonKey(name: 'accept_default_resolvers')
  bool? acceptDefaultResolvers;
  @JsonKey(name: 'accept_search_domain')
  bool? acceptSearchDomain;

  OpenvpnDNSServer({
    required this.tag,
    // 可空字段省略（默认 null）
  });

  @override
  String get type => typeName;

  factory OpenvpnDNSServer.fromJson(Map<String, dynamic> json) =>
      _$OpenvpnDNSServerFromJson(json);

  @override
  Map<String, dynamic> toJson() =>
      {'type': typeName, ..._$OpenvpnDNSServerToJson(this)};
}
