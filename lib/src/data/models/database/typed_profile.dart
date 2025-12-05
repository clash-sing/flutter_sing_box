import 'package:flutter_sing_box/flutter_sing_box.dart';
import 'package:json_annotation/json_annotation.dart';


part 'typed_profile.g.dart';

@JsonSerializable()
class TypedProfile {
  ProfileType type;
  String path;
  int lastUpdated;
  int? autoUpdateInterval;
  String? subscribeUrl;
  String? webPageUrl;

  TypedProfile({
    required this.type,
    required this.path,
    required this.lastUpdated,
    this.autoUpdateInterval,
    this.subscribeUrl,
    this.webPageUrl
  });

  factory TypedProfile.fromJson(Map<String, dynamic> json) => _$TypedProfileFromJson(json);

  Map<String, dynamic> toJson() => _$TypedProfileToJson(this);

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