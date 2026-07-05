import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;


abstract final class AssetUtil {
  /// 缓存 Future 而非结果：第一个调用同步地把加载 Future 存下来，
  /// 并发调用直接 await 同一个 Future，底层只加载一次。
  static Future<List<String>>? _assetsListFuture;

  static Future<List<String>> getAssetsList() {
    // 注意：这里不是 async —— ??= 赋值是同步的，没有 await 间隙，
    // 因此并发调用不会重复触发加载。
    _assetsListFuture ??= _loadAssetsList();
    return _assetsListFuture!;
  }

  static Future<List<String>> _loadAssetsList() async {
    final manifest = await AssetManifest.loadFromAssetBundle(rootBundle);
    return manifest.listAssets();
  }

  /// 判断 asset 是否已打包进 app。
  static Future<bool> assetExists(String assetPath) async {
    return (await getAssetsList()).contains(assetPath);
  }

  /// 将 [assetPath] 对应的 asset 复制到 [destPath] 指定的位置。
  ///
  /// [destPath] 既可以是目标目录，也可以是完整的目标文件路径：
  /// - 以路径分隔符结尾（如 `<appDir>/geosite/`），或指向一个已存在的目录，
  ///   视为目录，目标文件名取 [assetPath] 的 basename；
  /// - 否则视为含文件名的完整路径（如 `<appDir>/geosite/cn.srs`）。
  ///
  /// 流程：先把 asset 写入临时文件，再与目标文件比对，
  /// 内容一致则跳过复制，不一致才覆盖写入，从而避免无谓的重复写入。
  ///
  /// 返回 true 表示复制成功，或目标文件已一致无需复制；失败返回 false。
  static Future<bool> copyAssetToDirectory(String assetPath, String destPath) async {
    debugPrint('复制 asset 到目录: $assetPath -> $destPath');
    if (await assetExists(assetPath) == false) return false;

    final String fileName = p.basename(assetPath);
    File? tempFile;
    try {
      // 1. 先将 assetPath 对应的文件复制到临时目录
      final ByteData byteData = await rootBundle.load(assetPath);
      final Directory tempDir = await getTemporaryDirectory();
      tempFile = File(p.join(tempDir.path, fileName));
      await tempFile.writeAsBytes(
        byteData.buffer.asUint8List(byteData.offsetInBytes, byteData.lengthInBytes),
      );

      // destPath 可能是目录（文件名取 basename）或完整文件路径
      final File destFile = await _resolveDestFile(assetPath, destPath);

      // 2-3. 比较临时文件与目标文件：内容一致则说明已复制，无需再复制
      if (await _filesEqual(tempFile, destFile)) {
        return true;
      }

      // 4. 不一致则将临时文件复制到目标位置
      await destFile.parent.create(recursive: true);
      await tempFile.copy(destFile.path);
      return true;
    } catch (e) {
      debugPrint('复制 asset 到目录失败: $assetPath -> $destPath');
      return false;
    } finally {
      // 无论成功或失败，都清理临时文件；清理失败不影响主流程
      if (tempFile != null) {
        try {
          if (await tempFile.exists()) await tempFile.delete();
        } catch (_) {
          // 忽略清理异常
        }
      }
    }
  }

  /// 比较两个文件内容是否一致：先比长度，长度相同再比 sha256 摘要。
  static Future<bool> _filesEqual(File source, File target) async {
    if (!await target.exists()) return false;
    if (await source.length() != await target.length()) return false;
    return await _digestOf(source) == await _digestOf(target);
  }

  /// 流式计算文件 sha256 摘要，避免把整个文件读进内存。
  static Future<Digest> _digestOf(File file) async {
    final sink = _DigestSink();
    final hasher = sha256.startChunkedConversion(sink);
    await for (final chunk in file.openRead()) {
      hasher.add(chunk);
    }
    hasher.close();
    return sink.value!;
  }

  /// 解析最终的目标文件路径。
  ///
  /// - [destPath] 以路径分隔符结尾、或指向已存在的目录 → 视为目录，
  ///   目标文件名取 [assetPath] 的 basename；
  /// - 否则 → [destPath] 即为含文件名的完整文件路径。
  static Future<File> _resolveDestFile(String assetPath, String destPath) async {
    final bool isDirHint = destPath.endsWith('/') || destPath.endsWith(r'\');
    if (isDirHint) {
      return File(p.join(destPath, p.basename(assetPath)));
    }
    if (await FileSystemEntity.type(destPath) == FileSystemEntityType.directory) {
      return File(p.join(destPath, p.basename(assetPath)));
    }
    return File(destPath);
  }
}

/// 接收 chunked 哈希输出的 Digest 的最小 Sink。
class _DigestSink implements Sink<Digest> {
  Digest? value;

  @override
  void add(Digest data) => value = data;

  @override
  void close() {}
}
