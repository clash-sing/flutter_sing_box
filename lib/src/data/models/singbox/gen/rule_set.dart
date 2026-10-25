// 本文件由 tool/gen_models.dart 生成，勿手改。
import 'package:json_annotation/json_annotation.dart';

import 'headless_rule.dart';

part 'rule_set.g.dart';

/// 由官方 JSON schema `$defs/RuleSet` 定义的配置模型。
@JsonSerializable(explicitToJson: true, includeIfNull: false)
class RuleSet {
  /// 对应 JSON 键 `type`，可空（null 不参与序列化）。
  String? type;
  /// 对应 JSON 键 `tag`，必填。
  Object tag;
  /// 对应 JSON 键 `rules`，可空（null 不参与序列化）。
  List<HeadlessRule>? rules;
  /// 对应 JSON 键 `format`，可空（null 不参与序列化）。
  String? format;
  /// 对应 JSON 键 `path`，可空（null 不参与序列化）。
  String? path;
  /// 对应 JSON 键 `url`，可空（null 不参与序列化）。
  String? url;
  /// 对应 JSON 键 `initial_path`，可空（null 不参与序列化）。
  @JsonKey(name: 'initial_path')
  String? initialPath;
  /// 对应 JSON 键 `http_client`，可空（null 不参与序列化）。
  @JsonKey(name: 'http_client')
  Object? httpClient;
  /// 对应 JSON 键 `update_interval`，可空（null 不参与序列化）。
  @JsonKey(name: 'update_interval')
  String? updateInterval;

  /// 以 [tag] 构造；可空字段省略时为 `null`。
  RuleSet({
    required this.tag,
    // 可空字段省略（默认 null）
  });

  /// 从 JSON 对象反序列化为本类型。
  factory RuleSet.fromJson(Map<String, dynamic> json) =>
      _$RuleSetFromJson(json);

  /// 序列化为 JSON 对象。
  Map<String, dynamic> toJson() => _$RuleSetToJson(this);
}
