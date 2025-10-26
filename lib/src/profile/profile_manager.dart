import 'dart:convert';
import 'dart:io';

import 'package:collection/collection.dart';
import 'package:flutter_sing_box/src/models/database/selected_proxy.dart';
import 'package:mmkv/mmkv.dart';
import 'package:path_provider/path_provider.dart';

import '../../flutter_sing_box.dart';
import '../const/outbound_type.dart';

class ProfileManager {
  static final ProfileManager _instance = ProfileManager._internal();
  factory ProfileManager() => _instance;

  late MMKV _mmkv;
  ProfileManager._internal() {
    _mmkv = MMKV("cs-profile", mode: MMKVMode.MULTI_PROCESS_MODE);
  }

  Future<SelectedProxy?> getSelectedProxy() async {
    final String? jsonString = _mmkv.decodeString(_Keys.selectedProxy);
    if (jsonString?.isNotEmpty == true) {
      final Map<String, dynamic> jsonMap = jsonDecode(jsonString!);
      return SelectedProxy.fromJson(jsonMap);
    } else {
      final profiles = getProfiles();
      if (profiles.isNotEmpty) {
        final profile = profiles[0];
        final file = File(profile.typed.path);
        final content = await file.readAsString();
        final jsonMap = jsonDecode(content);
        final singBox = SingBox.fromJson(jsonMap);
        final selector = singBox.outbounds.firstWhereOrNull((element) {
          return element.type == OutboundType.selector
              && element.outbounds?.isNotEmpty == true;
        });
        if (selector != null) {
          final selectedProxy = SelectedProxy(
            profileId: profile.id,
            group: selector.tag,
            outbound: selector.defaultTag ?? selector.outbounds![0],
          );
          return selectedProxy;
        } else {
          return null;
        }
      } else {
        return null;
      }
    }
  }

  bool setSelectedProxy(SelectedProxy selectedProxy) {
    final String jsonString = jsonEncode(selectedProxy.toJson());
    return _mmkv.encodeString(_Keys.selectedProxy, jsonString);
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
    if (jsonString?.isNotEmpty == true) {
      final Map<String, dynamic> jsonMap = jsonDecode(jsonString!);
      return Profile.fromJson(jsonMap);
    }
    return null;
  }

  Future<void> addProfile(Profile profile, SingBox singbox) async{
    final content = jsonEncode(singbox.toJson());
    await File(profile.typed.path).writeAsString(content);
    final String key = getProfileKey(profile.id);
    final String jsonString = jsonEncode(profile.toJson());
    _mmkv.encodeString(key, jsonString);
  }

  Future<void> updateProfile(Profile profile, SingBox singbox) async {
    final content = jsonEncode(singbox.toJson());
    await File(profile.typed.path).writeAsString(content);

    final String key = getProfileKey(profile.id);
    final String jsonString = jsonEncode(profile.toJson());
    _mmkv.encodeString(key, jsonString);
  }

  void deleteProfile(int id) {
    final profile = getProfile(id);
    if (profile == null) {
      return;
    }
    final String key = getProfileKey(profile.id);
    _mmkv.removeValue(key);
    final file = File(profile.typed.path);
    file.deleteSync();
  }

  List<Profile> getProfiles() {
    List<String> keys = _mmkv.allKeys.where(
      (key) => key.startsWith(_Keys.profilePrefix),
    ).toList();
    List<Profile> profiles = [];
    for (String key in keys) {
      final String? jsonString = _mmkv.decodeString(key);
      if (jsonString?.isNotEmpty == true) {
        final Map<String, dynamic> jsonMap = jsonDecode(jsonString!);
        profiles.add(Profile.fromJson(jsonMap));
      }
    }
    profiles.sort((a, b) => a.userOrder.compareTo(b.userOrder));
    return profiles;
  }

  void reorder(List<Profile>  profiles) {
    for (int i = 0; i < profiles.length; i++) {
      final Profile profile = profiles[i];
      profile.userOrder = i;
      final String jsonString = jsonEncode(profile.toJson());
      _mmkv.encodeString(getProfileKey(profile.id), jsonString);
    }
  }

}
class _Keys {
  static const String maxId = "max_id";
  static const String profilePrefix = "profile_";
  static const String selectedProxy = "selected_proxy";
}

final profileManager = ProfileManager();