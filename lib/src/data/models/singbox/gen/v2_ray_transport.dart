// 本文件由 tool/gen_models.dart 生成，勿手改。
import 'package:json_annotation/json_annotation.dart';

import 'http_header.dart';

part 'v2_ray_transport.g.dart';

@JsonSerializable(explicitToJson: true, includeIfNull: false)
class V2RayTransport {
  String type;
  Object? host;
  String? path;
  String? method;
  HTTPHeader? headers;
  @JsonKey(name: 'idle_timeout')
  String? idleTimeout;
  @JsonKey(name: 'ping_timeout')
  String? pingTimeout;
  @JsonKey(name: 'max_early_data')
  int? maxEarlyData;
  @JsonKey(name: 'early_data_header_name')
  String? earlyDataHeaderName;
  @JsonKey(name: 'service_name')
  String? serviceName;
  @JsonKey(name: 'permit_without_stream')
  bool? permitWithoutStream;

  V2RayTransport({
    required this.type,
    // 可空字段省略（默认 null）
  });

  factory V2RayTransport.fromJson(Map<String, dynamic> json) =>
      _$V2RayTransportFromJson(json);

  Map<String, dynamic> toJson() => _$V2RayTransportToJson(this);
}
