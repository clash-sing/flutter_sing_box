import 'package:json_annotation/json_annotation.dart';

part 'log.g.dart';

@JsonSerializable()
class Log {
  bool disabled;
  String level;
  String? output;
  bool timestamp;

  Log({
    required this.disabled,
    required this.level,
    this.output,
    required this.timestamp,
  });

  factory Log.fromJson(Map<String, dynamic> json) => _$LogFromJson(json);

  Map<String, dynamic> toJson() => _$LogToJson(this);
}