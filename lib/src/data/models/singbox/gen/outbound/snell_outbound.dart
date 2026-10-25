// 本文件由 tool/gen_models.dart 生成，勿手改。
part of 'outbound.dart';

/// `type` 判别值为 `snell` 的出站配置。
@JsonSerializable(explicitToJson: true, includeIfNull: false)
class SnellOutbound extends Outbound with DialerFields {
  /// 本类的 `type` 判别值。
  static const typeName = 'snell';

  /// 对应 JSON 键 `tag`，必填。
  @override
  String tag;
  /// 对应 JSON 键 `version`，必填。
  int version;
  /// 对应 JSON 键 `server`，可空（null 不参与序列化）。
  String? server;
  /// 对应 JSON 键 `server_port`，可空（null 不参与序列化）。
  @JsonKey(name: 'server_port')
  int? serverPort;
  /// 对应 JSON 键 `psk`，可空（null 不参与序列化）。
  String? psk;
  /// 对应 JSON 键 `userkey`，可空（null 不参与序列化）。
  String? userkey;
  /// 对应 JSON 键 `reuse`，可空（null 不参与序列化）。
  bool? reuse;
  /// 对应 JSON 键 `network`，可空（null 不参与序列化）。
  Object? network;
  /// 对应 JSON 键 `obfs_mode`，可空（null 不参与序列化）。
  @JsonKey(name: 'obfs_mode')
  String? obfsMode;
  /// 对应 JSON 键 `obfs_host`，可空（null 不参与序列化）。
  @JsonKey(name: 'obfs_host')
  String? obfsHost;
  /// 对应 JSON 键 `mode`，可空（null 不参与序列化）。
  String? mode;

  /// 以 [tag]、[version] 构造；可空字段省略时为 `null`。
  SnellOutbound({
    required this.tag,
    required this.version,
    // 可空字段省略（默认 null）
  });

  /// `type` 判别值，固定为 [typeName]。
  @override
  String get type => typeName;

  /// 从 JSON 对象反序列化为本类型。
  factory SnellOutbound.fromJson(Map<String, dynamic> json) =>
      _$SnellOutboundFromJson(json);

  /// 序列化为 JSON；输出携带 `type` 判别键。
  @override
  Map<String, dynamic> toJson() =>
      {'type': typeName, ..._$SnellOutboundToJson(this)};
}
