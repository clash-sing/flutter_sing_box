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
    debugPrint('flutter_sing_box 插件初始化 Windows 平台 startTime = ${DateTime.now()}');
    final io.Directory dir = await ProfileStorage().getStorageDirectory();
    const String assetBasePath = 'packages/flutter_sing_box/assets';

    const String assetPathSingBox = '$assetBasePath/windows/sing-box.exe';
    final singBoxResult = await AssetUtil.copyAssetToDirectory(assetPathSingBox, dir.path);
    if (!singBoxResult) {
      throw Exception('复制 sing_box.exe 资源失败');
    }
    const String assetPathLibcronet = '$assetBasePath/windows/libcronet.dll';
    final libcronetResult = await AssetUtil.copyAssetToDirectory(assetPathLibcronet, dir.path);
    if (!libcronetResult) {
      throw Exception('复制 libcronet.dll 资源失败');
    }

    // 释放独立服务程序 clash_sing_helper.exe，供 queryServiceStatus 调用。
    const String assetPathHelper = '$assetBasePath/windows/clash_sing_helper.exe';
    final helperResult = await AssetUtil.copyAssetToDirectory(assetPathHelper, dir.path);
    if (!helperResult) {
      throw Exception('复制 clash_sing_helper.exe 资源失败');
    }
    debugPrint('flutter_sing_box 插件初始化 Windows 平台 endTime = ${DateTime.now()}');
  }

  /// 查询 Windows 端 `clash_sing_service` 的安装/运行状态。
  ///
  /// 流程：确保 helper.json 就绪 → 调用 clash_sing_helper.exe status
  /// → 解析 stdout。任何异常（超时、进程失败、文件缺失）一律返回 [WindowsServiceStatus.error]。
  @override
  Future<WindowsServiceStatus> queryServiceStatus() async {
    try {
      // await ensureHelperJson();
      final io.Directory exeDir = await ProfileStorage().getStorageDirectory();
      final io.File helperExe = io.File(p.join(exeDir.path, 'clash_sing_helper.exe'));
      if (!await helperExe.exists()) {
        return WindowsServiceStatus.error;
      }

      final io.ProcessResult result = await io.Process.run(helperExe.path, [
        'status',
      ]).timeout(const Duration(seconds: 5));
      return WindowsServiceStatus.fromHelperOutput((result.stdout ?? '').toString().trim());
    } catch (_) {
      return WindowsServiceStatus.error;
    }
  }

  /// 构造通过 PowerShell 以管理员权限(runas)启动 [helperExePath] 执行
  /// `install` 的命令行参数。抽成独立方法便于单测参数形状。
  @visibleForTesting
  List<String> buildRunasArgs(String helperExePath) {
    return <String>[
      '-NoProfile',
      '-NonInteractive',
      '-Command',
      "Start-Process -FilePath '$helperExePath' -ArgumentList 'install' -Verb RunAs",
    ];
  }

  /// 轮询服务状态,直到命中 [WindowsServiceStatus.running] 或
  /// [WindowsServiceStatus.stopped](视为"已安装"),或超过 [deadline]。
  ///
  /// 抽成独立方法便于单测:[queryStatus]、[delay]、[now] 均可注入。
  /// 返回 `true` 表示服务已安装(可能已运行);`false` 表示超时仍未安装。
  @visibleForTesting
  Future<bool> waitForServiceReady({
    required Future<WindowsServiceStatus> Function() queryStatus,
    required Future<void> Function(Duration) delay,
    required DateTime Function() now,
    Duration pollInterval = const Duration(milliseconds: 500),
    Duration deadline = const Duration(seconds: 15),
  }) async {
    final DateTime end = now().add(deadline);
    while (now().isBefore(end)) {
      final WindowsServiceStatus status = await queryStatus();
      if (status == WindowsServiceStatus.running ||
          status == WindowsServiceStatus.stopped) {
        return true;
      }
      await delay(pollInterval);
    }
    return false;
  }

  @override
  Future<bool> installService(HelperConfig config) async {
    try {
      final io.Directory dir = await ProfileStorage().getStorageDirectory();
      await _ensureHelperJson(config: config, dir: dir.path);
      final io.File helperExe = io.File(p.join(dir.path, 'clash_sing_helper.exe'));
      if (!await helperExe.exists()) {
        return false;
      }

      final io.ProcessResult result = await io.Process.run(helperExe.path, [
        'install',
      ]).timeout(const Duration(seconds: 5));
      final stdout = (result.stdout ?? '').toString().trim();
      debugPrint('installService stdout = $stdout');
      return true;
    } catch (e) {
      debugPrint('flutter_sing_box 插件安装服务失败, $e');
      return false;
    }
  }

  /// 确保 helper.exe 同目录下存在合法的 helper.json（status 命令的强依赖）。
  ///
  /// - 已存在则**不覆盖**（保护服务运行时回写的 port 字段）。
  /// - [dir] 仅用于测试注入；默认为 exe 同目录。
  Future<void> _ensureHelperJson({required HelperConfig config, required String dir}) async {
    final io.File file = io.File(p.join(dir, 'helper.json'));
    if (await file.exists()) return;

    await file.parent.create(recursive: true);
    // final Map<String, dynamic> config = <String, dynamic>{
    //   'execute': p.join(directory, 'sing-box.exe'),
    //   'config': p.join(directory, 'sing-box-config.json'),
    //   'helperName': windowsServiceName,
    //   'helperDisplayName': windowsServiceDisplayName,
    //   'helperDescription': windowsServiceDescription,
    //   'port': 0,
    // };
    await file.writeAsString(jsonEncode(config));
  }

  @override
  Future<String> getSingBoxVersion() async {
    return '1.13.14';
  }
}
