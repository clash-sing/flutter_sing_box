// 本文件由 tool/gen_models.dart 生成，勿手改。
import 'package:json_annotation/json_annotation.dart';

import 'hysteria2_realm_port_mapping.dart';

part 'hysteria2_realm.g.dart';

@JsonSerializable(explicitToJson: true, includeIfNull: false)
class Hysteria2Realm {
  @JsonKey(name: 'server_url')
  String? serverUrl;
  String? token;
  @JsonKey(name: 'realm_id')
  String? realmId;
  @JsonKey(name: 'stun_servers')
  List<String>? stunServers;
  @JsonKey(name: 'ip_version')
  int? ipVersion;
  @JsonKey(name: 'port_mapping')
  Hysteria2RealmPortMapping? portMapping;
  @JsonKey(name: 'http_client')
  Object? httpClient;

  Hysteria2Realm();

  factory Hysteria2Realm.fromJson(Map<String, dynamic> json) =>
      _$Hysteria2RealmFromJson(json);

  Map<String, dynamic> toJson() => _$Hysteria2RealmToJson(this);
}
