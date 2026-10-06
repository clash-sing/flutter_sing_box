// 本文件由 tool/gen_models.dart 生成，勿手改。
import 'package:json_annotation/json_annotation.dart';

part 'brutal_options.g.dart';

@JsonSerializable(explicitToJson: true, includeIfNull: false)
class BrutalOptions {
  bool? enabled;
  @JsonKey(name: 'up_mbps')
  int? upMbps;
  @JsonKey(name: 'down_mbps')
  int? downMbps;

  BrutalOptions();

  factory BrutalOptions.fromJson(Map<String, dynamic> json) =>
      _$BrutalOptionsFromJson(json);

  Map<String, dynamic> toJson() => _$BrutalOptionsToJson(this);
}
