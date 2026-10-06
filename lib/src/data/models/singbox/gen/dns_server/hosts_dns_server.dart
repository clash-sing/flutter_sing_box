// 本文件由 tool/gen_models.dart 生成，勿手改。
part of 'dns_server.dart';

@JsonSerializable(explicitToJson: true, includeIfNull: false)
class HostsDNSServer extends DNSServer {
  static const typeName = 'hosts';

  @override
  String tag;
  Object? path;
  Object? predefined;

  HostsDNSServer({
    required this.tag,
    // 可空字段省略（默认 null）
  });

  @override
  String get type => typeName;

  factory HostsDNSServer.fromJson(Map<String, dynamic> json) =>
      _$HostsDNSServerFromJson(json);

  @override
  Map<String, dynamic> toJson() =>
      {'type': typeName, ..._$HostsDNSServerToJson(this)};
}
