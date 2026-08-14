import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as p;

/// 字节写入函数签名：把 [bytes] 写入 [dest]。便于单测注入模拟异常。
typedef AssetBytesWriter = Future<void> Function(Uint8List bytes, File dest);

/// 文件重命名函数签名：把 [source] 重命名为 [newPath]。便于单测注入模拟异常。
typedef AssetFileRenamer = Future<File> Function(File source, String newPath);


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
  /// 流程：加载 asset 字节，与目标文件比对 sha256，内容一致则跳过写入，
  /// 不一致才写入，从而避免无谓的重复写入。写入由 [writeBytesWithRenameFallback]
  /// 承担，目标被运行中进程锁定时走重命名降级。
  ///
  /// 返回 true 表示写入成功，或目标文件已一致无需写入；失败返回 false。
  static Future<bool> copyAssetToDirectory(String assetPath, String destPath) async {
    debugPrint('复制 asset 到目录: $assetPath -> $destPath');
    if (await assetExists(assetPath) == false) return false;

    try {
      final ByteData byteData = await rootBundle.load(assetPath);
      final Uint8List bytes =
          byteData.buffer.asUint8List(byteData.offsetInBytes, byteData.lengthInBytes);

      // destPath 可能是目录（文件名取 basename）或完整文件路径
      final File destFile = await _resolveDestFile(assetPath, destPath);

      // 内容一致则说明已写入，无需再写入
      if (await _bytesEqualFile(bytes, destFile)) {
        return true;
      }

      // 写入目标位置（目标被运行中进程锁定时自动重命名降级）
      await destFile.parent.create(recursive: true);
      return await writeBytesWithRenameFallback(bytes, destFile);
    } catch (e) {
      debugPrint('复制 asset 到目录失败: $assetPath -> $destPath, $e');
      return false;
    }
  }

  /// 将 [bytes] 写入 [dest]，目标被占用时走重命名降级。
  ///
  /// Windows 上运行中的 exe（典型：作为系统服务宿主的 `clash_sing_helper.exe`）会被
  /// 独占锁定，直接 [File.writeAsBytes] 报 errno 32（共享冲突）。Windows 允许重命名
  /// 运行中的 exe：故先把锁定目标重命名为 `*.old`（运行中进程仍持有有效句柄、继续跑
  /// 旧版），再写入新文件；新版在进程下次重启时生效。上一轮遗留的 `*.old` 会在重命名
  /// 前尝试删除，仍被占用则忽略（极端情况下重命名会失败并返回 false）。
  ///
  /// 直接用 [File.writeAsBytes] 写字节，而非 `copy(临时文件)`：避免临时文件在异步
  /// 过程中被外部清理导致降级失败；且 writeAsBytes 对锁定目标报标准 errno 32，
  /// 行为可预期（File.copy 在锁定时反而报反直觉的 errno 183）。
  ///
  /// [writer] / [renamer] 仅供单测注入；默认用真实 [File.writeAsBytes] / [File.rename]。
  /// 返回 true 表示写入成功（含降级成功），false 表示最终失败。
  @visibleForTesting
  static Future<bool> writeBytesWithRenameFallback(
    Uint8List bytes,
    File dest, {
    AssetBytesWriter? writer,
    AssetFileRenamer? renamer,
  }) async {
    final AssetBytesWriter doWrite = writer ?? (b, f) => f.writeAsBytes(b);
    final AssetFileRenamer doRename = renamer ?? (f, newPath) => f.rename(newPath);
    try {
      await doWrite(bytes, dest);
      return true;
    } catch (e) {
      // 目标不存在说明失败另有原因（权限、磁盘等），重命名兜底无意义。
      if (!await dest.exists()) {
        debugPrint('写入失败且目标不存在，跳过重命名降级: ${dest.path}, $e');
        return false;
      }
      // 清理更早一轮遗留的 .old；仍被占用则忽略，由下方 rename 决定成败。
      final File oldFile = File('${dest.path}.old');
      try {
        if (await oldFile.exists()) await oldFile.delete();
      } catch (_) {
        // 残留 .old 仍被占用，忽略
      }
      try {
        await doRename(dest, oldFile.path);
        await doWrite(bytes, dest);
        debugPrint('重命名降级成功（旧文件保留为 ${oldFile.path}，进程重启后失效）: ${dest.path}');
        return true;
      } catch (e2) {
        debugPrint('重命名降级仍失败: ${dest.path}, 原始=$e, 降级=$e2');
        return false;
      }
    }
  }

  /// 比对 [bytes] 与目标文件 [target] 的 sha256 是否一致。
  /// 目标不存在直接返回 false；存在则比 bytes 摘要与文件摘要。
  static Future<bool> _bytesEqualFile(Uint8List bytes, File target) async {
    if (!await target.exists()) return false;
    return sha256.convert(bytes) == await _digestOf(target);
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
