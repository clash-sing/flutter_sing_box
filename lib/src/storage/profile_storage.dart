import 'dart:convert';
import 'dart:io' as io;
import 'package:path/path.dart' as p;

// 旧拍平 SingBox 已删除，gen 生成模型经包级 barrel 导出，直接引入即可
import 'package:flutter_sing_box/flutter_sing_box.dart';
import 'package:path_provider/path_provider.dart';

/// 订阅配置档案的持久化存取（MMKV 元数据 + 文件系统配置体）。
///
/// 元数据（[Profile]）存 MMKV（`cs_profile` 实例），sing-box 配置 JSON
/// 写 `profiles/` 目录下的文件；两者以 [Profile.id] 关联。
class ProfileStorage {
  ProfileStorage._internal();
  static final ProfileStorage _instance = ProfileStorage._internal();
  /// 单例实例。
  static ProfileStorage get instance => _instance;
  /// 单例工厂构造器。
  factory ProfileStorage() => _instance;

  /// 仅用于单元测试, 用 [MemoryStorage] 代替默认的 [MmkvStorage]
  static void mockInit() => _storage = MemoryStorage();

  static KeyValueStorage? _storage;
  /// 底层键值存储；缺省惰性初始化为 MMKV。
  static KeyValueStorage get storage => _storage ??= MmkvStorage('cs_profile');

  /// 配置存储根目录：Android 取应用文档目录，Windows 取应用缓存目录。
  Future<io.Directory> getStorageDirectory() async {
    if (io.Platform.isAndroid) {
      return await getApplicationDocumentsDirectory();
    } else if (io.Platform.isWindows) {
      return await getApplicationCacheDirectory();
    }
    return await getApplicationDocumentsDirectory();
  }

  /// 当前选中的档案；从未选择过时返回 `null`。
  Profile? getSelectedProfile() {
    final profileId = storage.getInt(_Keys.selectedProfileId);
    return getProfile(profileId);
  }

  /// 设为当前选中的档案。
  bool setSelectedProfile(int profileId) {
    return storage.setInt(_Keys.selectedProfileId, profileId);
  }

  int get _maxId {
    return storage.getInt(_Keys.maxId);
  }

  /// 生成新的档案 ID（自增）。
  int get generateProfileId {
    final id = _maxId + 1;
    storage.setInt(_Keys.maxId, id);
    return id;
  }

  String _getProfileKey(int id) {
    return "${_Keys.profilePrefix}$id";
  }

  /// 取档案配置文件的完整路径（目录不存在则创建）。
  Future<String> getProfilePath(int id) async {
    final io.Directory documentsDir = await getStorageDirectory();
    final profilesDir = io.Directory(p.join(documentsDir.path, 'profiles'));
    if (!await profilesDir.exists()) {
      await profilesDir.create(recursive: true);
    }
    return p.join(profilesDir.path, '${_getProfileKey(id)}.json');
  }

  /// 按 ID 读取档案元数据；不存在返回 `null`。
  Profile? getProfile(int id) {
    final String key = _getProfileKey(id);
    final String? jsonString = storage.getString(key);
    if (jsonString?.isNotEmpty == true) {
      final Map<String, dynamic> jsonMap = jsonDecode(jsonString!);
      return Profile.fromJson(jsonMap);
    }
    return null;
  }

  /// 新增档案：配置 JSON 写文件、元数据入 MMKV；首个档案自动选中。
  Future<void> addProfile(Profile profile, SingBox singBox) async {
    final content = jsonEncode(singBox.toJson());
    await io.File(profile.typed.path).writeAsString(content);
    final String key = _getProfileKey(profile.id);
    final String jsonString = jsonEncode(profile.toJson());
    storage.setString(key, jsonString);
    if (getSelectedProfile() == null) {
      setSelectedProfile(profile.id);
    }
  }

  /// 更新档案元数据。
  void updateProfile(Profile profile) {
    final String key = _getProfileKey(profile.id);
    final String jsonString = jsonEncode(profile.toJson());
    storage.setString(key, jsonString);
  }

  /// 删除档案（元数据与配置文件一并删除），选中项自动顺延。
  void deleteProfile(int id) {
    final profile = getProfile(id);
    if (profile == null) {
      return;
    }
    final String key = _getProfileKey(profile.id);
    storage.removeValue(key);
    final file = io.File(profile.typed.path);
    file.deleteSync();
    final firstProfile = getProfiles().firstOrNull;
    if (firstProfile != null) {
      setSelectedProfile(firstProfile.id);
    } else {
      storage.removeValue(_Keys.selectedProfileId);
    }
  }

  /// 全部档案，按用户排序值（order）升序。
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

  /// 全部档案 ID。
  List<int> getProfileIds() {
    List<String> keys = storage.allKeys
        .where((key) => key.startsWith(_Keys.profilePrefix))
        .toList();
    return keys
        .map((key) => int.tryParse(key.substring(_Keys.profilePrefix.length)))
        .whereType<int>()
        .toList();
  }

  /// 按传入顺序重写各档案的 order。
  void sort(List<Profile> profiles) {
    for (int i = 0; i < profiles.length; i++) {
      final Profile profile = profiles[i];
      profile.order = i;
      final String jsonString = jsonEncode(profile.toJson());
      storage.setString(_getProfileKey(profile.id), jsonString);
    }
  }

  /// 当前生效配置文件的路径（未设置时用存储根目录下的缺省文件名）。
  Future<io.File> getUsingConfig() async {
    final String usingConfig =
        storage.getString(_Keys.usingConfig) ?? (await getStorageDirectory()).path;
    return io.File(p.join(usingConfig, _Keys.usingConfigFilename));
  }

  /// 记录当前生效配置所在目录。
  void setUsingConfig(String path) {
    storage.setString(_Keys.usingConfig, path);
  }

  /// 清空全部档案元数据（不动配置文件）。
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
