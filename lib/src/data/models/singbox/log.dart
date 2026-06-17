import 'package:json_annotation/json_annotation.dart';

part 'log.g.dart';

@JsonSerializable(explicitToJson: true)
class Log {
  bool? disabled;
  String? level;
  String? output;
  bool? timestamp;

  Log({
    this.disabled,
    this.level,
    this.output,
    this.timestamp,
  });

  factory Log.fromJson(Map<String, dynamic> json) => _$LogFromJson(json);

  Map<String, dynamic> toJson() => _$LogToJson(this);
}