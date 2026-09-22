import 'package:flutter_sing_box/src/constants/windows_constants.dart';
import 'package:flutter_sing_box/src/windows/windows_arch.dart';
import 'package:flutter_test/flutter_test.dart';

/// WindowsConstants 单测：双架构资产目录改造后，asset 路径必须带上
/// 与真机架构匹配的子目录段，而文件名常量保持不变（释放目标路径、
/// helper.json、App 侧与 clash_sing_service 侧都依赖这些文件名）。
/// asset key 的插件前缀取自 FlutterSingBoxConstants.assetBasePath
/// （packages/flutter_sing_box/）。
void main() {
  const String base = 'packages/flutter_sing_box/assets/windows';

  setUp(WindowsArch.resetForTest);

  group('WindowsConstants asset 路径', () {
    test('amd64 真机 → asset 路径带 amd64 段', () {
      WindowsArch.resolver = () => 9;
      expect(WindowsConstants.singBoxAsset, '$base/amd64/sing-box.exe');
      expect(WindowsConstants.libcronetAsset, '$base/amd64/libcronet.dll');
      expect(WindowsConstants.helperAsset, '$base/amd64/clash_sing_helper.exe');
    });

    test('arm64 真机 → asset 路径带 arm64 段', () {
      WindowsArch.resolver = () => 12;
      expect(WindowsConstants.singBoxAsset, '$base/arm64/sing-box.exe');
      expect(WindowsConstants.libcronetAsset, '$base/arm64/libcronet.dll');
      expect(WindowsConstants.helperAsset, '$base/arm64/clash_sing_helper.exe');
    });

    test('文件名常量不含架构段（下游路径契约不变）', () {
      expect(WindowsConstants.singBoxFileName, 'sing-box.exe');
      expect(WindowsConstants.libcronetFileName, 'libcronet.dll');
      expect(WindowsConstants.helperFileName, 'clash_sing_helper.exe');
      expect(WindowsConstants.helperConfigFileName, 'helper.json');
    });
  });
}
