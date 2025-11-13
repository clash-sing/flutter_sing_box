import 'package:json_annotation/json_annotation.dart';

part 'client_status.g.dart';

@JsonSerializable()
class ClientStatus {
  int memory;
  int goroutines;
  int connectionsIn;
  int connectionsOut;
  bool trafficAvailable;
  int uplink;
  int downlink;
  int uplinkTotal;
  int downlinkTotal;

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

  factory ClientStatus.fromJson(Map<String, dynamic> json) => _$ClientStatusFromJson(json);

  Map<String, dynamic> toJson() => _$ClientStatusToJson(this);
}
