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

  SelectedProxy? getSelectedProxy() {
    final String? jsonString = _mmkv.decodeString(_Keys.selectedProxy);
    if (jsonString?.isNotEmpty == true) {
      final Map<String, dynamic> jsonMap = jsonDecode(jsonString!);
      return SelectedProxy.fromJson(jsonMap);
    } else {
        return null;
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

  Future<void> addProfile(Profile profile, SingBox singBox) async{
    final content = jsonEncode(singBox.toJson());
    await File(profile.typed.path).writeAsString(content);
    final String key = getProfileKey(profile.id);
    final String jsonString = jsonEncode(profile.toJson());
    _mmkv.encodeString(key, jsonString);
    final defaultProxy = getDefaultProxy(singBox);
    if (defaultProxy != null && getSelectedProxy() == null) {
      setSelectedProxy(SelectedProxy(
          profileId: profile.id,
          group: defaultProxy.key,
          outbound: defaultProxy.value
      ));
    }
  }

  /// TODO: 更新配置文件，未检查 [SelectedProxy]
  Future<void> updateProfile(Profile profile, SingBox singbox) async {
    final content = jsonEncode(singbox.toJson());
    await File(profile.typed.path).writeAsString(content);

    final String key = getProfileKey(profile.id);
    final String jsonString = jsonEncode(profile.toJson());
    _mmkv.encodeString(key, jsonString);
  }

  /// TODO: 删除配置文件，未检查 [SelectedProxy]
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

  MapEntry<String, String>? getDefaultProxy(SingBox singBox) {
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