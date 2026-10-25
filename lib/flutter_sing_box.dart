export '../src/data/models/index.dart';
export '../src/data/network/index.dart';
export '../src/constants/index.dart';
export '../src/utils/index.dart';
export '../src/core/index.dart';
export '../src/storage/index.dart';

// 导出各平台的 Dart 实现，供 Flutter 自动生成的 dart_plugin_registrant.dart
// 通过主 library 访问并调用其 registerWith()（pubspec 中已声明 dartPluginClass）。
export 'flutter_sing_box_method_channel.dart';
export 'flutter_sing_box_windows.dart';

import 'flutter_sing_box.dart';
import 'flutter_sing_box_platform_interface.dart';

/// flutter_sing_box 插件的主入口，封装全部跨平台能力。
class FlutterSingBox {
  /// 初始化插件。
  Future<void> init() async {
    return await FlutterSingBoxPlatform.instance.init();
  }

  /// 启动 VPN 服务。
  Future<void> startVpn() async {
    return await FlutterSingBoxPlatform.instance.startVpn();
  }

  /// 停止 VPN 服务。
  Future<void> stopVpn() async {
    return await FlutterSingBoxPlatform.instance.stopVpn();
  }

  /// 重载服务配置。
  Future<void> serviceReload() async {
    return await FlutterSingBoxPlatform.instance.serviceReload();
  }

  /// 设置 Clash 模式（如 `Global` / `Rule` / `Direct`）。
  Future<void> setClashMode(String clashMode) async {
    return await FlutterSingBoxPlatform.instance.setClashMode(clashMode);
  }

  /// 在 [groupTag] 分组中选中 [outboundTag] 出站。
  Future<void> selectOutbound({required String groupTag, required String outboundTag}) async {
    return await FlutterSingBoxPlatform.instance.selectOutbound(
      groupTag: groupTag,
      outboundTag: outboundTag,
    );
  }

  /// 将 [groupTag] 分组置为 [isExpand] 指定的展开/收起状态。
  Future<void> setGroupExpand({required String groupTag, required bool isExpand}) async {
    return await FlutterSingBoxPlatform.instance.setGroupExpand(
      groupTag: groupTag,
      isExpand: isExpand,
    );
  }

  /// 对 [groupTag] 分组执行 URL 测速。
  Future<void> urlTest({required String groupTag}) async {
    return await FlutterSingBoxPlatform.instance.urlTest(groupTag: groupTag);
  }

  /// 获取底层 sing-box 内核版本号。
  Future<String> getSingBoxVersion() async {
    return await FlutterSingBoxPlatform.instance.getSingBoxVersion();
  }

  /// 查询 Windows 端 `clash_sing_service` 的安装/运行状态。
  Future<WindowsServiceStatus> queryServiceStatus() {
    return FlutterSingBoxPlatform.instance.queryServiceStatus();
  }

  /// 安装 Windows 系统服务（UAC 提权，仅 Windows 平台实际执行）。
  ///
  /// [serviceName] 服务名，[displayName] 显示名，[description] 描述文案。
  Future<bool> installService({
    required String serviceName,
    required String displayName,
    required String description,
  }) {
    return FlutterSingBoxPlatform.instance.installService(
      serviceName: serviceName,
      displayName: displayName,
      description: description,
    );
  }

  /// 卸载 Windows 系统服务。
  Future<bool> uninstallService() {
    return FlutterSingBoxPlatform.instance.uninstallService();
  }

  /// 启动已安装的 Windows 系统服务。
  Future<bool> startService() {
    return FlutterSingBoxPlatform.instance.startService();
  }

  /// 停止 Windows 系统服务。
  Future<bool> stopService() {
    return FlutterSingBoxPlatform.instance.stopService();
  }

  /// 客户端连接状态的更新流。
  Stream<ClientStatus> get connectedStatusStream =>
      FlutterSingBoxPlatform.instance.connectedStatusStream;

  /// 分组列表的更新流。
  Stream<List<ClientGroup>> get groupStream => FlutterSingBoxPlatform.instance.groupStream;

  /// Clash 模式的更新流。
  Stream<ClientClashMode> get clashModeStream => FlutterSingBoxPlatform.instance.clashModeStream;

  /// sing-box 内核日志的更新流（按批推送）。
  Stream<List<ClientLog>> get logStream => FlutterSingBoxPlatform.instance.logStream;

  /// 代理生命周期状态的更新流（启动失败原因也经此流下发）。
  Stream<ProxyState> get proxyStateStream => FlutterSingBoxPlatform.instance.proxyStateStream;
}
