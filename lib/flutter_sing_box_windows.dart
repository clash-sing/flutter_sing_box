import 'dart:io' as io;
import 'package:flutter_sing_box/src/constants/windows_constants.dart';
import 'package:path/path.dart' as p;
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_sing_box/flutter_sing_box.dart';
import 'package:flutter_sing_box/flutter_sing_box_platform_interface.dart';
import 'package:flutter_sing_box/src/windows/helper_cli.dart';

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
    final singBoxResult = await AssetUtil.copyAssetToDirectory(
      WindowsConstants.singBoxAsset,
      dir.path,
    );
    if (!singBoxResult) {
      throw Exception('复制 sing_box.exe 资源失败');
    }
    final libcronetResult = await AssetUtil.copyAssetToDirectory(
      WindowsConstants.libcronetAsset,
      dir.path,
    );
    if (!libcronetResult) {
      throw Exception('复制 libcronet.dll 资源失败');
    }

    // 释放独立服务程序 clash_sing_helper.exe，供 HelperCli 调用。
    final helperResult = await AssetUtil.copyAssetToDirectory(
      WindowsConstants.helperAsset,
      dir.path,
    );
    if (!helperResult) {
      throw Exception('复制 clash_sing_helper.exe 资源失败');
    }
    debugPrint('flutter_sing_box 插件初始化 Windows 平台 endTime = ${DateTime.now()}');
  }

  /// 基于 exe 同目录构造 HelperCli（每次调用重建，无状态，轻量）。
  HelperCli _buildCli(io.Directory dir) {
    return HelperCli(helperExePath: p.join(dir.path, WindowsConstants.helperFileName));
  }

  /// 查询 Windows 端 `clash_sing_service` 的安装/运行状态。
  ///
  /// 流程：定位 helper.exe → 不存在直接返回 error → 委托 HelperCli.status。
  /// 任何异常（超时、进程失败）由 HelperCli 归一为 [WindowsServiceStatus.error]。
  /// 进程非零退出（含 helper.json 缺失等导致的 Go panic）同样由 HelperCli
  /// 归一为 [WindowsServiceStatus.error]，调用方无需区分具体失败原因。
  @override
  Future<WindowsServiceStatus> queryServiceStatus() async {
    try {
      final io.Directory dir = await ProfileStorage().getStorageDirectory();
      final io.File helperExe = io.File(p.join(dir.path, WindowsConstants.helperFileName));
      if (!await helperExe.exists()) {
        return WindowsServiceStatus.notInstalled;
      }
      final io.File configFile = io.File(p.join(dir.path, WindowsConstants.helperConfigFileName));
      if (!await configFile.exists()) {
        return WindowsServiceStatus.notInstalled;
      }
      final cli = _buildCli(dir);
      return cli.status();
    } catch (_) {
      return WindowsServiceStatus.error;
    }
  }

  @override
  Future<bool> installService({
    required String serviceName,
    required String displayName,
    required String description,
  }) async {
    try {
      final io.Directory dir = await ProfileStorage().getStorageDirectory();
      final String usingConfig = (await ProfileStorage().getUsingConfig()).path;
      HelperConfig config = HelperConfig(
        helperServiceName: serviceName,
        helperServiceDisplayName: displayName,
        helperServiceDescription: description,
        singBoxExecute: p.join(dir.path, WindowsConstants.singBoxFileName),
        singBoxConfig: usingConfig,
      );
      final io.File helperExe = io.File(p.join(dir.path, WindowsConstants.helperFileName));
      if (!await helperExe.exists()) {
        return false;
      }
      final cli = _buildCli(dir);
      return cli.install(config);
    } catch (e) {
      debugPrint('flutter_sing_box 插件安装服务失败, $e');
      return false;
    }
  }

  @override
  Future<bool> uninstallService() async {
    try {
      final io.Directory dir = await ProfileStorage().getStorageDirectory();
      final io.File helperExe = io.File(p.join(dir.path, WindowsConstants.helperFileName));
      if (!await helperExe.exists()) {
        return false;
      }
      final cli = _buildCli(dir);
      return cli.uninstall();
    } catch (e) {
      debugPrint('flutter_sing_box 插件卸载服务失败, $e');
      return false;
    }
  }

  @override
  Future<bool> startService() async {
    try {
      final io.Directory dir = await ProfileStorage().getStorageDirectory();
      final io.File helperExe = io.File(p.join(dir.path, WindowsConstants.helperFileName));
      if (!await helperExe.exists()) {
        return false;
      }
      final cli = _buildCli(dir);
      return cli.start();
    } catch (e) {
      debugPrint('flutter_sing_box 插件启动服务失败, $e');
      return false;
    }
  }

  @override
  Future<bool> stopService() async {
    try {
      final io.Directory dir = await ProfileStorage().getStorageDirectory();
      final io.File helperExe = io.File(p.join(dir.path, WindowsConstants.helperFileName));
      if (!await helperExe.exists()) {
        return false;
      }
      final cli = _buildCli(dir);
      return cli.stop();
    } catch (e) {
      debugPrint('flutter_sing_box 插件停止服务失败, $e');
      return false;
    }
  }

  @override
  Future<String> getSingBoxVersion() async {
    return '1.13.14';
  }
}
