import 'package:json_annotation/json_annotation.dart';

import '../../constants/profile_type.dart';

part 'typed_profile.g.dart';

@JsonSerializable()
class TypedProfile {
  ProfileType type;
  String path;
  int lastUpdated;
  bool autoUpdate;
  int? autoUpdateInterval;
  String? remoteUrl;
  String? webPageUrl;

  TypedProfile({
    required this.type,
    required this.path,
    required this.lastUpdated,
    required this.autoUpdate,
    this.autoUpdateInterval,
    this.remoteUrl,
    this.webPageUrl
  });

  factory TypedProfile.fromJson(Map<String, dynamic> json) => _$TypedProfileFromJson(json);

  Map<String, dynamic> toJson() => _$TypedProfileToJson(this);

}