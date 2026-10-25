// 本文件由 tool/gen_models.dart 生成，勿手改。
import 'package:json_annotation/json_annotation.dart';

import 'http_header.dart';

part 'v2_ray_transport.g.dart';

/// 由官方 JSON schema `$defs/V2RayTransport` 定义的配置模型。
@JsonSerializable(explicitToJson: true, includeIfNull: false)
class V2RayTransport {
  /// 对应 JSON 键 `type`，必填。
  String type;
  /// 对应 JSON 键 `host`，可空（null 不参与序列化）。
  Object? host;
  /// 对应 JSON 键 `path`，可空（null 不参与序列化）。
  String? path;
  /// 对应 JSON 键 `method`，可空（null 不参与序列化）。
  String? method;
  /// 对应 JSON 键 `headers`，可空（null 不参与序列化）。
  HTTPHeader? headers;
  /// 对应 JSON 键 `idle_timeout`，可空（null 不参与序列化）。
  @JsonKey(name: 'idle_timeout')
  String? idleTimeout;
  /// 对应 JSON 键 `ping_timeout`，可空（null 不参与序列化）。
  @JsonKey(name: 'ping_timeout')
  String? pingTimeout;
  /// 对应 JSON 键 `max_early_data`，可空（null 不参与序列化）。
  @JsonKey(name: 'max_early_data')
  int? maxEarlyData;
  /// 对应 JSON 键 `early_data_header_name`，可空（null 不参与序列化）。
  @JsonKey(name: 'early_data_header_name')
  String? earlyDataHeaderName;
  /// 对应 JSON 键 `service_name`，可空（null 不参与序列化）。
  @JsonKey(name: 'service_name')
  String? serviceName;
  /// 对应 JSON 键 `permit_without_stream`，可空（null 不参与序列化）。
  @JsonKey(name: 'permit_without_stream')
  bool? permitWithoutStream;

  /// 以 [type] 构造；可空字段省略时为 `null`。
  V2RayTransport({
    required this.type,
    // 可空字段省略（默认 null）
  });

  /// 从 JSON 对象反序列化为本类型。
  factory V2RayTransport.fromJson(Map<String, dynamic> json) =>
      _$V2RayTransportFromJson(json);

  /// 序列化为 JSON 对象。
  Map<String, dynamic> toJson() => _$V2RayTransportToJson(this);
}
