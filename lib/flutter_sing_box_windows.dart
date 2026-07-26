import 'dart:async';
import 'dart:io' as io;
import 'package:flutter_sing_box/src/constants/windows_constants.dart';
import 'package:flutter_sing_box/src/windows/helper_http_client.dart';
import 'package:flutter_sing_box/src/windows/clash_http_client.dart';
import 'package:path/path.dart' as p;
import 'package:flutter/foundation.dart';
import 'package:flutter_sing_box/flutter_sing_box.dart';
import 'package:flutter_sing_box/flutter_sing_box_platform_interface.dart';
import 'package:flutter_sing_box/src/windows/helper_cli.dart';

class FlutterSingBoxWindows extends FlutterSingBoxPlatform {
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
    final serviceStatus = await queryServiceStatus();
    if (serviceStatus == WindowsServiceStatus.running ||
        serviceStatus == WindowsServiceStatus.stopped) {
      HelperHttpClient().status();
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

  @override
  Future<void> startVpn() async {
    await HelperHttpClient().start();
  }

  @override
  Future<void> stopVpn() async {
    await HelperHttpClient().stop();
  }

  @override
  Future<void> serviceReload() async {
    await HelperHttpClient().restart();
  }

  ProxyState _lastProxyState = ProxyState.stopped;
  StreamController<ProxyState>? _proxyStateStreamController;

  StreamController<ProxyState> get _controller {
    _proxyStateStreamController ??= StreamController<ProxyState>.broadcast();
    return _proxyStateStreamController!;
  }

  /// 供 HelperHttpClient 调用,取代直接访问 controller。
  ///
  /// 连接成功(started)时顺带后台刷新代理模式——clash mode 的数据来源与推送
  /// 都内聚在本类,HelperHttpClient 只管 helper service 控制与状态转发。
  void emitProxyState(ProxyState state) {
    _lastProxyState = state;
    _controller.add(state);
    if (state == ProxyState.started) {
      unawaited(_refreshClashMode());
      unawaited(_refreshClientGroup());
    }
  }

  /// 连接成功后拉取代理模式并回推到 clashModeStream。
  ///
  /// fire-and-forget: 失败仅 debugPrint,不影响 proxyState 流、不阻塞连接流程。
  /// 9090 在 sing-box 进程刚拉起时未必就绪,故重试 3 次、间隔 800ms。
  Future<void> _refreshClashMode() async {
    const int maxAttempts = 3;
    const Duration interval = Duration(milliseconds: 800);
    for (int i = 0; i < maxAttempts; i++) {
      try {
        final mode = await ClashHttpClient().getClashMode();
        emitClashMode(mode);
        return;
      } catch (e) {
        debugPrint('拉取 clash mode 失败 (第 ${i + 1}/$maxAttempts 次): $e');
        if (i < maxAttempts - 1) {
          await Future.delayed(interval);
        }
      }
    }
    debugPrint('拉取 clash mode 最终失败,放弃本轮刷新');
  }

  Future<void> _refreshClientGroup() async {
    const int maxAttempts = 3;
    const Duration interval = Duration(milliseconds: 800);
    for (int i = 0; i < maxAttempts; i++) {
      try {
        final groups = await ClashHttpClient().getGroups();
        emitClientGroups(groups);
        return;
      } catch (e) {
        debugPrint('拉取 proxies 失败 (第 ${i + 1}/$maxAttempts 次): $e');
        if (i < maxAttempts - 1) {
          await Future.delayed(interval);
        }
      }
    }
    debugPrint('拉取 proxies 最终失败,放弃本轮刷新');
  }

  /// TODO: async* 的理论竞态，可改为 Stream.multi。但竞态窗口极窄，无需 Stream.multi。
  @override
  Stream<ProxyState> get proxyStateStream async* {
    yield _lastProxyState; // 新订阅者立即拿到当前状态
    yield* _controller.stream;
  }

  StreamController<ClientClashMode>? _clashModeStreamController;
  ClientClashMode? _lastClashMode;

  StreamController<ClientClashMode> get _clashModeController {
    _clashModeStreamController ??= StreamController<ClientClashMode>.broadcast();
    return _clashModeStreamController!;
  }

  /// 供 HelperHttpClient 在连接成功后回调,取代直接访问 controller。
  void emitClashMode(ClientClashMode mode) {
    _lastClashMode = mode;
    _clashModeController.add(mode);
  }

  /// TODO: async* 的理论竞态,可改为 Stream.multi。但竞态窗口极窄,与 proxyStateStream 一致。
  @override
  Stream<ClientClashMode> get clashModeStream async* {
    if (_lastClashMode != null) yield _lastClashMode!; // 新订阅者立即拿到当前模式
    yield* _clashModeController.stream;
  }

  StreamController<List<ClientGroup>>? _clientGroupStreamController;
  List<ClientGroup>? _clientGroups;

  StreamController<List<ClientGroup>> get _clientGroupController {
    _clientGroupStreamController ??= StreamController<List<ClientGroup>>.broadcast();
    return _clientGroupStreamController!;
  }

  /// 供 HelperHttpClient 在连接成功后回调,取代直接访问 controller。
  void emitClientGroups(List<ClientGroup> groups) {
    _clientGroups = groups;
    _clientGroupController.add(groups);
  }

  @override
  Stream<List<ClientGroup>> get groupStream async* {
    if (_clientGroups != null) yield _clientGroups!; // 新订阅者立即拿到当前模式
    yield* _clientGroupController.stream;
  }

  void dispose() {
    _proxyStateStreamController?.close();
    _proxyStateStreamController = null;
    _clashModeStreamController?.close();
    _clashModeStreamController = null;
    _clientGroupStreamController?.close();
    _clientGroupStreamController = null;
  }
}
