import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_sing_box/flutter_sing_box.dart';
import 'package:flutter_sing_box/flutter_sing_box_platform_interface.dart';

/// macOS 平台的纯 Dart 兼容层实现（无代理/内核能力）。
///
/// 之所以是 Dart-only：本轮只保证插件 API 在 macOS 上安全可调用，
/// 不引入原生工程；真正的 macOS 代理能力（helper 或 NetworkExtension）
/// 留待后续方案。详见 doc/superpowers/specs/2026-11-14-macos-compatibility-layer-design.md。
class FlutterSingBoxMacos extends FlutterSingBoxPlatform {
  FlutterSingBoxMacos({Future<bool> Function()? ruleSetExtractor})
    : _ruleSetExtractor =
          ruleSetExtractor ?? (() => RuleSetAssets.ensureExtracted());

  /// 启动失败时下发的固定原因（UI 直接展示）。
  static const String unsupportedMessage = 'macOS 暂不支持启动代理（当前为兼容层）';

  final Future<bool> Function() _ruleSetExtractor;

  /// 注册本实现为平台默认实例（由 dart_plugin_registrant 调用）。
  static void registerWith() {
    FlutterSingBoxPlatform.instance = FlutterSingBoxMacos();
  }

  ProxyState _lastProxyState = ProxyState.stopped;

  StreamController<ProxyState>? _proxyStateController;
  StreamController<ProxyState> get _proxyStateControllerOrCreate =>
      _proxyStateController ??= StreamController<ProxyState>.broadcast();

  void _emit(ProxyState state) {
    _lastProxyState = state;
    _proxyStateControllerOrCreate.add(state);
  }

  Stream<ProxyState>? _proxyStateStream;

  /// 初始化：释放内置规则集（best-effort，失败不阻断启动）。
  @override
  Future<void> init() async {
    try {
      await _ruleSetExtractor();
    } catch (e) {
      debugPrint('macOS 释放内置规则集失败(忽略): $e');
    }
  }

  /// 当前平台无内核：经状态流下发「不支持」，不抛异常、不假装已连接。
  @override
  Future<void> startVpn() async {
    _emit(ProxyState.starting);
    _emit(const ProxyStopped(errMessage: unsupportedMessage));
  }

  /// 未启动过内核，仅归位状态机。
  @override
  Future<void> stopVpn() async {
    _emit(const ProxyStopped());
  }

  /// 当前平台无内核，空实现。
  @override
  Future<void> serviceReload() async {}

  /// 当前平台无内核，空实现。
  @override
  Future<void> setClashMode(String mode) async {}

  /// 当前平台无内核，空实现。
  @override
  Future<void> selectOutbound({
    required String groupTag,
    required String outboundTag,
  }) async {}

  /// 当前平台无内核，空实现。
  @override
  Future<void> setGroupExpand({
    required String groupTag,
    required bool isExpand,
  }) async {}

  /// 当前平台无内核，空实现。
  @override
  Future<void> urlTest({required String groupTag}) async {}

  /// 当前平台未内置内核。
  @override
  Future<String> getSingBoxVersion() async => 'unsupported';

  /// 非 Windows 平台无系统服务概念。
  @override
  Future<WindowsServiceStatus> queryServiceStatus() async =>
      WindowsServiceStatus.unsupported;

  /// 与非 Windows 的 MethodChannel 默认实现保持一致。
  @override
  Future<bool> installService({
    required String serviceName,
    required String displayName,
    required String description,
  }) async => true;

  /// 非 Windows 平台无系统服务概念。
  @override
  Future<bool> uninstallService() async => false;

  /// 非 Windows 平台无系统服务概念。
  @override
  Future<bool> startService() async => false;

  /// 非 Windows 平台无系统服务概念。
  @override
  Future<bool> stopService() async => false;

  /// 非 Windows 平台无 helper 更新概念。
  @override
  Future<bool> hasPendingHelperUpdate() async => false;

  /// 非 Windows 平台无 helper 服务概念。
  @override
  Future<bool> restartService() async => false;

  /// 代理状态流（广播流：同一 stream 对象可多次订阅）。
  ///
  /// 用 [Stream.multi] 而非 `async*`：`async*` 返回单订阅流，缓存后二次
  /// listen 会抛 Bad state；且其 onListen 延迟到微任务，同一轮次内
  /// listen 后立刻调用 [startVpn] 会丢掉 `ProxyStarting` 事件。
  /// 每个新订阅者先收到当前状态，之后接收状态变化。
  @override
  Stream<ProxyState> get proxyStateStream {
    return _proxyStateStream ??= Stream<ProxyState>.multi((controller) {
      controller.add(_lastProxyState);
      final sub = _proxyStateControllerOrCreate.stream.listen(
        controller.add,
        onError: controller.addError,
      );
      controller.onCancel = sub.cancel;
    }, isBroadcast: true);
  }

  /// 兼容层无连接状态数据，返回空广播流。
  @override
  Stream<ClientStatus> get connectedStatusStream =>
      const Stream<ClientStatus>.empty();

  /// 兼容层无分组数据，返回空广播流。
  @override
  Stream<List<ClientGroup>> get groupStream =>
      const Stream<List<ClientGroup>>.empty();

  /// 兼容层无 Clash 模式数据，返回空广播流。
  @override
  Stream<ClientClashMode> get clashModeStream =>
      const Stream<ClientClashMode>.empty();

  /// 兼容层无内核日志，返回空广播流。
  @override
  Stream<List<ClientLog>> get logStream =>
      const Stream<List<ClientLog>>.empty();
}
