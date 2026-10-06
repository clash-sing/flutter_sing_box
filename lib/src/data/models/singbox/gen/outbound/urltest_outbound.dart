// 本文件由 tool/gen_models.dart 生成，勿手改。
part of 'outbound.dart';

@JsonSerializable(explicitToJson: true, includeIfNull: false)
class UrltestOutbound extends Outbound {
  static const typeName = 'urltest';

  @override
  String tag;
  List<String>? outbounds;
  String? url;
  String? interval;
  int? tolerance;
  @JsonKey(name: 'idle_timeout')
  String? idleTimeout;
  @JsonKey(name: 'interrupt_exist_connections')
  bool? interruptExistConnections;

  UrltestOutbound({
    required this.tag,
    // 可空字段省略（默认 null）
  });

  @override
  String get type => typeName;

  factory UrltestOutbound.fromJson(Map<String, dynamic> json) =>
      _$UrltestOutboundFromJson(json);

  @override
  Map<String, dynamic> toJson() =>
      {'type': typeName, ..._$UrltestOutboundToJson(this)};
}
