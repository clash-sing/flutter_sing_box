// 本文件由 tool/gen_models.dart 生成，勿手改。
part of 'dns_server.dart';

@JsonSerializable(explicitToJson: true, includeIfNull: false)
class FakeipDNSServer extends DNSServer {
  static const typeName = 'fakeip';

  @override
  @JsonKey()
  String tag;
  @JsonKey(name: 'inet4_range')
  Object? inet4Range;
  @JsonKey(name: 'inet6_range')
  Object? inet6Range;

  FakeipDNSServer({
    required this.tag,
    // 可空字段省略（默认 null）
  });

  @override
  String get type => typeName;

  factory FakeipDNSServer.fromJson(Map<String, dynamic> json) =>
      _$FakeipDNSServerFromJson(json);

  @override
  Map<String, dynamic> toJson() =>
      {'type': typeName, ..._$FakeipDNSServerToJson(this)};
}
