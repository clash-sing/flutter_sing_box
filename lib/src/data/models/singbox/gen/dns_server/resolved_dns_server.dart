// 本文件由 tool/gen_models.dart 生成，勿手改。
part of 'dns_server.dart';

@JsonSerializable(explicitToJson: true, includeIfNull: false)
class ResolvedDNSServer extends DNSServer {
  static const typeName = 'resolved';

  @override
  String tag;
  String? service;
  @JsonKey(name: 'accept_default_resolvers')
  bool? acceptDefaultResolvers;

  ResolvedDNSServer({
    required this.tag,
    // 可空字段省略（默认 null）
  });

  @override
  String get type => typeName;

  factory ResolvedDNSServer.fromJson(Map<String, dynamic> json) =>
      _$ResolvedDNSServerFromJson(json);

  @override
  Map<String, dynamic> toJson() =>
      {'type': typeName, ..._$ResolvedDNSServerToJson(this)};
}
