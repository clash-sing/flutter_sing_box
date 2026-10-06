// 本文件由 tool/gen_models.dart 生成，勿手改。
part of 'outbound.dart';

@JsonSerializable(explicitToJson: true, includeIfNull: false)
class SnellOutbound extends Outbound with DialerFields {
  static const typeName = 'snell';

  @override
  String tag;
  int version;
  String? server;
  @JsonKey(name: 'server_port')
  int? serverPort;
  String? psk;
  String? userkey;
  bool? reuse;
  Object? network;
  @JsonKey(name: 'obfs_mode')
  String? obfsMode;
  @JsonKey(name: 'obfs_host')
  String? obfsHost;
  String? mode;

  SnellOutbound({
    required this.tag,
    required this.version,
    // 可空字段省略（默认 null）
  });

  @override
  String get type => typeName;

  factory SnellOutbound.fromJson(Map<String, dynamic> json) =>
      _$SnellOutboundFromJson(json);

  @override
  Map<String, dynamic> toJson() =>
      {'type': typeName, ..._$SnellOutboundToJson(this)};
}
