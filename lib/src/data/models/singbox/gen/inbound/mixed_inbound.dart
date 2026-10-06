// 本文件由 tool/gen_models.dart 生成，勿手改。
part of 'inbound.dart';

@JsonSerializable(explicitToJson: true, includeIfNull: false)
class MixedInbound extends Inbound with ListenFields, DialerFields {
  static const typeName = 'mixed';

  @override
  String tag;
  Object? listen;
  @JsonKey(name: 'listen_port')
  int? listenPort;
  List<User>? users;
  @JsonKey(name: 'set_system_proxy')
  bool? setSystemProxy;
  InboundTLSOptions? tls;

  MixedInbound({
    required this.tag,
    // 可空字段省略（默认 null）
  });

  @override
  String get type => typeName;

  factory MixedInbound.fromJson(Map<String, dynamic> json) =>
      _$MixedInboundFromJson(json);

  @override
  Map<String, dynamic> toJson() =>
      {'type': typeName, ..._$MixedInboundToJson(this)};
}
