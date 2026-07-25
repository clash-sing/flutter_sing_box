import 'package:json_annotation/json_annotation.dart';

part 'clash_configs.g.dart';

@JsonSerializable(explicitToJson: true)
class ClashConfigs {
  final int port;

  @JsonKey(name: 'socks-port')
  final int socksPort;

  @JsonKey(name: 'redir-port')
  final int redirPort;

  @JsonKey(name: 'tproxy-port')
  final int tproxyPort;

  @JsonKey(name: 'mixed-port')
  final int mixedPort;

  @JsonKey(name: 'allow-lan')
  final bool allowLan;

  @JsonKey(name: 'bind-address')
  final String bindAddress;

  final String mode;

  @JsonKey(name: 'mode-list')
  final List<String> modeList;

  @JsonKey(name: 'log-level')
  final String logLevel;

  final bool ipv6;

  ClashConfigs({
    required this.port,
    required this.socksPort,
    required this.redirPort,
    required this.tproxyPort,
    required this.mixedPort,
    required this.allowLan,
    required this.bindAddress,
    required this.mode,
    required this.modeList,
    required this.logLevel,
    required this.ipv6,
  });

  factory ClashConfigs.fromJson(Map<String, dynamic> json) => _$ClashConfigsFromJson(json);
  Map<String, dynamic> toJson() => _$ClashConfigsToJson(this);

}
