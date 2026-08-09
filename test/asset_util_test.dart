import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_sing_box/src/utils/asset_util.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;

/// AssetUtil.writeBytesWithRenameFallback 单测。
///
/// 该方法负责把 asset 字节落到目标位置，并对「目标被运行中进程锁定」
/// （Windows 上作为系统服务宿主的 helper.exe）做重命名降级。这里用注入的
/// writer / renamer 模拟文件锁定，避免依赖平台特定的文件占用行为。
void main() {
  group('AssetUtil.writeBytesWithRenameFallback', () {
    late Directory tmp;
    late File dest;
    final newBytes = Uint8List.fromList([1, 2, 3, 4, 5]);

    setUp(() async {
      tmp = await Directory.systemTemp.createTemp('asset_write_test_');
      dest = File(p.join(tmp.path, 'helper.exe'));
    });

    tearDown(() async {
      if (await tmp.exists()) await tmp.delete(recursive: true);
    });

    test('dest 不存在 → 直接写入成功', () async {
      final ok = await AssetUtil.writeBytesWithRenameFallback(newBytes, dest);

      expect(ok, isTrue);
      expect(await dest.readAsBytes(), newBytes);
      // 无降级残留
      expect(await File('${dest.path}.old').exists(), isFalse);
    });

    test('dest 存在内容不同 → 覆盖成功，不产生 .old', () async {
      await dest.writeAsBytes([9, 9, 9]);

      final ok = await AssetUtil.writeBytesWithRenameFallback(newBytes, dest);

      expect(ok, isTrue);
      expect(await dest.readAsBytes(), newBytes);
      expect(await File('${dest.path}.old').exists(), isFalse);
    });

    test('writer 首次失败（模拟锁定）→ rename dest 为 .old 后重试成功', () async {
      await dest.writeAsBytes([9, 9, 9]);
      var call = 0;

      // 注入 writer：第一次抛异常模拟「目标被占用」，第二次正常写入。
      Future<void> fakeWriter(Uint8List b, File f) async {
        call += 1;
        if (call == 1) {
          throw const FileSystemException('sharing violation', 'locked', OSError('sharing violation', 32));
        }
        await f.writeAsBytes(b);
      }

      final ok = await AssetUtil.writeBytesWithRenameFallback(newBytes, dest, writer: fakeWriter);

      expect(ok, isTrue);
      expect(call, 2); // 首次失败 + 降级后重试一次
      expect(await dest.readAsBytes(), newBytes); // dest 已是新版
      // 旧 dest 被重命名保留为 .old（运行中进程仍持有其句柄）
      final oldFile = File('${dest.path}.old');
      expect(await oldFile.exists(), isTrue);
      expect(await oldFile.readAsBytes(), [9, 9, 9]);
    });

    test('writer 失败但 dest 不存在 → false（无可重命名的目标）', () async {
      Future<void> failingWriter(Uint8List b, File f) async {
        throw const FileSystemException('denied');
      }

      final ok = await AssetUtil.writeBytesWithRenameFallback(newBytes, dest, writer: failingWriter);

      expect(ok, isFalse);
      expect(await dest.exists(), isFalse);
    });

    test('writer 失败且 rename 也失败 → false', () async {
      await dest.writeAsBytes([9, 9, 9]);

      Future<void> failingWriter(Uint8List b, File f) async {
        throw const FileSystemException('sharing violation', 'locked', OSError('sharing violation', 32));
      }

      Future<File> failingRenamer(File s, String newPath) async {
        throw const FileSystemException('rename denied');
      }

      final ok = await AssetUtil.writeBytesWithRenameFallback(
        newBytes,
        dest,
        writer: failingWriter,
        renamer: failingRenamer,
      );

      expect(ok, isFalse);
    });

    test('降级前清理更早遗留的 .old 残留，再重命名当前旧 dest', () async {
      await dest.writeAsBytes([9, 9, 9]);
      // 预置更早一轮更新残留的 .old（无进程占用，可删）
      final staleOld = File('${dest.path}.old');
      await staleOld.writeAsBytes([7, 7, 7]);

      var call = 0;
      Future<void> fakeWriter(Uint8List b, File f) async {
        call += 1;
        if (call == 1) {
          throw const FileSystemException('sharing violation', 'locked', OSError('sharing violation', 32));
        }
        await f.writeAsBytes(b);
      }

      final ok = await AssetUtil.writeBytesWithRenameFallback(newBytes, dest, writer: fakeWriter);

      expect(ok, isTrue);
      // .old 现在应是本次重命名的旧 dest，而非已被清理的残留
      expect(await File('${dest.path}.old').readAsBytes(), [9, 9, 9]);
    });
  });
}
