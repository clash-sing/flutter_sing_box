// 本文件由 tool/gen_models.dart 生成，勿手改。
import 'package:json_annotation/json_annotation.dart';

import 'inbound_reality_handshake_options.dart';

part 'inbound_reality_options.g.dart';

@JsonSerializable(explicitToJson: true, includeIfNull: false)
class InboundRealityOptions {
  bool? enabled;
  InboundRealityHandshakeOptions? handshake;
  @JsonKey(name: 'private_key')
  String? privateKey;
  @JsonKey(name: 'short_id')
  Object? shortId;
  @JsonKey(name: 'max_time_difference')
  String? maxTimeDifference;

  InboundRealityOptions();

  factory InboundRealityOptions.fromJson(Map<String, dynamic> json) =>
      _$InboundRealityOptionsFromJson(json);

  Map<String, dynamic> toJson() => _$InboundRealityOptionsToJson(this);
}
