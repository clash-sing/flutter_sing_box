import 'package:flutter_sing_box/src/data/models/clash/clash_dns.dart';
import 'package:json_annotation/json_annotation.dart';

import 'clash_group.dart';
import 'clash_proxy.dart';

part 'clash.g.dart';

@JsonSerializable(explicitToJson: true)
class Clash {
  ClashDns? dns;
  List<ClashProxy> proxies;
  @JsonKey(name: "proxy-groups")
  List<ClashGroup> proxyGroups;

  Clash({this.dns, required this.proxies, required this.proxyGroups});

  factory Clash.fromJson(Map<String, dynamic> json) => _$ClashFromJson(json);

  Map<String, dynamic> toJson() => _$ClashToJson(this);
}
