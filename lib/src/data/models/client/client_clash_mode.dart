import 'package:json_annotation/json_annotation.dart';

part 'client_clash_mode.g.dart';

/// Represents the available and current Clash modes.
@JsonSerializable()
class ClientClashMode {
  /// The list of available Clash modes (e.g., ['Global', 'Rule', 'Direct']).
  final List<String> modes;

  /// The currently active Clash mode.
  final String currentMode;

  /// Creates a new [ClientClashMode] instance.
  ClientClashMode({
    required this.modes,
    required this.currentMode
  });

  /// Creates a new [ClientClashMode] instance from a JSON map.
  factory ClientClashMode.fromJson(Map<String, dynamic> json) => _$ClientClashModeFromJson(json);

  /// Converts this [ClientClashMode] instance to a JSON map.
  Map<String, dynamic> toJson() => _$ClientClashModeToJson(this);

}
