import 'package:json_annotation/json_annotation.dart';

part 'client_log.g.dart';

/// 推送到 App 端的单条内核日志。
@JsonSerializable(explicitToJson: true)
class ClientLog {
  /// 常量构造一条日志。
  const ClientLog({required this.level, required this.message});

  /// 日志级别
  /// 0=Panic, 1=Fatal, 2=Error, 3=Warn, 4=Info, 5=Debug, 6=Trace
  final int level;
  /// 日志正文。
  final String message;

  /// 从 JSON 反序列化。
  factory ClientLog.fromJson(Map<String, dynamic> json) => _$ClientLogFromJson(json);

  /// 序列化为 JSON。
  Map<String, dynamic> toJson() => _$ClientLogToJson(this);
}
