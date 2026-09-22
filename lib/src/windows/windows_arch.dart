import 'dart:ffi';

import 'package:ffi/ffi.dart';
import 'package:flutter/foundation.dart';
import 'package:win32/win32.dart';

/// 真机 CPU 架构原始值解析函数签名。
///
/// 返回 win32 的 `PROCESSOR_ARCHITECTURE_*` 数值（9=AMD64、12=ARM64）。
/// 拆成独立签名纯粹是为了单测注入——不触发真实 win32 调用即可覆盖各分支。
typedef NativeArchResolver = int Function();

/// Windows 真机 CPU 架构探测。
///
/// 用于在双架构资产目录（`assets/windows/amd64|arm64/`）中选定与真机匹配的
/// 一份。关键点：必须取「真机（native）」架构而非当前进程架构——目前 Flutter
/// 只能构建 x64 的 Windows 应用，App 在 ARM64 机器上以 x64 模拟运行，若按
/// 进程架构选择会错选 amd64，导致 sing-box / helper 长期跑在 x64 模拟层。
/// [GetNativeSystemInfo] 在 WOW64 进程里返回的正是真机架构（Vista 起可用，
/// 兼容面优于 IsWow64Process2，且无需进程句柄）。
///
/// 结果进程内缓存一次（架构运行期不会变）；解析异常与未知架构值一律兜底
/// [amd64]——与历史上仅发布 amd64 资产的行为保持一致。
abstract final class WindowsArch {
  /// 资产子目录名，与 GOARCH 及 clash_sing_service build.sh 的产物布局一致。
  static const String amd64 = 'amd64';
  static const String arm64 = 'arm64';

  /// 底层真机架构解析器，默认走 win32 的 GetNativeSystemInfo；仅供单测替换。
  @visibleForTesting
  static NativeArchResolver resolver = _resolveViaWin32;

  static String? _cached;

  /// 当前真机架构目录名（'amd64' / 'arm64'），首次调用探测后进程内缓存。
  static String current() => _cached ??= _detect();

  static String _detect() {
    final int raw;
    try {
      raw = resolver();
    } catch (_) {
      // win32 调用不可用（理论上不会发生）：兜底 amd64，不向调用方抛出。
      return amd64;
    }
    // 只显式识别 ARM64；AMD64 与一切未知值（INTEL / IA64 / UNKNOWN 等）
    // 统一兜底 amd64。Flutter Windows 应用不构建 x86，无需单独处理。
    // （PROCESSOR_ARCHITECTURE 是 implements int 的 extension type，可直接比较。）
    return raw == PROCESSOR_ARCHITECTURE_ARM64 ? arm64 : amd64;
  }

  /// 清空缓存并把解析器还原为默认实现；仅供单测在用例间隔离。
  @visibleForTesting
  static void resetForTest() {
    _cached = null;
    resolver = _resolveViaWin32;
  }

  static int _resolveViaWin32() {
    final Pointer<SYSTEM_INFO> info = calloc<SYSTEM_INFO>();
    try {
      GetNativeSystemInfo(info);
      return info.ref.wProcessorArchitecture;
    } finally {
      calloc.free(info);
    }
  }
}
