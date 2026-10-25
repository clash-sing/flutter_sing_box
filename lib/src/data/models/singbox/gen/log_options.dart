// 本文件由 tool/gen_models.dart 生成，勿手改。
import 'package:json_annotation/json_annotation.dart';

part 'log_options.g.dart';

/// 顶层 `log` 配置段模型。
@JsonSerializable(explicitToJson: true, includeIfNull: false)
class LogOptions {
  /// 对应 JSON 键 `disabled`，可空（null 不参与序列化）。
  bool? disabled;
  /// 对应 JSON 键 `level`，可空（null 不参与序列化）。
  String? level;
  /// 对应 JSON 键 `output`，可空（null 不参与序列化）。
  String? output;
  /// 对应 JSON 键 `timestamp`，可空（null 不参与序列化）。
  bool? timestamp;

  /// 构造实例；可空字段省略时为 `null`。
  LogOptions();

  /// 从 JSON 对象反序列化为本类型。
  factory LogOptions.fromJson(Map<String, dynamic> json) =>
      _$LogOptionsFromJson(json);

  /// 序列化为 JSON 对象。
  Map<String, dynamic> toJson() => _$LogOptionsToJson(this);
}
