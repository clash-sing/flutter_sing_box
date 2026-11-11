import 'dart:io' as io;

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as p;

import '../constants/flutter_sing_box_constants.dart';
import '../data/models/singbox/gen/index.dart';
import '../storage/core_storage.dart';

/// 内置远程规则集的本地兜底（clash_sing_app#27）。
///
/// 模板中的 `geoip-cn` / `geosite-cn` 是 remote 规则集：没有缓存时
/// sing-box 会在启动阶段同步下载，失败则整份配置起不来。这里把官方
/// 规则集随插件打包，启动时释放到可写目录，并在生成配置时写入
/// `initial_path`，让内核无缓存时优先读本地文件；后台更新逻辑保持不变。
///
/// 资产来源（`rule-set` 分支）：
/// - https://github.com/SagerNet/sing-geoip
/// - https://github.com/SagerNet/sing-geosite
abstract final class RuleSetAssets {
  /// 随插件打包的规则集文件名。
  static const List<String> fileNames = ['geoip-cn.srs', 'geosite-cn.srs'];

  /// 运行时释放目录名（位于 [CoreStorage] 存储根目录下）。
  static const String directoryName = 'rule-sets';

  /// 文件名对应的官方仓库路径片段（用于拒绝来源不明的同名规则集）。
  static const Map<String, String> _officialRepos = {
    'geoip-cn.srs': 'sing-geoip',
    'geosite-cn.srs': 'sing-geosite',
  };

  /// 规则集在插件资产中的完整 key。
  static String assetPathOf(String fileName) =>
      '${FlutterSingBoxConstants.assetBasePath}rulesets/$fileName';

  /// 运行时规则集目录；目录不存在时创建。
  static Future<io.Directory> defaultDirectory() async {
    final io.Directory storage = await CoreStorage().getStorageDirectory();
    final io.Directory dir = io.Directory(p.join(storage.path, directoryName));
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  /// 把内置规则集释放到 [directory]（缺省为 [defaultDirectory]）。
  ///
  /// 内容一致时跳过写入；单个文件失败只记日志并继续，返回是否全部成功。
  /// 失败不阻断插件初始化——配置注入侧还会再检查文件是否存在。
  ///
  /// [loader] 仅供单测注入，绕过 rootBundle。
  static Future<bool> ensureExtracted({
    io.Directory? directory,
    Future<ByteData> Function(String assetPath)? loader,
  }) async {
    var allOk = true;
    final Future<ByteData> Function(String assetPath) load =
        loader ?? rootBundle.load;
    try {
      final io.Directory dir = directory ?? await defaultDirectory();
      if (!await dir.exists()) {
        await dir.create(recursive: true);
      }
      for (final String fileName in fileNames) {
        try {
          final ByteData data = await load(assetPathOf(fileName));
          final Uint8List bytes = data.buffer.asUint8List(
            data.offsetInBytes,
            data.lengthInBytes,
          );
          final io.File target = io.File(p.join(dir.path, fileName));
          if (await target.exists() &&
              listEquals(await target.readAsBytes(), bytes)) {
            continue;
          }
          await target.writeAsBytes(bytes, flush: true);
        } catch (e) {
          allOk = false;
          debugPrint('释放内置规则集失败: $fileName, $e');
        }
      }
    } catch (e) {
      allOk = false;
      debugPrint('释放内置规则集失败: $e');
    }
    return allOk;
  }

  /// 给配置中可识别的 remote 规则集补上本地 `initial_path`。
  ///
  /// 仅处理同时满足以下条件的规则集：
  /// - `type == "remote"`，`format` 为空或 `binary`；
  /// - URL 指向 SagerNet 官方 `sing-geoip` / `sing-geosite` 仓库（含 CDN 镜像），
  ///   且文件名命中 [fileNames]——不同文件名的规则集语义不同，绝不替换；
  /// - 本地释放文件存在。
  ///
  /// 已有 `initial_path` 且指向的文件有效时保留（尊重订阅自定义路径）；
  /// 指向的文件失效时替换为当前设备的路径。
  ///
  /// 任何异常都只记日志，绝不向订阅导入流程冒泡。
  static Future<void> applyInitialPaths(
    SingBox singBox, {
    io.Directory? directory,
  }) async {
    try {
      final List<RuleSet> ruleSets = singBox.route.ruleSet ?? const [];
      if (ruleSets.isEmpty) return;
      final io.Directory dir = directory ?? await defaultDirectory();
      for (final RuleSet ruleSet in ruleSets) {
        final String? fileName = _bundledFileNameOf(ruleSet);
        if (fileName == null) continue;
        final io.File localFile = io.File(p.join(dir.path, fileName));
        if (!await localFile.exists()) continue;
        final String? current = ruleSet.initialPath;
        if (current != null && current.isNotEmpty) {
          if (await io.File(current).exists()) continue;
        }
        ruleSet.initialPath = localFile.path;
      }
    } catch (e) {
      debugPrint('注入规则集本地兜底路径失败(忽略): $e');
    }
  }

  /// 规则集对应的内置文件名；不满足官方来源/格式条件时返回 null。
  static String? _bundledFileNameOf(RuleSet ruleSet) {
    if (ruleSet.type != 'remote') return null;
    final String? format = ruleSet.format;
    if (format != null && format != 'binary') return null;
    final String? url = ruleSet.url;
    if (url == null || url.isEmpty) return null;
    final Uri? uri = Uri.tryParse(url);
    if (uri == null || uri.pathSegments.isEmpty) return null;
    final String fileName = uri.pathSegments.last;
    final String? repo = _officialRepos[fileName];
    if (repo == null) return null;
    final bool official =
        uri.pathSegments.contains('SagerNet') &&
        uri.pathSegments.any(
          (segment) => segment == repo || segment.startsWith('$repo@'),
        );
    return official ? fileName : null;
  }
}
