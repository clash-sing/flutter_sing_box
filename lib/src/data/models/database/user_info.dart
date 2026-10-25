import 'package:json_annotation/json_annotation.dart';

part 'user_info.g.dart';

/// 订阅流量用量与到期信息（订阅响应头解析所得）。
@JsonSerializable(explicitToJson: true)
class UserInfo {
  /// 已上传字节数。
  int? upload;
  /// 已下载字节数。
  int? download;
  /// 流量总量字节数。
  int? total;
  /// 到期时间（epoch 秒）。
  int? expire;

  /// 构造用量信息。
  UserInfo({
    this.upload,
    this.download,
    this.total,
    this.expire
  });

  /// 从 JSON 反序列化。
  factory UserInfo.fromJson(Map<String, dynamic> json) => _$UserInfoFromJson(json);

  /// 序列化为 JSON。
  Map<String, dynamic> toJson() => _$UserInfoToJson(this);

}