import 'package:json_annotation/json_annotation.dart';

part 'clash_dns.g.dart';

@JsonSerializable(explicitToJson: true)
class ClashDns {
  @JsonKey(name: 'nameserver-policy')
  final Map<String, List<String>>? nameserverPolicy;
  ClashDns({this.nameserverPolicy});

  factory ClashDns.fromJson(Map<String, dynamic> json) => _$ClashDnsFromJson(json);

  Map<String, dynamic> toJson() => _$ClashDnsToJson(this);
}
