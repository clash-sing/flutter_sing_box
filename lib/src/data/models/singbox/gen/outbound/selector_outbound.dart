// 本文件由 tool/gen_models.dart 生成，勿手改。
part of 'outbound.dart';

@JsonSerializable(explicitToJson: true, includeIfNull: false)
class SelectorOutbound extends Outbound {
  static const typeName = 'selector';

  @override
  String tag;
  List<String>? outbounds;
  @JsonKey(name: 'default')
  String? default_;
  @JsonKey(name: 'interrupt_exist_connections')
  bool? interruptExistConnections;

  SelectorOutbound({
    required this.tag,
    // 可空字段省略（默认 null）
  });

  @override
  String get type => typeName;

  factory SelectorOutbound.fromJson(Map<String, dynamic> json) =>
      _$SelectorOutboundFromJson(json);

  @override
  Map<String, dynamic> toJson() =>
      {'type': typeName, ..._$SelectorOutboundToJson(this)};
}
