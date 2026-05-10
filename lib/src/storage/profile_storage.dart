import 'dart:convert';
import 'dart:io';

import 'package:flutter_sing_box/flutter_sing_box.dart';
import 'package:path_provider/path_provider.dart';

class ProfileStorage {
  ProfileStorage._internal();
  static final ProfileStorage _instance = ProfileStorage._internal();
  static ProfileStorage get instance => _instance;
  factory ProfileStorage() => _instance;

  /// 仅用于单元测试, 用 [MemoryStorage] 代替默认的 [MmkvStorage]
  static void mockInit() => _storage = MemoryStorage();

  static KeyValueStorage? _storage;
  static KeyValueStorage get storage => _storage ??= MmkvStorage('cs_profile');

  Profile? getSelectedProfile() {
    final profileId = storage.getInt(_Keys.selectedProfileId);
    return getProfile(profileId);
  }

  bool setSelectedProfile(int profileId) {
    return storage.setInt(_Keys.selectedProfileId, profileId);
  }

  int get _maxId {
    return storage.getInt(_Keys.maxId);
  }

  int get generateProfileId {
    final id = _maxId + 1;
    storage.setInt(_Keys.maxId, id);
    return id;
  }

  String _getProfileKey(int id) {
    return "${_Keys.profilePrefix}$id";
  }

  Future<String> getProfilePath(int id) async {
    final Directory documentsDir = await getApplicationDocumentsDirectory();
    final profilesDir = Directory('${documentsDir.path}/profiles');
    if (!await profilesDir.exists()) {
      await profilesDir.create(recursive: true);
    }
    return "${profilesDir.path}/${_getProfileKey(id)}.json";
  }

  Profile? getProfile(int id) {
    final String key = _getProfileKey(id);
    final String? jsonString = storage.getString(key);
    if (jsonString?.isNotEmpty == true) {
      final Map<String, dynamic> jsonMap = jsonDecode(jsonString!);
      return Profile.fromJson(jsonMap);
    }
    return null;
  }

  Future<void> addProfile(Profile profile, SingBox singBox) async {
    final content = jsonEncode(singBox.toJson());
    await File(profile.typed.path).writeAsString(content);
    final String key = _getProfileKey(profile.id);
    final String jsonString = jsonEncode(profile.toJson());
    storage.setString(key, jsonString);
    if (getSelectedProfile() == null) {
      setSelectedProfile(profile.id);
    }
  }

  void updateProfile(Profile profile) {
    final String key = _getProfileKey(profile.id);
    final String jsonString = jsonEncode(profile.toJson());
    storage.setString(key, jsonString);
  }

  void deleteProfile(int id) {
    final profile = getProfile(id);
    if (profile == null) {
      return;
    }
    final String key = _getProfileKey(profile.id);
    storage.removeValue(key);
    final file = File(profile.typed.path);
    file.deleteSync();
    final firstProfile = getProfiles().firstOrNull;
    if (firstProfile != null) {
      setSelectedProfile(firstProfile.id);
    } else {
      storage.removeValue(_Keys.selectedProfileId);
    }
  }

  List<Profile> getProfiles() {
    List<String> keys = storage.allKeys
        .where((key) => key.startsWith(_Keys.profilePrefix))
        .toList();
    List<Profile> profiles = [];
    for (String key in keys) {
      final String? jsonString = storage.getString(key);
      if (jsonString?.isNotEmpty == true) {
        final Map<String, dynamic> jsonMap = jsonDecode(jsonString!);
        profiles.add(Profile.fromJson(jsonMap));
      }
    }
    profiles.sort((a, b) => a.order.compareTo(b.order));
    return profiles;
  }

  List<int> getProfileIds() {
    List<String> keys = storage.allKeys
        .where((key) => key.startsWith(_Keys.profilePrefix))
        .toList();
    return keys
        .map((key) => int.tryParse(key.substring(_Keys.profilePrefix.length)))
        .whereType<int>()
        .toList();
  }

  void sort(List<Profile> profiles) {
    for (int i = 0; i < profiles.length; i++) {
      final Profile profile = profiles[i];
      profile.order = i;
      final String jsonString = jsonEncode(profile.toJson());
      storage.setString(_getProfileKey(profile.id), jsonString);
    }
  }

  Future<File> getUsingConfig() async {
    final String usingConfig =
        storage.getString(_Keys.usingConfig) ?? (await getApplicationDocumentsDirectory()).path;
    return File('$usingConfig/${_Keys.usingConfigFilename}');
  }

  void setUsingConfig(String path) {
    storage.setString(_Keys.usingConfig, path);
  }

  void clear() {
    storage.clearAll();
  }
}

class _Keys {
  static const String maxId = "max_id";
  static const String profilePrefix = "profile_";
  static const String selectedProfileId = "selected_profile_id";
  static const String usingConfig = "using_config";
  static const String usingConfigFilename = "using_config.json";
}
