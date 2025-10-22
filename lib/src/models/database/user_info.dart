import 'package:json_annotation/json_annotation.dart';

part 'user_info.g.dart';

@JsonSerializable()
class UserInfo {
  int? upload;
  int? download;
  int? total;
  int? expire;

  UserInfo({
    this.upload,
    this.download,
    this.total,
    this.expire
  });

  factory UserInfo.fromJson(Map<String, dynamic> json) => _$UserInfoFromJson(json);

  Map<String, dynamic> toJson() => _$UserInfoToJson(this);

}