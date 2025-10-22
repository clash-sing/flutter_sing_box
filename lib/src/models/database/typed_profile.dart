import 'package:json_annotation/json_annotation.dart';

import '../../const/profile_type.dart';

part 'typed_profile.g.dart';

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