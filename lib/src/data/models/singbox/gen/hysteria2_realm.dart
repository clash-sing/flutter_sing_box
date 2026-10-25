// 本文件由 tool/gen_models.dart 生成，勿手改。
import 'package:json_annotation/json_annotation.dart';

import 'hysteria2_realm_port_mapping.dart';

part 'hysteria2_realm.g.dart';

/// 由官方 JSON schema `$defs/Hysteria2Realm` 定义的配置模型。
@JsonSerializable(explicitToJson: true, includeIfNull: false)
class Hysteria2Realm {
  /// 对应 JSON 键 `server_url`，可空（null 不参与序列化）。
  @JsonKey(name: 'server_url')
  String? serverUrl;
  /// 对应 JSON 键 `token`，可空（null 不参与序列化）。
  String? token;
  /// 对应 JSON 键 `realm_id`，可空（null 不参与序列化）。
  @JsonKey(name: 'realm_id')
  String? realmId;
  /// 对应 JSON 键 `stun_servers`，可空（null 不参与序列化）。
  @JsonKey(name: 'stun_servers')
  List<String>? stunServers;
  /// 对应 JSON 键 `ip_version`，可空（null 不参与序列化）。
  @JsonKey(name: 'ip_version')
  int? ipVersion;
  /// 对应 JSON 键 `port_mapping`，可空（null 不参与序列化）。
  @JsonKey(name: 'port_mapping')
  Hysteria2RealmPortMapping? portMapping;
  /// 对应 JSON 键 `http_client`，可空（null 不参与序列化）。
  @JsonKey(name: 'http_client')
  Object? httpClient;

  /// 构造实例；可空字段省略时为 `null`。
  Hysteria2Realm();

  /// 从 JSON 对象反序列化为本类型。
  factory Hysteria2Realm.fromJson(Map<String, dynamic> json) =>
      _$Hysteria2RealmFromJson(json);

  /// 序列化为 JSON 对象。
  Map<String, dynamic> toJson() => _$Hysteria2RealmToJson(this);
}
