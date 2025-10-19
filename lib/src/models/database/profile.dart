import 'package:json_annotation/json_annotation.dart';

part 'profile.g.dart';

@JsonSerializable(explicitToJson: true)
class Profile {
  int id;
  int userOrder;
  String name;
  TypedProfile typed;

  Profile({
    this.id = 0,
    this.userOrder = 0,
    required this.name,
    required this.typed
  });

  factory Profile.fromJson(Map<String, dynamic> json) => _$ProfileFromJson(json);

  Map<String, dynamic> toJson() => _$ProfileToJson(this);
}

@JsonSerializable()
class TypedProfile {
  String? path;
  ProfileType type;
  String? remoteURL;
  int? lastUpdated;
  bool autoUpdate;
  int? autoUpdateInterval;

  TypedProfile({
    this.path,
    required this.type,
    this.remoteURL,
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