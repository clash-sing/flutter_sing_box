// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'debug_options.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DebugOptions _$DebugOptionsFromJson(Map<String, dynamic> json) => DebugOptions()
  ..listen = json['listen'] as String?
  ..gcPercent = (json['gc_percent'] as num?)?.toInt()
  ..maxStack = (json['max_stack'] as num?)?.toInt()
  ..maxThreads = (json['max_threads'] as num?)?.toInt()
  ..panicOnFault = json['panic_on_fault'] as bool?
  ..traceBack = json['trace_back'] as String?
  ..memoryLimit = json['memory_limit']
  ..oomKiller = json['oom_killer'] as bool?;

Map<String, dynamic> _$DebugOptionsToJson(DebugOptions instance) =>
    <String, dynamic>{
      'listen': ?instance.listen,
      'gc_percent': ?instance.gcPercent,
      'max_stack': ?instance.maxStack,
      'max_threads': ?instance.maxThreads,
      'panic_on_fault': ?instance.panicOnFault,
      'trace_back': ?instance.traceBack,
      'memory_limit': ?instance.memoryLimit,
      'oom_killer': ?instance.oomKiller,
    };
