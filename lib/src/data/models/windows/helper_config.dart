import 'package:json_annotation/json_annotation.dart';

part 'helper_config.g.dart';

@JsonSerializable(explicitToJson: true)
class HelperConfig {
  @JsonKey(name: "helperName")
  final String helperServiceName;
  @JsonKey(name: "helperDisplayName")
  final String helperServiceDisplayName;
  @JsonKey(name: "helperDescription")
  final String helperServiceDescription;
  @JsonKey(name: "execute")
  final String singBoxExecute;
  @JsonKey(name: "config")
  final String singBoxConfig;
  @JsonKey(name: "port")
  final int singBoxPort;

  HelperConfig({
    required this.helperServiceName,
    required this.helperServiceDisplayName,
    required this.helperServiceDescription,
    required this.singBoxExecute,
    required this.singBoxConfig,
    required this.singBoxPort,
  });

  factory HelperConfig.fromJson(Map<String, dynamic> json) => _$HelperConfigFromJson(json);

  Map<String, dynamic> toJson() => _$HelperConfigToJson(this);
}
