// 本文件由 tool/gen_models.dart 生成，勿手改。
import 'package:json_annotation/json_annotation.dart';

part 'debug_options.g.dart';

@JsonSerializable(explicitToJson: true, includeIfNull: false)
class DebugOptions {
  String? listen;
  @JsonKey(name: 'gc_percent')
  int? gcPercent;
  @JsonKey(name: 'max_stack')
  int? maxStack;
  @JsonKey(name: 'max_threads')
  int? maxThreads;
  @JsonKey(name: 'panic_on_fault')
  bool? panicOnFault;
  @JsonKey(name: 'trace_back')
  String? traceBack;
  @JsonKey(name: 'memory_limit')
  Object? memoryLimit;
  @JsonKey(name: 'oom_killer')
  bool? oomKiller;

  DebugOptions();

  factory DebugOptions.fromJson(Map<String, dynamic> json) =>
      _$DebugOptionsFromJson(json);

  Map<String, dynamic> toJson() => _$DebugOptionsToJson(this);
}
