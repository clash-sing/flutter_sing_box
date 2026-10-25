import 'package:json_annotation/json_annotation.dart';

import 'typed_profile.dart';
import 'user_info.dart';

part 'profile.g.dart';

/// 订阅档案元数据（MMKV 持久化；配置体为 [TypedProfile.path] 指向的文件）。
@JsonSerializable(explicitToJson: true)
class Profile {
  /// 档案 ID（自增主键）。
  int id;
  /// 用户排序值，小者靠前。
  int order;
  /// 档案显示名。
  String name;
  /// 出站节点数量，可空。
  int? outboundsCount;
  /// 类型化信息（类型 / 路径 / 订阅元信息）。
  TypedProfile typed;
  /// 订阅用量信息，可空。
  UserInfo? userInfo;

  /// 构造档案元数据。
  Profile({
    required this.id,
    required this.order,
    required this.name,
    required this.outboundsCount,
    required this.typed,
    this.userInfo,
  });

  /// 从 JSON 反序列化。
  factory Profile.fromJson(Map<String, dynamic> json) => _$ProfileFromJson(json);

  /// 序列化为 JSON。
  Map<String, dynamic> toJson() => _$ProfileToJson(this);

  /// 复制并替换指定字段（[id] 与 [userInfo] 不变）。
  Profile copyWith({
    int? order,
    String? name,
    int? outboundsCount,
    TypedProfile? typed,
  }) =>
      Profile(
        id: id,
        order: order ?? this.order,
        name: name ?? this.name,
        outboundsCount: outboundsCount ?? this.outboundsCount,
        typed: typed ?? this.typed,
        userInfo: userInfo,
      );
}