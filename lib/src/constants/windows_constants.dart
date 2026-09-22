import 'package:flutter_sing_box/flutter_sing_box.dart';
import 'package:flutter_sing_box/src/windows/windows_arch.dart';

abstract class WindowsConstants {
  static const String singBoxFileName = 'sing-box.exe';
  static const String libcronetFileName = 'libcronet.dll';
  static const String helperFileName = 'clash_sing_helper.exe';
  static const String helperConfigFileName = 'helper.json';

  static String get singBoxAsset => '$_assetPath$singBoxFileName';
  static String get libcronetAsset => '$_assetPath$libcronetFileName';
  static String get helperAsset => '$_assetPath$helperFileName';

  /// 资产基路径按真机架构取子目录（amd64 / arm64），见 [WindowsArch]。
  static String get _assetPath =>
      '${FlutterSingBoxConstants.assetBasePath}windows/${WindowsArch.current()}/';
}
