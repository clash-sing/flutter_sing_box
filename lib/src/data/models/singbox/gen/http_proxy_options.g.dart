// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'http_proxy_options.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

HTTPProxyOptions _$HTTPProxyOptionsFromJson(Map<String, dynamic> json) =>
    HTTPProxyOptions()
      ..enabled = json['enabled'] as bool?
      ..server = json['server'] as String?
      ..serverPort = (json['server_port'] as num?)?.toInt()
      ..bypassDomain = json['bypass_domain']
      ..matchDomain = json['match_domain'];

Map<String, dynamic> _$HTTPProxyOptionsToJson(HTTPProxyOptions instance) =>
    <String, dynamic>{
      'enabled': ?instance.enabled,
      'server': ?instance.server,
      'server_port': ?instance.serverPort,
      'bypass_domain': ?instance.bypassDomain,
      'match_domain': ?instance.matchDomain,
    };
