// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'client_group.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ClientGroup _$ClientGroupFromJson(Map<String, dynamic> json) => ClientGroup(
  tag: json['tag'] as String,
  type: json['type'] as String,
  selectable: json['selectable'] as bool,
  selected: json['selected'] as String,
  isExpand: json['isExpand'] as bool,
  item: json['item'] == null
      ? null
      : GroupItem.fromJson(json['item'] as Map<String, dynamic>),
);

Map<String, dynamic> _$ClientGroupToJson(ClientGroup instance) =>
    <String, dynamic>{
      'tag': instance.tag,
      'type': instance.type,
      'selectable': instance.selectable,
      'selected': instance.selected,
      'isExpand': instance.isExpand,
      'item': ?instance.item?.toJson(),
    };

GroupItem _$GroupItemFromJson(Map<String, dynamic> json) => GroupItem(
  tag: json['tag'] as String,
  type: json['type'] as String,
  urlTestDelay: (json['urlTestDelay'] as num).toInt(),
  getURLTestTime: (json['getURLTestTime'] as num).toInt(),
);

Map<String, dynamic> _$GroupItemToJson(GroupItem instance) => <String, dynamic>{
  'tag': instance.tag,
  'type': instance.type,
  'urlTestDelay': instance.urlTestDelay,
  'getURLTestTime': instance.getURLTestTime,
};
