import 'package:json_annotation/json_annotation.dart';

part 'client_log.g.dart';

@JsonSerializable()
class ClientLog {
  const ClientLog({required this.level, required this.message});

  /// 日志级别
  /// 0=Panic, 1=Fatal, 2=Error, 3=Warn, 4=Info, 5=Debug, 6=Trace
  final int level;
  final String message;

  factory ClientLog.fromJson(Map<String, dynamic> json) => _$ClientLogFromJson(json);

  Map<String, dynamic> toJson() => _$ClientLogToJson(this);
}
