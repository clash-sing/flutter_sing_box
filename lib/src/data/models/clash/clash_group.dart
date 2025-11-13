import 'package:json_annotation/json_annotation.dart';

part 'clash_group.g.dart';

@JsonSerializable(explicitToJson: true)
class ClashGroup {
  String name;
  String type;
  List<String> proxies;
  String? url;
  int? interval;

  ClashGroup({
    required this.name,
    required this.type,
    required this.proxies,
    this.url,
    this.interval,
  });

  factory ClashGroup.fromJson(Map<String, dynamic> json) => _$ClashGroupFromJson(json);

  Map<String, dynamic> toJson() => _$ClashGroupToJson(this);
}