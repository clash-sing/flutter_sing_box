/// 代理（VPN）服务的生命周期状态。
///
/// sealed class 形态：四个状态各为一个子类，经模式匹配穷尽处理。
/// 仅 [ProxyStopped] 携带数据（[ProxyStopped.errMessage]）。
sealed class ProxyState {
  const ProxyState();

  /// 已停止（无错误信息）。供 `state == ProxyState.stopped` 这类存量比较使用。
  static const ProxyStopped stopped = ProxyStopped();

  /// 正在启动。
  static const ProxyStarting starting = ProxyStarting();

  /// 已启动。
  static const ProxyStarted started = ProxyStarted();

  /// 正在停止。
  static const ProxyStopping stopping = ProxyStopping();

  /// 该状态的显示名（EventChannel 传输字符串与 UI 展示共用）。
  String get name;

  /// 解析显示名到对应状态；未知值兜底为无错误信息的 [stopped]。
  static ProxyState fromName(String name) => switch (name) {
    ProxyStopped._stateName => const ProxyStopped(),
    ProxyStarting._stateName => const ProxyStarting(),
    ProxyStarted._stateName => const ProxyStarted(),
    ProxyStopping._stateName => const ProxyStopping(),
    _ => const ProxyStopped(),
  };
}

/// 已停止。
///
/// [errMessage] 非 null 表示异常停止（启动失败、内核崩溃等），为 null 表示正常停止。
final class ProxyStopped extends ProxyState {
  const ProxyStopped({this.errMessage});

  static const _stateName = 'Stopped';

  /// 异常停止的原因；正常停止时为 null。
  final String? errMessage;

  @override
  String get name => _stateName;

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is ProxyStopped && other.errMessage == errMessage;

  @override
  int get hashCode => Object.hash(ProxyStopped, errMessage);

  @override
  String toString() =>
      errMessage == null ? 'ProxyStopped' : 'ProxyStopped(errMessage: $errMessage)';
}

/// 正在启动。
final class ProxyStarting extends ProxyState {
  const ProxyStarting();

  static const _stateName = 'Starting';

  @override
  String get name => _stateName;

  @override
  String toString() => 'ProxyStarting';
}

/// 已启动。
final class ProxyStarted extends ProxyState {
  const ProxyStarted();

  static const _stateName = 'Started';

  @override
  String get name => _stateName;

  @override
  String toString() => 'ProxyStarted';
}

/// 正在停止。
final class ProxyStopping extends ProxyState {
  const ProxyStopping();

  static const _stateName = 'Stopping';

  @override
  String get name => _stateName;

  @override
  String toString() => 'ProxyStopping';
}
