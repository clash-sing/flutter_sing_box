import 'package:json_annotation/json_annotation.dart';

import 'typed_profile.dart';
import 'user_info.dart';

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
