import 'package:json_annotation/json_annotation.dart';

import 'typed_profile.dart';
import 'user_info.dart';

part 'profile.g.dart';

@JsonSerializable(explicitToJson: true)
class Profile {
  int id;
  int order;
  String name;
  TypedProfile typed;
  UserInfo? userInfo;

  Profile({
    required this.id,
    required this.order,
    required this.name,
    required this.typed,
    this.userInfo,
  });

  factory Profile.fromJson(Map<String, dynamic> json) => _$ProfileFromJson(json);

  Map<String, dynamic> toJson() => _$ProfileToJson(this);

  Profile copyWith({
    int? order,
    String? name,
    TypedProfile? typed,
  }) =>
      Profile(
        id: id,
        order: order ?? this.order,
        name: name ?? this.name,
        typed: typed ?? this.typed,
        userInfo: userInfo,
      );
}