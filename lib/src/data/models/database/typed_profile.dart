import 'package:flutter_sing_box/flutter_sing_box.dart';
import 'package:json_annotation/json_annotation.dart';


part 'typed_profile.g.dart';

/// 档案的类型化信息（配置文件路径 / 更新时间 / 订阅地址）。
@JsonSerializable(explicitToJson: true)
class TypedProfile {
  /// 档案类型（见 [ProfileType]）。
  ProfileType type;
  /// 配置文件路径。
  String path;
  /// 最近更新时间（epoch 毫秒）。
  int lastUpdated;
  /// 自动更新间隔（分钟），可空。
  int? autoUpdateInterval;
  /// 订阅地址，可空。
  String? subscribeUrl;
  /// 订阅主页，可空。
  String? webPageUrl;

  /// 构造类型化信息。
  TypedProfile({
    required this.type,
    required this.path,
    required this.lastUpdated,
    this.autoUpdateInterval,
    this.subscribeUrl,
    this.webPageUrl
  });

  /// 从 JSON 反序列化。
  factory TypedProfile.fromJson(Map<String, dynamic> json) => _$TypedProfileFromJson(json);

  /// 序列化为 JSON。
  Map<String, dynamic> toJson() => _$TypedProfileToJson(this);

  /// 复制并替换订阅相关字段（其余不变）。
  TypedProfile copyWith({
    int? autoUpdateInterval,
    String? subscribeUrl,
  }) =>
      TypedProfile(
        type: type,
        path: path,
        lastUpdated: lastUpdated,
        autoUpdateInterval: autoUpdateInterval ?? this.autoUpdateInterval,
        subscribeUrl: subscribeUrl ?? this.subscribeUrl,
        webPageUrl: webPageUrl,
      );
}