import 'dart:convert';
import 'dart:io';

import 'package:flutter_sing_box/flutter_sing_box.dart';
import 'package:mmkv/mmkv.dart';
import 'package:path_provider/path_provider.dart';

class ProfileManager {
  static final ProfileManager _instance = ProfileManager._internal();
  factory ProfileManager() => _instance;

  ProfileManager._internal();

  MMKV? _mmkv;

  MMKV get mmkv {
    _mmkv ??= MMKV("cs_profile", mode: MMKVMode.MULTI_PROCESS_MODE);
    return _mmkv!;
  }

  Profile? getSelectedProfile() {
    final profileId = mmkv.decodeInt(_Keys.selectedProfileId);
    return _getProfile(profileId);
  }

  bool setSelectedProfile(int profileId) {
    return mmkv.encodeInt(_Keys.selectedProfileId, profileId);
  }

  int get _maxId {
    return mmkv.decodeInt(_Keys.maxId);
  }

  int get generateProfileId {
    final id = _maxId + 1;
    mmkv.encodeInt(_Keys.maxId, id);
    return id;
  }

  String _getProfileKey(int id) {
    return "${_Keys.profilePrefix}$id";
  }

  Future<String> getProfilePath(int id) async {
    final Directory documentsDir = await getApplicationDocumentsDirectory();
    final profilesDir = Directory('${documentsDir.path}/profiles');
    if (!profilesDir.existsSync()) {
      profilesDir.createSync(recursive: true);
    }
    return "${profilesDir.path}/${_getProfileKey(id)}.json";
  }

  Profile? _getProfile(int id) {
    final String key = _getProfileKey(id);
    final String? jsonString = mmkv.decodeString(key);
    if (jsonString?.isNotEmpty == true) {
      final Map<String, dynamic> jsonMap = jsonDecode(jsonString!);
      return Profile.fromJson(jsonMap);
    }
    return null;
  }

  Future<void> addProfile(Profile profile, SingBox singBox) async{
    final content = jsonEncode(singBox.toJson());
    await File(profile.typed.path).writeAsString(content);
    final String key = _getProfileKey(profile.id);
    final String jsonString = jsonEncode(profile.toJson());
    mmkv.encodeString(key, jsonString);
    if (getSelectedProfile() == null) {
      setSelectedProfile(profile.id);
    }
  }

  Future<void> updateProfile(Profile profile, SingBox singBox) async {
    final content = jsonEncode(singBox.toJson());
    await File(profile.typed.path).writeAsString(content);
    final String key = _getProfileKey(profile.id);
    final String jsonString = jsonEncode(profile.toJson());
    mmkv.encodeString(key, jsonString);
  }

  void deleteProfile(int id) {
    final profile = _getProfile(id);
    if (profile == null) {
      return;
    }
    final String key = _getProfileKey(profile.id);
    mmkv.removeValue(key);
    final file = File(profile.typed.path);
    file.deleteSync();
    final firstProfile = getProfiles().firstOrNull;
    if (firstProfile != null) {
      setSelectedProfile(firstProfile.id);
    } else {
      mmkv.removeValue(_Keys.selectedProfileId);
    }
  }

  List<Profile> getProfiles() {
    List<String> keys = mmkv.allKeys.where(
      (key) => key.startsWith(_Keys.profilePrefix),
    ).toList();
    List<Profile> profiles = [];
    for (String key in keys) {
      final String? jsonString = mmkv.decodeString(key);
      if (jsonString?.isNotEmpty == true) {
        final Map<String, dynamic> jsonMap = jsonDecode(jsonString!);
        profiles.add(Profile.fromJson(jsonMap));
      }
    }
    profiles.sort((a, b) => a.order.compareTo(b.order));
    return profiles;
  }

  void sort(List<Profile>  profiles) {
    for (int i = 0; i < profiles.length; i++) {
      final Profile profile = profiles[i];
      profile.order = i;
      final String jsonString = jsonEncode(profile.toJson());
      mmkv.encodeString(_getProfileKey(profile.id), jsonString);
    }
  }

}
class _Keys {
  static const String maxId = "max_id";
  static const String profilePrefix = "profile_";
  static const String selectedProfileId = "selected_profile_id";
}
