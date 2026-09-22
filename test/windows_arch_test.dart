import 'dart:io' as io;

import 'package:flutter_sing_box/src/windows/windows_arch.dart';
import 'package:flutter_test/flutter_test.dart';

/// WindowsArch 单测：通过注入 [WindowsArch.resolver] 覆盖各架构分支，
/// 不触碰真实 win32 调用。注入用 PROCESSOR_ARCHITECTURE 原始数值
/// （9=AMD64、12=ARM64、0=INTEL、0xFFFF=UNKNOWN）。
void main() {
  setUp(WindowsArch.resetForTest);

  group('WindowsArch.current', () {
    test('ARM64 真机 → arm64', () {
      WindowsArch.resolver = () => 12;
      expect(WindowsArch.current(), WindowsArch.arm64);
    });

    test('AMD64 真机 → amd64', () {
      WindowsArch.resolver = () => 9;
      expect(WindowsArch.current(), WindowsArch.amd64);
    });

    test('未知架构值（如 INTEL / UNKNOWN）→ 兜底 amd64', () {
      WindowsArch.resolver = () => 0;
      expect(WindowsArch.current(), WindowsArch.amd64);

      WindowsArch.resetForTest();
      WindowsArch.resolver = () => 0xFFFF;
      expect(WindowsArch.current(), WindowsArch.amd64);
    });

    test('解析器抛异常 → 兜底 amd64，不向调用方抛出', () {
      WindowsArch.resolver = () => throw StateError('win32 不可用');
      expect(WindowsArch.current(), WindowsArch.amd64);
    });

    test('结果进程内缓存：resolver 只被调用一次', () {
      int calls = 0;
      WindowsArch.resolver = () {
        calls++;
        return 12;
      };
      WindowsArch.current();
      WindowsArch.current();
      expect(calls, 1);
    });

    test('缓存后替换 resolver 不影响已缓存的结果', () {
      WindowsArch.resolver = () => 12;
      expect(WindowsArch.current(), WindowsArch.arm64);

      WindowsArch.resolver = () => 9;
      expect(WindowsArch.current(), WindowsArch.arm64);
    });

    test('默认 resolver 走真实 GetNativeSystemInfo，返回合法架构', () {
      // 不注入 resolver，直接命中真实 win32 调用（仅 Windows 平台可跑；
      // 本开发/CI 机为 x64 应得 amd64，ARM64 机器上得 arm64 同样合法）。
      expect(
        WindowsArch.current(),
        anyOf(WindowsArch.amd64, WindowsArch.arm64),
        skip: !io.Platform.isWindows ? '真实 win32 调用仅 Windows 可执行' : false,
      );
    }, skip: !io.Platform.isWindows ? '真实 win32 调用仅 Windows 可执行' : false);
  });
}
