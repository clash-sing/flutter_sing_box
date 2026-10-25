// 本文件由 tool/gen_models.dart 生成，勿手改。
import 'package:json_annotation/json_annotation.dart';

part 'user.g.dart';

/// 由官方 JSON schema `$defs/User` 定义的配置模型。
@JsonSerializable(explicitToJson: true, includeIfNull: false)
class User {
  /// 对应 JSON 键 `Username`，可空（null 不参与序列化）。
  @JsonKey(name: 'Username')
  String? username;
  /// 对应 JSON 键 `Password`，可空（null 不参与序列化）。
  @JsonKey(name: 'Password')
  String? password;

  /// 构造实例；可空字段省略时为 `null`。
  User();

  /// 从 JSON 对象反序列化为本类型。
  factory User.fromJson(Map<String, dynamic> json) =>
      _$UserFromJson(json);

  /// 序列化为 JSON 对象。
  Map<String, dynamic> toJson() => _$UserToJson(this);
}
