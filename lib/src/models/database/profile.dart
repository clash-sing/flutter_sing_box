import 'package:json_annotation/json_annotation.dart';

part 'profile.g.dart';

@JsonSerializable(explicitToJson: true)
class Profile {
  int id;
  int userOrder;
  String name;
  TypedProfile typed;
  UserInfo? userInfo;

  Profile({
    this.id = 0,
    this.userOrder = 0,
    required this.name,
    required this.typed,
    this.userInfo
  });

  factory Profile.fromJson(Map<String, dynamic> json) => _$ProfileFromJson(json);

  Map<String, dynamic> toJson() => _$ProfileToJson(this);
}

@JsonSerializable()
class TypedProfile {
  String? path;
  ProfileType type;
  String? remoteUrl;
  String? webPageUrl;
  int? lastUpdated;
  bool autoUpdate;
  int? autoUpdateInterval;

  TypedProfile({
    this.path,
    required this.type,
    this.remoteUrl,
    this.webPageUrl,
    this.lastUpdated,
    required this.autoUpdate,
    this.autoUpdateInterval
  });

  factory TypedProfile.fromJson(Map<String, dynamic> json) => _$TypedProfileFromJson(json);

  Map<String, dynamic> toJson() => _$TypedProfileToJson(this);

}

enum ProfileType {
  local,
  remote
}

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
