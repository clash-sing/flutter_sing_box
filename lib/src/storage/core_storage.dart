import 'dart:io' as io;
import 'package:path/path.dart' as p;

// 存储抽象与 MMKV 实现经包级 barrel 导出，直接引入即可
import 'package:flutter_sing_box/flutter_sing_box.dart';
import 'package:path_provider/path_provider.dart';

/// 内核存储的路径契约与 Dart↔原生交接通道，非事实源。
///
/// 订阅数据的事实源在 app 侧（档案 CRUD 已随存储收缩移除，本类不再
/// 持有 Profile 相关读写），只保留两类职责：
/// - **路径契约**：存储根目录（[getStorageDirectory]）与配置文件路径派生
///   （[getProfilePath]，`profiles/profile_<id>.json`）——存储根的选择同时被
///   Dart 侧与 Kotlin 原生侧依赖，插件是这份契约的唯一持有者；
/// - **交接通道**：`using_config`（[setUsingConfig]）与 `selected_profile_name`
///   （[setSelectedProfileName]）两键，供原生侧定位当前生效配置。
class CoreStorage {
  CoreStorage._internal();
  static final CoreStorage _instance = CoreStorage._internal();
  /// 单例实例。
  static CoreStorage get instance => _instance;
  /// 单例工厂构造器。
  factory CoreStorage() => _instance;

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

  /// 写交接键：当前选中的档案名（原生侧按名定位配置文件）。
  void setSelectedProfileName(String name) {
    storage.setString(_Keys.selectedProfileName, name);
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
}

class _Keys {
  static const String profilePrefix = "profile_";
  static const String selectedProfileName = "selected_profile_name";
  static const String usingConfig = "using_config";
  static const String usingConfigFilename = "using_config.json";
}
