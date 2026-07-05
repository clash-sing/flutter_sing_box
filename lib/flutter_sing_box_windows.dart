import 'dart:convert';
import 'dart:io' as io;
import 'package:path/path.dart' as p;
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_sing_box/flutter_sing_box.dart';
import 'package:flutter_sing_box/flutter_sing_box_platform_interface.dart';

class FlutterSingBoxWindows extends FlutterSingBoxPlatform {
  @visibleForTesting
  final methodChannel = const MethodChannel('flutter_sing_box');

  /// Registers this class as the default instance of [FlutterSingBoxPlatform].
  static void registerWith() {
    FlutterSingBoxPlatform.instance = FlutterSingBoxWindows();
  }

  @override
  Future<void> init() async {
    debugPrint('flutter_sing_box 插件初始化 Windows 平台');
    const String assetBasePath = 'packages/flutter_sing_box/assets';

    const String assetPathSingBox = '$assetBasePath/windows/sing-box.exe';
    const String assetPathLibcronet = '$assetBasePath/windows/libcronet.dll';
    final singBoxResult = await AssetUtil.copyAssetToDirectory(
      assetPathSingBox,
      p.dirname(io.Platform.resolvedExecutable),
    );
    if (!singBoxResult) {
      throw Exception('复制 sing_box.exe 资源失败');
    }
    await AssetUtil.copyAssetToDirectory(
      assetPathLibcronet,
      p.dirname(io.Platform.resolvedExecutable),
    );

    // 释放独立服务程序 clash_sing_helper.exe，供 queryServiceStatus 调用。
    const String assetPathHelper = '$assetBasePath/windows/clash_sing_helper.exe';
    final helperResult = await AssetUtil.copyAssetToDirectory(
      assetPathHelper,
      p.dirname(io.Platform.resolvedExecutable),
    );
    if (!helperResult) {
      throw Exception('复制 clash_sing_helper.exe 资源失败');
    }
  }

  /// 查询 Windows 端 `clash_sing_service` 的安装/运行状态。
  ///
  /// 流程：确保 helper.json 就绪 → 调用 clash_sing_helper.exe status
  /// → 解析 stdout。任何异常（超时、进程失败、文件缺失）一律返回 [WindowsServiceStatus.error]。
  @override
  Future<WindowsServiceStatus> queryServiceStatus() async {
    try {
      await ensureHelperJson();

      final String exeDir = p.dirname(io.Platform.resolvedExecutable);
      final io.File helperExe = io.File(p.join(exeDir, 'clash_sing_helper.exe'));
      if (!await helperExe.exists()) {
        return WindowsServiceStatus.error;
      }

      final io.ProcessResult result = await io.Process.run(helperExe.path, ['status'])
          .timeout(const Duration(seconds: 5));
      return WindowsServiceStatus.fromHelperOutput(
        (result.stdout ?? '').toString().trim(),
      );
    } catch (_) {
      return WindowsServiceStatus.error;
    }
  }

  /// 确保 helper.exe 同目录下存在合法的 helper.json（status 命令的强依赖）。
  ///
  /// - 已存在则**不覆盖**（保护服务运行时回写的 port 字段）。
  /// - [dir] 仅用于测试注入；默认为 exe 同目录。
  @visibleForTesting
  Future<void> ensureHelperJson({String? dir}) async {
    final String directory = dir ?? p.dirname(io.Platform.resolvedExecutable);
    final io.File file = io.File(p.join(directory, 'helper.json'));
    if (await file.exists()) return;

    await file.parent.create(recursive: true);
    final Map<String, dynamic> config = <String, dynamic>{
      'execute': p.join(directory, 'sing-box.exe'),
      'config': p.join(directory, 'sing-box-config.json'),
      'helperName': windowsServiceName,
      'helperDisplayName': windowsServiceDisplayName,
      'helperDescription': windowsServiceDescription,
      'port': 0,
    };
    await file.writeAsString(jsonEncode(config));
  }
}
