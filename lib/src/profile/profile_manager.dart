import 'dart:convert';
import 'dart:io';

import 'package:mmkv/mmkv.dart';
import 'package:path_provider/path_provider.dart';

import '../../flutter_sing_box.dart';
import '../models/database/profile.dart';

class ProfileManager {
  static final ProfileManager _instance = ProfileManager._internal();
  factory ProfileManager() => _instance;

  late MMKV _mmkv;
  ProfileManager._internal() {
    _mmkv = MMKV("cs-profile", mode: MMKVMode.MULTI_PROCESS_MODE);
  }

  int get _maxId {
    return _mmkv.decodeInt(_Keys.maxId);
  }

  int get generateProfileId {
    _mmkv.encodeInt(_Keys.maxId, _maxId + 1);
    return _maxId;
  }

  String getProfileKey(int id) {
    return "${_Keys.profilePrefix}$_maxId";
  }

  Future<String> getProfilePath(int id) async {
    final Directory documentsDir = await getApplicationDocumentsDirectory();
    final profilesDir = Directory('${documentsDir.path}/profiles');
    if (!profilesDir.existsSync()) {
      profilesDir.createSync(recursive: true);
    }
    return "${profilesDir.path}/${getProfileKey(id)}.json";
  }

  Profile? getProfile(int id) {
    final String key = getProfileKey(id);
    final String? jsonString = _mmkv.decodeString(key);
    if (jsonString != null && jsonString.isNotEmpty) {
      final Map<String, dynamic> jsonMap = jsonDecode(jsonString);
      return Profile.fromJson(jsonMap);
    }
    return null;
  }

  Future<Profile> addProfile(Profile profile, SingBox singbox) async{
    final content = jsonEncode(singbox.toJson());
    final file = await File(profile.typed.path).writeAsString(content);
    final String key = getProfileKey(profile.id);
    final String jsonString = jsonEncode(profile.toJson());
    _mmkv.encodeString(key, jsonString);
    if (file.existsSync()) {
      profile.typed.path = file.path;
    }
    return profile;
  }

  void updateProfile(Profile profile) {
    final String key = getProfileKey(profile.id);
    final String jsonString = jsonEncode(profile.toJson());
    _mmkv.encodeString(key, jsonString);
  }

  void deleteProfile(Profile profile) {
    final String key = getProfileKey(profile.id);
    _mmkv.removeValue(key);
  }

  List<Profile> getProfiles() {
    List<String> keys = _mmkv.allKeys.where(
      (key) => key.startsWith(_Keys.profilePrefix),
    ).toList();
    List<Profile> profiles = [];
    for (String key in keys) {
      final String? jsonString = _mmkv.decodeString(key);
      if (jsonString != null && jsonString.isNotEmpty) {
        final Map<String, dynamic> jsonMap = jsonDecode(jsonString);
        profiles.add(Profile.fromJson(jsonMap));
      }
    }
    return profiles;
  }

  void reorder(List<Profile>  profiles) {
    for (int i = 0; i < profiles.length; i++) {
      final Profile profile = profiles[i];
      profile.userOrder = i;
      updateProfile(profile);
    }
  }

}
class _Keys {
  static const String maxId = "max_id";
  static const String profilePrefix = "profile_";
}

final profileManager = ProfileManager();