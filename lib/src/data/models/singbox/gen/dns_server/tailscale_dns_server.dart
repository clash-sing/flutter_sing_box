// 本文件由 tool/gen_models.dart 生成，勿手改。
part of 'dns_server.dart';

@JsonSerializable(explicitToJson: true, includeIfNull: false)
class TailscaleDNSServer extends DNSServer {
  static const typeName = 'tailscale';

  @override
  @JsonKey()
  String tag;
  String? endpoint;
  @JsonKey(name: 'accept_default_resolvers')
  bool? acceptDefaultResolvers;
  @JsonKey(name: 'accept_search_domain')
  bool? acceptSearchDomain;

  TailscaleDNSServer({
    required this.tag,
    // 可空字段省略（默认 null）
  });

  @override
  String get type => typeName;

  factory TailscaleDNSServer.fromJson(Map<String, dynamic> json) =>
      _$TailscaleDNSServerFromJson(json);

  @override
  Map<String, dynamic> toJson() =>
      {'type': typeName, ..._$TailscaleDNSServerToJson(this)};
}
