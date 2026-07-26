import 'package:json_annotation/json_annotation.dart';

part 'clash_api_proxy.g.dart';

@JsonSerializable(explicitToJson: true)
class ClashApiProxy {
  final String type;
  final String name;
  final bool udp;
  @JsonKey(name: 'history')
  final List<ClashApiProxyHistory> histories;
  final String? now;
  final List<String>? all;

  ClashApiProxy({
    required this.type,
    required this.name,
    required this.udp,
    required this.histories,
    required this.now,
    required this.all,
  });

  factory ClashApiProxy.fromJson(Map<String, dynamic> json) => _$ClashApiProxyFromJson(json);
  Map<String, dynamic> toJson() => _$ClashApiProxyToJson(this);
}

@JsonSerializable(explicitToJson: true)
class ClashApiProxyHistory {
  /// 示例：2026-07-25T11:17:57.4471785+08:00
  final String time;
  final int delay;

  ClashApiProxyHistory({required this.time, required this.delay});

  DateTime get localTime => DateTime.parse(time).toLocal();

  factory ClashApiProxyHistory.fromJson(Map<String, dynamic> json) =>
      _$ClashApiProxyHistoryFromJson(json);
  Map<String, dynamic> toJson() => _$ClashApiProxyHistoryToJson(this);
}
