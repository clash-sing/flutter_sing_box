import 'package:json_annotation/json_annotation.dart';

part 'helper_config.g.dart';

/// `clash_sing_helper.exe install` 的安装参数（序列化为 helper.json）。
@JsonSerializable(explicitToJson: true)
class HelperConfig {
  /// 服务名（JSON 键 `helperName`）。
  @JsonKey(name: "helperName")
  final String helperServiceName;
  /// 服务显示名（JSON 键 `helperDisplayName`）。
  @JsonKey(name: "helperDisplayName")
  final String helperServiceDisplayName;
  /// 服务描述（JSON 键 `helperDescription`）。
  @JsonKey(name: "helperDescription")
  final String helperServiceDescription;
  /// sing-box 可执行文件路径（JSON 键 `execute`）。
  @JsonKey(name: "execute")
  final String singBoxExecute;
  /// sing-box 配置文件路径（JSON 键 `config`）。
  @JsonKey(name: "config")
  final String singBoxConfig;
  /// helper HTTP API 端口（JSON 键 `port`，0 表示默认）。
  @JsonKey(name: "port")
  final int helperPort;

  /// 构造安装参数；[helperPort] 缺省 0。
  HelperConfig({
    required this.helperServiceName,
    required this.helperServiceDisplayName,
    required this.helperServiceDescription,
    required this.singBoxExecute,
    required this.singBoxConfig,
    this.helperPort = 0,
  });

  /// 从 JSON 反序列化。
  factory HelperConfig.fromJson(Map<String, dynamic> json) => _$HelperConfigFromJson(json);

  /// 序列化为 JSON。
  Map<String, dynamic> toJson() => _$HelperConfigToJson(this);
}
