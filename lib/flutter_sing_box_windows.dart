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
import 'package:flutter_sing_box/src/windows/system_proxy_service.dart';

/// Windows 平台的 [FlutterSingBoxPlatform] 纯 Dart 实现。
///
/// 经内置 helper 驱动系统服务托管 sing-box；代理生命周期状态集中在
/// [proxyStateStream]（启动失败不抛出，经该流下发）。
class FlutterSingBoxWindows extends FlutterSingBoxPlatform {
  /// 注册本实现为平台默认实例（由 Windows C-API 桩调用）。
  static void registerWith() {
    FlutterSingBoxPlatform.instance = FlutterSingBoxWindows();
  }

  /// 初始化：释放 sing-box.exe / libcronet.dll / clash_sing_helper.exe 到应用目录，
  /// 并清除上次异常退出遗留的系统代理（崩溃自愈）。
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
    // 崩溃自愈: 若上次异常退出遗留了系统代理,且 sing-box 当前未运行,则清除
    if (CsSettingsStorage().systemProxyActive) {
      final status = await queryServiceStatus();
      if (status != WindowsServiceStatus.running) {
        await SystemProxyService().disable();
      }
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
      return await cli.status();
    } catch (_) {
      return WindowsServiceStatus.error;
    }
  }

  /// 安装 Windows 系统服务（UAC 提权经 helper CLI）。
  ///
  /// 服务可执行文件与 sing-box 配置路径由 [ProfileStorage] 当前使用项决定。
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
      return await cli.install(config);
    } catch (e) {
      debugPrint('flutter_sing_box 插件安装服务失败, $e');
      return false;
    }
  }

  /// 卸载 Windows 系统服务；helper.exe 缺失或异常时返回 `false`。
  @override
  Future<bool> uninstallService() async {
    try {
      final io.Directory dir = await ProfileStorage().getStorageDirectory();
      final io.File helperExe = io.File(p.join(dir.path, WindowsConstants.helperFileName));
      if (!await helperExe.exists()) {
        return false;
      }
      final cli = _buildCli(dir);
      return await cli.uninstall();
    } catch (e) {
      debugPrint('flutter_sing_box 插件卸载服务失败, $e');
      return false;
    }
  }

  /// 启动已安装的 Windows 系统服务；helper.exe 缺失或异常时返回 `false`。
  @override
  Future<bool> startService() async {
    try {
      final io.Directory dir = await ProfileStorage().getStorageDirectory();
      final io.File helperExe = io.File(p.join(dir.path, WindowsConstants.helperFileName));
      if (!await helperExe.exists()) {
        return false;
      }
      final cli = _buildCli(dir);
      return await cli.start();
    } catch (e) {
      debugPrint('flutter_sing_box 插件启动服务失败, $e');
      return false;
    }
  }

  /// 停止 Windows 系统服务；helper.exe 缺失或异常时返回 `false`。
  @override
  Future<bool> stopService() async {
    try {
      final io.Directory dir = await ProfileStorage().getStorageDirectory();
      final io.File helperExe = io.File(p.join(dir.path, WindowsConstants.helperFileName));
      if (!await helperExe.exists()) {
        return false;
      }
      final cli = _buildCli(dir);
      return await cli.stop();
    } catch (e) {
      debugPrint('flutter_sing_box 插件停止服务失败, $e');
      return false;
    }
  }

  /// 返回内置 sing-box 内核版本号（随打包内核升级同步更新）。
  @override
  Future<String> getSingBoxVersion() async {
    return '1.14.4';
  }

  /// 经 helper HTTP API 启动代理（失败不抛出，原因经 [proxyStateStream] 下发）。
  @override
  Future<void> startVpn() async {
    await HelperHttpClient().start();
  }

  /// 经 helper HTTP API 停止代理。
  @override
  Future<void> stopVpn() async {
    await HelperHttpClient().stop();
  }

  /// 经 helper HTTP API 重启代理（等价于配置重载）。
  @override
  Future<void> serviceReload() async {
    await HelperHttpClient().restart();
  }

  /// 经 Clash API 设置代理模式，并在后台异步刷新模式流。
  @override
  Future<void> setClashMode(String mode) async {
    await ClashHttpClient().setClashMode(mode);
    unawaited(_refreshClashMode());
  }

  /// 经 Clash API 在 [groupTag] 分组中选中 [outboundTag] 出站。
  @override
  Future<void> selectOutbound({required String groupTag, required String outboundTag}) async {
    await ClashHttpClient().setOutbound(groupTag: groupTag, outboundTag: outboundTag);
  }

  /// Windows 端无持久化展开状态，空实现。
  @override
  Future<void> setGroupExpand({required String groupTag, required bool isExpand}) async {}

  /// 经 Clash API 对 [groupTag] 分组执行 URL 测速。
  @override
  Future<void> urlTest({required String groupTag}) async {
    await ClashHttpClient().testGroup(groupTag);
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
      _startGroupRefresh();
      _startLogSubscribe();
      _startHelperWatch();
      // 系统代理模式：sing-box 已起，设系统代理
      if (CsSettingsStorage().proxyMode == ProxyMode.systemProxy) {
        unawaited(SystemProxyService().enable());
      }
    } else {
      // 任何离开 started 的状态（启动中/停止中/已停止）都终止存活轮询
      _cancelHelperWatch();
      // is ProxyStopped 覆盖带 errMessage 的异常停止（启动失败、内核崩溃、
      // 存活轮询发现的 helper 崩溃）——这些场景同样需要停副作用流、清系统代理
      if (state is ProxyStopped) {
        _cancelGroupRefresh();
        _cancelLogSubscribe();
        // 只要标志位说系统代理还开着就清(覆盖断开/切换重启/崩溃后停止)
        if (CsSettingsStorage().systemProxyActive) {
          unawaited(SystemProxyService().disable());
        }
      }
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

  /// group 轮询的「代」：每次启动新一轮自增,使上一轮自动退出;
  /// stopped / dispose 也自增以取消所有在飞轮询。
  int _groupRefreshGeneration = 0;

  /// 启动一轮新的 group 轮询;自增 generation 使上一轮自动退出,
  /// 天然处理 start/restart/status 多处重复触发 started 的并发防护。
  void _startGroupRefresh() {
    final int gen = ++_groupRefreshGeneration;
    unawaited(_refreshClientGroup(gen));
  }

  /// 取消所有在飞的 group 轮询(stopped / dispose 调用)。
  void _cancelGroupRefresh() {
    _groupRefreshGeneration++;
  }

  /// helper 存活轮询的「代」：每次启动新一轮自增使上一轮自动退出;
  /// 离开 started（停止中/已停止/重启过渡）与 dispose 也自增以取消所有在飞轮询。
  int _helperWatchGeneration = 0;

  /// 存活轮询间隔；默认 [WindowsConstants.helperWatchInterval]，测试可缩短。
  @visibleForTesting
  Duration helperWatchInterval = WindowsConstants.helperWatchInterval;

  /// 存活轮询的探测点：默认查 helper /status；测试可覆写。
  @visibleForTesting
  Future<String> Function() helperStatusProbe = () => HelperHttpClient().probeStatus();

  /// 启动一轮新的 helper 存活轮询;自增 generation 使上一轮自动退出,
  /// 天然处理 start/restart/status 多处重复触发 started 的并发防护。
  void _startHelperWatch() {
    final gen = ++_helperWatchGeneration;
    unawaited(_watchHelperAlive(gen));
  }

  /// 取消所有在飞的存活轮询(离开 started / dispose 调用)。
  void _cancelHelperWatch() {
    _helperWatchGeneration++;
  }

  /// 连接期间周期探测 helper /status,感知 helper 服务/sing-box 异常退出——
  /// 此前 helper 崩溃后 App 无从得知,UI 一直显示已连接(issue #19 验收反馈)。
  ///
  /// 探测返回 running 无动作;返回 stopped(sing-box 已退出)或连接失败
  /// (helper 服务崩溃,[_get] 重读配置重试后仍失败)时 emit 带 errMessage 的
  /// ProxyStopped 归位 UI,本轮监视结束。fire-and-forget,不影响连接流程。
  /// 用 [gen] 配合 [_helperWatchGeneration] 做取消与重复 started 的并发防护,
  /// emit 前复查 gen 与当前状态,避免用户主动 stop/restart 途中误报。
  Future<void> _watchHelperAlive(int gen) async {
    while (gen == _helperWatchGeneration && _lastProxyState == ProxyState.started) {
      await Future.delayed(helperWatchInterval);
      if (gen != _helperWatchGeneration || _lastProxyState != ProxyState.started) return;
      try {
        final status = await helperStatusProbe();
        if (gen != _helperWatchGeneration || _lastProxyState != ProxyState.started) return;
        if (status == 'running') continue;
        emitProxyState(const ProxyStopped(errMessage: '代理内核已停止运行。'));
        return;
      } catch (_) {
        if (gen != _helperWatchGeneration || _lastProxyState != ProxyState.started) return;
        emitProxyState(const ProxyStopped(errMessage: 'Clash Service 服务意外停止运行。'));
        return;
      }
    }
  }

  /// 连接成功后每秒持续拉取 proxies 回推 groupStream,直到 stopped / dispose 取消。
  ///
  /// fire-and-forget: 失败仅 debugPrint、不中断循环、不影响 proxyState 流。
  /// 串行循环(上一次完成才发下一次)避免请求重叠;用 [gen] 配合
  /// [_groupRefreshGeneration] 做取消与重复 started 的并发防护。
  Future<void> _refreshClientGroup(int gen) async {
    while (gen == _groupRefreshGeneration) {
      try {
        final groups = await ClashHttpClient().getGroups();
        // 拉取期间若已被取消(generation 变了),丢弃这次结果,避免把过期数据推给 UI。
        if (gen == _groupRefreshGeneration) {
          emitClientGroups(groups);
        }
      } catch (e) {
        debugPrint('拉取 proxies 失败: $e');
      }
      await Future.delayed(const Duration(seconds: 1));
    }
  }

  /// TODO: async* 的理论竞态，可改为 Stream.multi。但竞态窗口极窄，无需 Stream.multi。
  /// 代理状态流；新订阅者立即获得当前状态。
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
  /// Clash 模式流；新订阅者立即获得最近一次模式。
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

  /// 分组列表流；新订阅者立即获得最近一次分组数据。
  @override
  Stream<List<ClientGroup>> get groupStream async* {
    if (_clientGroups != null) yield _clientGroups!; // 新订阅者立即拿到当前模式
    yield* _clientGroupController.stream;
  }

  StreamController<List<ClientLog>>? _logStreamController;

  StreamController<List<ClientLog>> get _logController {
    _logStreamController ??= StreamController<List<ClientLog>>.broadcast();
    return _logStreamController!;
  }

  /// 推送日志到 logStream。日志是事件流而非状态，不做 _last 缓存重放
  /// （切页面的订阅者不应看到重复的最后一条），与 Android 端行为一致。
  void emitLogs(List<ClientLog> logs) {
    _logController.add(logs);
  }

  /// 内核日志流（事件型，不做缓存重放）。
  @override
  Stream<List<ClientLog>> get logStream => _logController.stream;

  StreamSubscription<List<ClientLog>>? _logSubscription;
  Timer? _logReconnectTimer;

  /// 启动 Clash API 日志 WS 订阅（started 时调用）。
  ///
  /// 重复 started（restart/status 多处触发）时先取消旧订阅再重连，天然幂等。
  void _startLogSubscribe() {
    _cancelLogSubscribe();
    _logSubscription = ClashHttpClient().subscribeLogs().listen(
      emitLogs,
      onError: (Object e) => debugPrint('日志流订阅出错: $e'),
      onDone: _scheduleLogReconnect,
    );
  }

  /// 取消日志订阅与在途重连（stopped / dispose 调用）。
  void _cancelLogSubscribe() {
    _logReconnectTimer?.cancel();
    _logReconnectTimer = null;
    unawaited(_logSubscription?.cancel());
    _logSubscription = null;
  }

  /// 断线/出错后延迟 2 秒重连：仅当仍处于 started 且未被显式取消。
  ///
  /// 重试间隔同时覆盖「started 时 sing-box 刚拉起、Clash API 尚未就绪」的场景，
  /// 与 [_refreshClashMode] 的重试理由一致。
  void _scheduleLogReconnect() {
    if (_lastProxyState != ProxyState.started) return;
    _logReconnectTimer?.cancel();
    _logReconnectTimer = Timer(const Duration(seconds: 2), () {
      if (_lastProxyState == ProxyState.started) {
        _startLogSubscribe();
      }
    });
  }

  /// 释放全部轮询任务与广播流控制器。
  void dispose() {
    _cancelGroupRefresh();
    _cancelHelperWatch();
    _cancelLogSubscribe();
    _proxyStateStreamController?.close();
    _proxyStateStreamController = null;
    _clashModeStreamController?.close();
    _clashModeStreamController = null;
    _clientGroupStreamController?.close();
    _clientGroupStreamController = null;
    _logStreamController?.close();
    _logStreamController = null;
  }
}
