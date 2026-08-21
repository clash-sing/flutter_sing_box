import 'dart:async';

/// 轮询等待真实网络 IO 完成（10ms 间隔，超时由测试框架的单测默认超时兜底）。
Future<void> until(bool Function() condition) async {
  while (!condition()) {
    await Future.delayed(const Duration(milliseconds: 10));
  }
}
