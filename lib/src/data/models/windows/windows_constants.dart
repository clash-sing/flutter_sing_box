import 'package:flutter_sing_box/flutter_sing_box.dart';

abstract class WindowsConstants {
  static const String singBoxFileName = 'sing-box.exe';
  static const String libcronetFileName = 'libcronet.dll';
  static const String helperFileName = 'clash_sing_helper.exe';
  static const String helperConfigFileName = 'helper.json';

  static String get singBoxAsset => '$_assetPath$singBoxFileName';
  static String get libcronetAsset => '$_assetPath$libcronetFileName';
  static String get helperAsset => '$_assetPath$helperFileName';

  static String get _assetPath => '${FlutterSingBoxConstants.assetBasePath}windows/';
}
