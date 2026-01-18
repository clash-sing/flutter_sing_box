import 'package:json_annotation/json_annotation.dart';

part 'client_status.g.dart';

/// Represents the status of the sing-box client.
@JsonSerializable()
class ClientStatus {
  /// The current memory usage in bytes.
  int memory;

  /// The number of active goroutines.
  int goroutines;

  /// The number of incoming connections.
  int connectionsIn;

  /// The number of outgoing connections.
  int connectionsOut;

  /// Whether traffic information is available.
  bool trafficAvailable;

  /// The current uplink speed in bytes per second.
  int uplink;

  /// The current downlink speed in bytes per second.
  int downlink;

  /// The total uploaded traffic in bytes.
  int uplinkTotal;

  /// The total downloaded traffic in bytes.
  int downlinkTotal;

  /// Creates a new [ClientStatus] instance.
  ClientStatus({
    required this.memory,
    required this.goroutines,
    required this.connectionsIn,
    required this.connectionsOut,
    required this.trafficAvailable,
    required this.uplink,
    required this.downlink,
    required this.uplinkTotal,
    required this.downlinkTotal,
  });

  /// Creates a new [ClientStatus] instance from a JSON map.
  factory ClientStatus.fromJson(Map<String, dynamic> json) => _$ClientStatusFromJson(json);

  /// Converts this [ClientStatus] instance to a JSON map.
  Map<String, dynamic> toJson() => _$ClientStatusToJson(this);
}
