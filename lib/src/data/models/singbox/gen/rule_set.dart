// 本文件由 tool/gen_models.dart 生成，勿手改。
import 'package:json_annotation/json_annotation.dart';

import 'headless_rule.dart';

part 'rule_set.g.dart';

@JsonSerializable(explicitToJson: true, includeIfNull: false)
class RuleSet {
  String? type;
  Object tag;
  List<HeadlessRule>? rules;
  String? format;
  String? path;
  String? url;
  @JsonKey(name: 'initial_path')
  String? initialPath;
  @JsonKey(name: 'http_client')
  Object? httpClient;
  @JsonKey(name: 'update_interval')
  String? updateInterval;

  RuleSet({
    required this.tag,
    // 可空字段省略（默认 null）
  });

  factory RuleSet.fromJson(Map<String, dynamic> json) =>
      _$RuleSetFromJson(json);

  Map<String, dynamic> toJson() => _$RuleSetToJson(this);
}
