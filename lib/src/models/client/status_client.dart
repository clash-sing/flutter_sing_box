import 'package:json_annotation/json_annotation.dart';

part 'status_client.g.dart';

@JsonSerializable()
class StatusClient {
  int memory;
  int goroutines;
  int connectionsIn;
  int connectionsOut;
  bool trafficAvailable;
  int uplink;
  int downlink;
  int uplinkTotal;
  int downlinkTotal;

  StatusClient({
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

  factory StatusClient.fromJson(Map<String, dynamic> json) => _$StatusClientFromJson(json);

  Map<String, dynamic> toJson() => _$StatusClientToJson(this);
}
