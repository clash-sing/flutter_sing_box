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
  items: (json['items'] as List<dynamic>?)
      ?.map((e) => GroupItem.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$ClientGroupToJson(ClientGroup instance) =>
    <String, dynamic>{
      'tag': instance.tag,
      'type': instance.type,
      'selectable': instance.selectable,
      'selected': instance.selected,
      'isExpand': instance.isExpand,
      'items': ?instance.items?.map((e) => e.toJson()).toList(),
    };

GroupItem _$GroupItemFromJson(Map<String, dynamic> json) => GroupItem(
  tag: json['tag'] as String,
  type: json['type'] as String,
  urlTestTime: (json['urlTestTime'] as num).toInt(),
  urlTestDelay: (json['urlTestDelay'] as num).toInt(),
);

Map<String, dynamic> _$GroupItemToJson(GroupItem instance) => <String, dynamic>{
  'tag': instance.tag,
  'type': instance.type,
  'urlTestTime': instance.urlTestTime,
  'urlTestDelay': instance.urlTestDelay,
};
