import 'package:flutter_sing_box/flutter_sing_box.dart';
import 'package:json_annotation/json_annotation.dart';


part 'typed_profile.g.dart';

@JsonSerializable()
class TypedProfile {
  ProfileType type;
  String path;
  int lastUpdated;
  int? autoUpdateInterval;
  String? remoteUrl;
  String? webPageUrl;

  TypedProfile({
    required this.type,
    required this.path,
    required this.lastUpdated,
    this.autoUpdateInterval,
    this.remoteUrl,
    this.webPageUrl
  });

  factory TypedProfile.fromJson(Map<String, dynamic> json) => _$TypedProfileFromJson(json);

  Map<String, dynamic> toJson() => _$TypedProfileToJson(this);

  TypedProfile copyWith({
    ProfileType? type,
    String? path,
    int? lastUpdated,
    int? autoUpdateInterval,
    String? remoteUrl,
    String? webPageUrl
  }) =>
      TypedProfile(
          type: type ?? this.type,
          path: path ?? this.path,
          lastUpdated: lastUpdated ?? this.lastUpdated,
          autoUpdateInterval: autoUpdateInterval ?? this.autoUpdateInterval,
          remoteUrl: remoteUrl ?? this.remoteUrl,
          webPageUrl: webPageUrl ?? this.webPageUrl
      );
}