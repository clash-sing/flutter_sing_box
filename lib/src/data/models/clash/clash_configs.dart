import 'package:json_annotation/json_annotation.dart';

part 'clash_configs.g.dart';

/// Clash API `configs` 端点返回的全局配置快照。
@JsonSerializable(explicitToJson: true)
class ClashConfigs {
  /// HTTP 代理端口。
  final int port;

  /// SOCKS 代理端口（对应 JSON 键 `socks-port`）。
  @JsonKey(name: 'socks-port')
  final int socksPort;

  /// 透明代理 redir 端口（对应 JSON 键 `redir-port`）。
  @JsonKey(name: 'redir-port')
  final int redirPort;

  /// 透明代理 tproxy 端口（对应 JSON 键 `tproxy-port`）。
  @JsonKey(name: 'tproxy-port')
  final int tproxyPort;

  /// mixed 混合端口（对应 JSON 键 `mixed-port`）。
  @JsonKey(name: 'mixed-port')
  final int mixedPort;

  /// 是否允许局域网连接（对应 JSON 键 `allow-lan`）。
  @JsonKey(name: 'allow-lan')
  final bool allowLan;

  /// 监听地址（对应 JSON 键 `bind-address`）。
  @JsonKey(name: 'bind-address')
  final String bindAddress;

  /// 当前代理模式。
  final String mode;

  /// 可用模式列表（对应 JSON 键 `mode-list`）。
  @JsonKey(name: 'mode-list')
  final List<String> modeList;

  /// 日志级别（对应 JSON 键 `log-level`）。
  @JsonKey(name: 'log-level')
  final String logLevel;

  /// 是否启用 IPv6。
  final bool ipv6;

  /// 构造配置快照。
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

  /// 从 JSON 反序列化。
  factory ClashConfigs.fromJson(Map<String, dynamic> json) => _$ClashConfigsFromJson(json);
  /// 序列化为 JSON。
  Map<String, dynamic> toJson() => _$ClashConfigsToJson(this);

}
