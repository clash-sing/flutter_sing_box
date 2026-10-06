// 本文件由 tool/gen_models.dart 生成，勿手改。
import 'package:json_annotation/json_annotation.dart';

part 'log_options.g.dart';

@JsonSerializable(explicitToJson: true, includeIfNull: false)
class LogOptions {
  bool? disabled;
  String? level;
  String? output;
  bool? timestamp;

  LogOptions();

  factory LogOptions.fromJson(Map<String, dynamic> json) =>
      _$LogOptionsFromJson(json);

  Map<String, dynamic> toJson() => _$LogOptionsToJson(this);
}
