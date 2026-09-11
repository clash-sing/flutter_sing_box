import 'package:flutter_sing_box/flutter_sing_box.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ProxyState.fromName', () {
    test('解析四个合法状态名', () {
      expect(ProxyState.fromName('Stopped'), ProxyState.stopped);
      expect(ProxyState.fromName('Starting'), ProxyState.starting);
      expect(ProxyState.fromName('Started'), ProxyState.started);
      expect(ProxyState.fromName('Stopping'), ProxyState.stopping);
    });

    test('未知状态名兜底为 stopped（无错误信息）', () {
      final state = ProxyState.fromName('unknown');
      expect(state, isA<ProxyStopped>());
      expect((state as ProxyStopped).errMessage, isNull);
    });
  });

  group('相等性', () {
    test('兼容常量与对应 const 实例相等', () {
      expect(ProxyState.stopped, const ProxyStopped());
      expect(ProxyState.starting, const ProxyStarting());
      expect(ProxyState.started, const ProxyStarted());
      expect(ProxyState.stopping, const ProxyStopping());
    });

    test('ProxyStopped 按 errMessage 值相等（含 hashCode 一致）', () {
      expect(const ProxyStopped(errMessage: 'x'), ProxyStopped(errMessage: 'x'));
      expect(
        const ProxyStopped(errMessage: 'x').hashCode,
        ProxyStopped(errMessage: 'x').hashCode,
      );
      expect(const ProxyStopped(), const ProxyStopped(errMessage: null));
    });

    test('不同 errMessage 的 stopped 互不相等', () {
      expect(const ProxyStopped(errMessage: 'x') == const ProxyStopped(errMessage: 'y'), isFalse);
      expect(const ProxyStopped() == const ProxyStopped(errMessage: 'x'), isFalse);
    });

    test('跨状态类型互不相等', () {
      expect(ProxyState.stopped == ProxyState.starting, isFalse);
      expect(ProxyState.started == ProxyState.stopping, isFalse);
    });
  });

  test('name 显示名与原 enum 保持一致', () {
    expect(ProxyState.stopped.name, 'Stopped');
    expect(ProxyState.starting.name, 'Starting');
    expect(ProxyState.started.name, 'Started');
    expect(ProxyState.stopping.name, 'Stopping');
  });

  test('switch 模式匹配可解构 errMessage 且穷尽', () {
    // 不写 default 分支即验证 sealed 穷尽性：漏任一子类编译不过
    String? messageOf(ProxyState state) => switch (state) {
      ProxyStopped(:final errMessage) => errMessage,
      ProxyStarting() => null,
      ProxyStarted() => null,
      ProxyStopping() => null,
    };
    expect(messageOf(const ProxyStopped(errMessage: '启动失败')), '启动失败');
    expect(messageOf(const ProxyStopped()), isNull);
    expect(messageOf(ProxyState.started), isNull);
  });
}
