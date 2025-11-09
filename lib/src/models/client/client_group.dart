import 'package:json_annotation/json_annotation.dart';

part 'client_group.g.dart';

@JsonSerializable(explicitToJson: true)
class ClientGroup {
  final String tag;
  final String type;
  final bool selectable;
  final String selected;
  final bool isExpand;
  final List<GroupItem>? items;

  ClientGroup({
    required this.tag,
    required this.type,
    required this.selectable,
    required this.selected,
    required this.isExpand,
    this.items,
  });

  factory ClientGroup.fromJson(Map<String, dynamic> json) => _$ClientGroupFromJson(json);

  Map<String, dynamic> toJson() => _$ClientGroupToJson(this);
}

@JsonSerializable()
class GroupItem {
  final String tag;
  final String type;
  final int urlTestTime;
  final int urlTestDelay;

  GroupItem({
    required this.tag,
    required this.type,
    required this.urlTestTime,
    required this.urlTestDelay,
  });

  factory GroupItem.fromJson(Map<String, dynamic> json) => _$GroupItemFromJson(json);

  Map<String, dynamic> toJson() => _$GroupItemToJson(this);
 }