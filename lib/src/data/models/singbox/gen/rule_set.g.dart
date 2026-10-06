// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'rule_set.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RuleSet _$RuleSetFromJson(Map<String, dynamic> json) =>
    RuleSet(tag: json['tag'] as Object)
      ..type = json['type'] as String?
      ..rules = (json['rules'] as List<dynamic>?)
          ?.map((e) => HeadlessRule.fromJson(e as Map<String, dynamic>))
          .toList()
      ..format = json['format'] as String?
      ..path = json['path'] as String?
      ..url = json['url'] as String?
      ..initialPath = json['initial_path'] as String?
      ..httpClient = json['http_client']
      ..updateInterval = json['update_interval'] as String?;

Map<String, dynamic> _$RuleSetToJson(RuleSet instance) => <String, dynamic>{
  'type': ?instance.type,
  'tag': instance.tag,
  'rules': ?instance.rules?.map((e) => e.toJson()).toList(),
  'format': ?instance.format,
  'path': ?instance.path,
  'url': ?instance.url,
  'initial_path': ?instance.initialPath,
  'http_client': ?instance.httpClient,
  'update_interval': ?instance.updateInterval,
};
