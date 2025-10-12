import 'package:json_annotation/json_annotation.dart';

import 'dns.dart';
import 'experimental.dart';
import 'inbound.dart';
import 'log.dart';
import 'outbound.dart';
import 'route.dart';

part 'sing_box.g.dart';

@JsonSerializable()
class SingBox {
  Dns dns;
  List<Inbound> inbounds;
  Route route;
  Experimental experimental;
  List<Outbound> outbounds;
  Log log;

  SingBox({
    required this.dns,
    required this.inbounds,
    required this.route,
    required this.experimental,
    required this.outbounds,
    required this.log,
  });

  factory SingBox.fromJson(Map<String, dynamic> json) => _$SingBoxFromJson(json);

  Map<String, dynamic> toJson() => _$SingBoxToJson(this);
}