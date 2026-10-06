// 本文件由 tool/gen_models.dart 生成，勿手改。
import 'package:json_annotation/json_annotation.dart';

import 'brutal_options.dart';

part 'outbound_multiplex_options.g.dart';

@JsonSerializable(explicitToJson: true, includeIfNull: false)
class OutboundMultiplexOptions {
  bool? enabled;
  String? protocol;
  @JsonKey(name: 'max_connections')
  int? maxConnections;
  @JsonKey(name: 'min_streams')
  int? minStreams;
  @JsonKey(name: 'max_streams')
  int? maxStreams;
  bool? padding;
  BrutalOptions? brutal;

  OutboundMultiplexOptions();

  factory OutboundMultiplexOptions.fromJson(Map<String, dynamic> json) =>
      _$OutboundMultiplexOptionsFromJson(json);

  Map<String, dynamic> toJson() => _$OutboundMultiplexOptionsToJson(this);
}
