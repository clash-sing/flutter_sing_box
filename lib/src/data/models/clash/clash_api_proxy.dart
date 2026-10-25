import 'package:json_annotation/json_annotation.dart';

part 'clash_api_proxy.g.dart';

/// Clash API `proxies` 端点返回的代理/分组条目。
@JsonSerializable(explicitToJson: true)
class ClashApiProxy {
  /// 条目类型（`Shadowsocks` / `Selector` / `URLTest` 等）。
  final String type;
  /// 条目名。
  final String name;
  /// 是否支持 UDP。
  final bool udp;
  /// 历史测速记录（对应 JSON 键 `history`）。
  @JsonKey(name: 'history')
  final List<ClashApiProxyHistory> histories;
  /// 分组当前选中项（仅分组条目非空）。
  final String? now;
  /// 分组成员列表（仅分组条目非空）。
  final List<String>? all;

  /// 构造条目；[now] / [all] 仅分组类条目有意义。
  ClashApiProxy({
    required this.type,
    required this.name,
    required this.udp,
    required this.histories,
    required this.now,
    required this.all,
  });

  /// 从 JSON 反序列化。
  factory ClashApiProxy.fromJson(Map<String, dynamic> json) => _$ClashApiProxyFromJson(json);
  /// 序列化为 JSON。
  Map<String, dynamic> toJson() => _$ClashApiProxyToJson(this);
}

/// 一条测速历史记录。
@JsonSerializable(explicitToJson: true)
class ClashApiProxyHistory {
  /// 示例：2026-07-25T11:17:57.4471785+08:00
  /// 测速时刻（ISO 8601 字符串）。
  final String time;
  /// 时延（毫秒）。
  final int delay;

  /// 构造历史记录。
  ClashApiProxyHistory({required this.time, required this.delay});

  /// 测速时刻的本地时区 [DateTime]。
  DateTime get localTime => DateTime.parse(time).toLocal();

  /// 从 JSON 反序列化。
  factory ClashApiProxyHistory.fromJson(Map<String, dynamic> json) =>
      _$ClashApiProxyHistoryFromJson(json);
  /// 序列化为 JSON。
  Map<String, dynamic> toJson() => _$ClashApiProxyHistoryToJson(this);
}
