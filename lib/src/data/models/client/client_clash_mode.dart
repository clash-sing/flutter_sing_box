import 'package:json_annotation/json_annotation.dart';

part 'client_clash_mode.g.dart';

@JsonSerializable()
class ClientClashMode {
  final List<String> modes;
  final String currentMode;

  ClientClashMode({
    required this.modes,
    required this.currentMode
  });

  factory ClientClashMode.fromJson(Map<String, dynamic> json) => _$ClientClashModeFromJson(json);

  Map<String, dynamic> toJson() => _$ClientClashModeToJson(this);

}
