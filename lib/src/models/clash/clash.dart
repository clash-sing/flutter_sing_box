import 'package:flutter_sing_box/src/models/clash/clash_group.dart';
import 'package:json_annotation/json_annotation.dart';

import 'clash_proxy.dart';

part 'clash.g.dart';

@JsonSerializable(explicitToJson: true)
class Clash {
  List<ClashProxy> proxies;
  @JsonKey(name: "proxy-groups")
  List<ClashGroup> proxyGroups;

  Clash({
    required this.proxies,
    required this.proxyGroups,
  });

  factory Clash.fromJson(Map<String, dynamic> json) => _$ClashFromJson(json);

  Map<String, dynamic> toJson() => _$ClashToJson(this);
}