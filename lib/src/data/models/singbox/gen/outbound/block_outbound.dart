// 本文件由 tool/gen_models.dart 生成，勿手改。
part of 'outbound.dart';

@JsonSerializable(explicitToJson: true, includeIfNull: false)
class BlockOutbound extends Outbound {
  static const typeName = 'block';

  @override
  String tag;

  BlockOutbound({
    required this.tag,
  });

  @override
  String get type => typeName;

  factory BlockOutbound.fromJson(Map<String, dynamic> json) =>
      _$BlockOutboundFromJson(json);

  @override
  Map<String, dynamic> toJson() =>
      {'type': typeName, ..._$BlockOutboundToJson(this)};
}
