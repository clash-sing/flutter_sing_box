import 'package:json_annotation/json_annotation.dart';

part 'clash_group.g.dart';

/// Clash 代理分组。
@JsonSerializable(explicitToJson: true)
class ClashGroup {
  /// 分组名（展示与选择器标识）。
  String name;
  /// 分组类型（如 `select` / `url-test`）。
  String type;
  /// 组内代理名列表。
  List<String> proxies;
  /// 测速 URL（url-test 类分组使用）。
  String? url;
  /// 测速间隔（秒）。
  int? interval;

  /// 构造分组；[url] 与 [interval] 可空。
  ClashGroup({
    required this.name,
    required this.type,
    required this.proxies,
    this.url,
    this.interval,
  });

  /// 从 JSON 反序列化。
  factory ClashGroup.fromJson(Map<String, dynamic> json) => _$ClashGroupFromJson(json);

  /// 序列化为 JSON。
  Map<String, dynamic> toJson() => _$ClashGroupToJson(this);
}