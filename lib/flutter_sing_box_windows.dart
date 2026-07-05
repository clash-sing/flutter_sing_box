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
}
