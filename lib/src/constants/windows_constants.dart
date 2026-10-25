import 'package:flutter_sing_box/flutter_sing_box.dart';
import 'package:flutter_sing_box/src/windows/windows_arch.dart';

/// Windows 平台相关常量（文件名 / 资产路径 / 轮询间隔）。
abstract class WindowsConstants {
  /// sing-box 内核可执行文件名。
  static const String singBoxFileName = 'sing-box.exe';
  /// libcronet 动态库文件名。
  static const String libcronetFileName = 'libcronet.dll';
  /// helper 服务程序文件名。
  static const String helperFileName = 'clash_sing_helper.exe';
  /// helper 服务配置文件名。
  static const String helperConfigFileName = 'helper.json';

  /// helper 存活轮询间隔：连接期间探测 helper /status 以感知 helper/sing-box 异常退出。
  static const Duration helperWatchInterval = Duration(seconds: 3);

  /// sing-box.exe 的打包资产路径（按真机架构取子目录）。
  static String get singBoxAsset => '$_assetPath$singBoxFileName';
  /// libcronet.dll 的打包资产路径（按真机架构取子目录）。
  static String get libcronetAsset => '$_assetPath$libcronetFileName';
  /// clash_sing_helper.exe 的打包资产路径（按真机架构取子目录）。
  static String get helperAsset => '$_assetPath$helperFileName';

  /// 资产基路径按真机架构取子目录（amd64 / arm64），见 [WindowsArch]。
  static String get _assetPath =>
      '${FlutterSingBoxConstants.assetBasePath}windows/${WindowsArch.current()}/';
}
