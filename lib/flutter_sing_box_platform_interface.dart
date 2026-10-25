import 'package:flutter_sing_box/flutter_sing_box.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

/// flutter_sing_box 各平台实现必须实现的平台接口。
///
/// 平台实现应继承本类而非以 `interface` 方式实现；
/// 未被平台实现覆写的方法默认抛出 [UnimplementedError]。
abstract class FlutterSingBoxPlatform extends PlatformInterface {
  /// 构造 [FlutterSingBoxPlatform]。
  FlutterSingBoxPlatform() : super(token: _token);

  static final Object _token = Object();

  static FlutterSingBoxPlatform _instance = MethodChannelFlutterSingBox();

  /// 平台默认实例，缺省为 [MethodChannelFlutterSingBox]。
  static FlutterSingBoxPlatform get instance => _instance;

  /// 平台实现注册自身时调用；token 校验阻止外部误设。
  static set instance(FlutterSingBoxPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  /// 初始化平台接口。
  Future<void> init() async {
    throw UnimplementedError('init() has not been implemented.');
  }

  /// 启动 VPN 服务。
  Future<void> startVpn() async {
    throw UnimplementedError('startVpn() has not been implemented.');
  }

  /// 停止 VPN 服务。
  Future<void> stopVpn() async {
    throw UnimplementedError('stopVpn() has not been implemented.');
  }

  /// 重载服务配置。
  Future<void> serviceReload() async {
    throw UnimplementedError('serviceReload() has not been implemented.');
  }

  /// 设置 Clash 模式。
  Future<void> setClashMode(String mode) async {
    throw UnimplementedError('setClashMode() has not been implemented.');
  }

  /// 在分组中选中指定出站。
  Future<void> selectOutbound({required String groupTag, required String outboundTag}) async {
    throw UnimplementedError('selectOutbound() has not been implemented.');
  }

  /// 设置分组的展开状态。
  Future<void> setGroupExpand({required String groupTag, required bool isExpand}) async {
    throw UnimplementedError('setGroupExpand() has not been implemented.');
  }

  /// 对指定分组执行 URL 测速。
  Future<void> urlTest({required String groupTag}) async {
    throw UnimplementedError('urlTest() has not been implemented.');
  }

  /// 获取底层 sing-box 内核版本号。
  Future<String> getSingBoxVersion() async {
    throw UnimplementedError('getSingBoxVersion() has not been implemented.');
  }

  /// 查询 Windows 端 `clash_sing_service` 的安装/运行状态。
  ///
  /// 仅 Windows 平台实现真正执行（调用 clash_sing_helper.exe status）；
  /// 其他平台返回 [WindowsServiceStatus.unsupported]。
  Future<WindowsServiceStatus> queryServiceStatus() {
    throw UnimplementedError('queryServiceStatus() has not been implemented.');
  }

  /// 安装 Windows 系统服务。
  ///
  /// 仅 Windows 平台实现真正执行；其他平台返回 `false`。
  Future<bool> installService({
    required String serviceName,
    required String displayName,
    required String description,
  }) async {
    throw UnimplementedError('installService() has not been implemented.');
  }

  /// 卸载 Windows 系统服务。
  ///
  /// 仅 Windows 平台实现真正执行（UAC 提权调用 clash_sing_helper.exe uninstall
  /// 并轮询确认）；其他平台返回 `false`。
  Future<bool> uninstallService() async {
    throw UnimplementedError('uninstallService() has not been implemented.');
  }

  /// 启动已安装的 Windows 系统服务。
  Future<bool> startService() async {
    throw UnimplementedError('startService() has not been implemented.');
  }

  /// 停止 Windows 系统服务（helper 内部走 HTTP API 同步关闭）。
  Future<bool> stopService() async {
    throw UnimplementedError('stopService() has not been implemented.');
  }

  /// 客户端连接状态的更新流。
  Stream<ClientStatus> get connectedStatusStream {
    throw UnimplementedError('connectedStatusStream has not been implemented.');
  }

  /// 分组列表的更新流。
  Stream<List<ClientGroup>> get groupStream {
    throw UnimplementedError('groupStream has not been implemented.');
  }

  /// Clash 模式的更新流。
  Stream<ClientClashMode> get clashModeStream {
    throw UnimplementedError('clashModeStream has not been implemented.');
  }

  /// sing-box 内核日志的更新流（按批推送）。
  Stream<List<ClientLog>> get logStream {
    throw UnimplementedError('logStream has not been implemented.');
  }

  /// 代理生命周期状态的更新流（启动失败原因也经此流下发）。
  Stream<ProxyState> get proxyStateStream {
    throw UnimplementedError('proxyStateStream has not been implemented.');
  }
}
