import 'dart:convert';
import 'dart:io';

import 'package:collection/collection.dart';
import 'package:mmkv/mmkv.dart';
import 'package:path_provider/path_provider.dart';

import '../../flutter_sing_box.dart';
import '../const/outbound_type.dart';

class ProfileManager {
  static final ProfileManager _instance = ProfileManager._internal();
  factory ProfileManager() => _instance;

  late MMKV _mmkv;
  ProfileManager._internal() {
    _mmkv = MMKV("cs-profile", mode: MMKVMode.SINGLE_PROCESS_MODE);
  }

  Profile? getSelectedProfile() {
    final profileId = _mmkv.decodeInt(_Keys.selectedProfileId);
    return _getProfile(profileId);
  }

  bool setSelectedProfile(int profileId) {
    return _mmkv.encodeInt(_Keys.selectedProfileId, profileId);
  }

  int get _maxId {
    return _mmkv.decodeInt(_Keys.maxId);
  }

  int get generateProfileId {
    final id = _maxId + 1;
    _mmkv.encodeInt(_Keys.maxId, id);
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
    final String? jsonString = _mmkv.decodeString(key);
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
    _mmkv.encodeString(key, jsonString);
    if (getSelectedProfile() == null) {
      setSelectedProfile(profile.id);
    }
  }

  Future<void> updateProfile(Profile profile, SingBox singBox) async {
    final content = jsonEncode(singBox.toJson());
    await File(profile.typed.path).writeAsString(content);
    if (profile.selectedGroup != null && profile.selectedOutbound != null) {
      List<String> tags = singBox.outbounds.map((e) => e.tag).toList();
      if (!tags.contains(profile.selectedGroup) || !tags.contains(profile.selectedOutbound)) {
        profile.selectedGroup = null;
        profile.selectedOutbound = null;
      }
    }
    final String key = _getProfileKey(profile.id);
    final String jsonString = jsonEncode(profile.toJson());
    _mmkv.encodeString(key, jsonString);
  }

  void deleteProfile(int id) {
    final profile = _getProfile(id);
    if (profile == null) {
      return;
    }
    if (getSelectedProfile()?.id == id) {
      final profiles = getProfiles();
      if (profiles.length > 1) {
        setSelectedProfile(profiles[1].id);
      } else {
        _mmkv.removeValue(_Keys.selectedProfileId);
      }
    }
    final String key = _getProfileKey(profile.id);
    _mmkv.removeValue(key);
    final file = File(profile.typed.path);
    file.deleteSync();
  }

  /// 获取默认的 代理组 & 出站tag
  @Deprecated(' 暂时保留此方法')
  MapEntry<String, String>? _getDefaultProxy(SingBox singBox) {
    final selector = singBox.outbounds.firstWhereOrNull((element) {
      return element.type == OutboundType.selector
          && element.outbounds?.isNotEmpty == true;
    });
    if (selector != null) {
      return MapEntry(selector.tag, selector.defaultTag ?? selector.outbounds![0]);
    } else {
      return null;
    }
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
      _mmkv.encodeString(_getProfileKey(profile.id), jsonString);
    }
  }

}
class _Keys {
  static const String maxId = "max_id";
  static const String profilePrefix = "profile_";
  static const String selectedProfileId = "selected_profile_id";
}

final profileManager = ProfileManager();