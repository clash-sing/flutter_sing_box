// 本文件由 tool/gen_models.dart 生成，勿手改。
part of 'outbound.dart';

@JsonSerializable(explicitToJson: true, includeIfNull: false)
class DirectOutbound extends Outbound with DialerFields {
  static const typeName = 'direct';

  @override
  @JsonKey()
  String tag;

  DirectOutbound({
    required this.tag,
    // 可空字段省略（默认 null）
  });

  @override
  String get type => typeName;

  factory DirectOutbound.fromJson(Map<String, dynamic> json) =>
      _$DirectOutboundFromJson(json);

  @override
  Map<String, dynamic> toJson() =>
      {'type': typeName, ..._$DirectOutboundToJson(this)};
}
