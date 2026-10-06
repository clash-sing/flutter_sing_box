// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cache_file_options.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CacheFileOptions _$CacheFileOptionsFromJson(Map<String, dynamic> json) =>
    CacheFileOptions()
      ..enabled = json['enabled'] as bool?
      ..path = json['path'] as String?
      ..cacheId = json['cache_id'] as String?
      ..storeFakeip = json['store_fakeip'] as bool?
      ..storeDns = json['store_dns'] as bool?
      ..bufferSize = json['buffer_size']
      ..flushInterval = json['flush_interval'] as String?;

Map<String, dynamic> _$CacheFileOptionsToJson(CacheFileOptions instance) =>
    <String, dynamic>{
      'enabled': ?instance.enabled,
      'path': ?instance.path,
      'cache_id': ?instance.cacheId,
      'store_fakeip': ?instance.storeFakeip,
      'store_dns': ?instance.storeDns,
      'buffer_size': ?instance.bufferSize,
      'flush_interval': ?instance.flushInterval,
    };
