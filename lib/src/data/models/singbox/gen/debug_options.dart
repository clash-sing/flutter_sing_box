// 本文件由 tool/gen_models.dart 生成，勿手改。
import 'package:json_annotation/json_annotation.dart';

part 'debug_options.g.dart';

/// 由官方 JSON schema `$defs/DebugOptions` 定义的配置模型。
@JsonSerializable(explicitToJson: true, includeIfNull: false)
class DebugOptions {
  /// 对应 JSON 键 `listen`，可空（null 不参与序列化）。
  String? listen;
  /// 对应 JSON 键 `gc_percent`，可空（null 不参与序列化）。
  @JsonKey(name: 'gc_percent')
  int? gcPercent;
  /// 对应 JSON 键 `max_stack`，可空（null 不参与序列化）。
  @JsonKey(name: 'max_stack')
  int? maxStack;
  /// 对应 JSON 键 `max_threads`，可空（null 不参与序列化）。
  @JsonKey(name: 'max_threads')
  int? maxThreads;
  /// 对应 JSON 键 `panic_on_fault`，可空（null 不参与序列化）。
  @JsonKey(name: 'panic_on_fault')
  bool? panicOnFault;
  /// 对应 JSON 键 `trace_back`，可空（null 不参与序列化）。
  @JsonKey(name: 'trace_back')
  String? traceBack;
  /// 对应 JSON 键 `memory_limit`，可空（null 不参与序列化）。
  @JsonKey(name: 'memory_limit')
  Object? memoryLimit;
  /// 对应 JSON 键 `oom_killer`，可空（null 不参与序列化）。
  @JsonKey(name: 'oom_killer')
  bool? oomKiller;

  /// 构造实例；可空字段省略时为 `null`。
  DebugOptions();

  /// 从 JSON 对象反序列化为本类型。
  factory DebugOptions.fromJson(Map<String, dynamic> json) =>
      _$DebugOptionsFromJson(json);

  /// 序列化为 JSON 对象。
  Map<String, dynamic> toJson() => _$DebugOptionsToJson(this);
}
