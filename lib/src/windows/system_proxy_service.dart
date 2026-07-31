import 'dart:ffi';
import 'dart:io' as io;

import 'package:ffi/ffi.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_sing_box/src/storage/cs_settings_storage.dart';
import 'package:win32/win32.dart';

/// 系统代理「写注册表 + 通知刷新」的实际执行者（抽象出来便于注入测试）。
abstract class SystemProxyApplier {
  Future<void> enable(String proxy);
  Future<void> disable();
}

/// 在 Windows 上设置/清除系统代理的高层服务。
///
/// [enable] 仅在 [SystemProxyApplier] 成功后置 `systemProxyActive=true`；
/// [disable] 置 `systemProxyActive=false`。FFI 异常仅 debugPrint，不抛出
/// （系统代理是 best-effort，不应阻断连接流程）。
class SystemProxyService {
  SystemProxyService({SystemProxyApplier? applier}) : _applier = applier;
  final SystemProxyApplier? _applier;

  Future<void> enable() async {
    final proxy = '127.0.0.1:${CsSettingsStorage().mixedPort}';
    try {
      await (_applier ?? _WindowsSystemProxyApplier()).enable(proxy);
    } catch (e) {
      debugPrint('启用系统代理失败: $e');
    }
    CsSettingsStorage().systemProxyActive = true;
  }

  Future<void> disable() async {
    try {
      await (_applier ?? _WindowsSystemProxyApplier()).disable();
    } catch (e) {
      debugPrint('清除系统代理失败: $e');
    }
    CsSettingsStorage().systemProxyActive = false;
  }
}

/// 默认实现：写 `HKCU\...\Internet Settings` 注册表 + 调 `InternetSetOption` 刷新。
///
/// 仅在 Windows 执行实际操作；其它平台为空操作。注册表/FFI API 对照
/// `package:win32` 6.x 实现（HKEY/PCWSTR/REG_SAM_FLAGS/REG_VALUE_TYPE 均为
/// 强类型包装），FFI 正确性最终由 Task 9 手工验证。
class _WindowsSystemProxyApplier implements SystemProxyApplier {
  static const _subKey =
      'SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Internet Settings';

  @override
  Future<void> enable(String proxy) async {
    if (!io.Platform.isWindows) return;
    using((arena) {
      final handle = arena<Pointer>();
      final subKey = arena.pcwstr(_subKey);
      if (RegOpenKeyEx(HKEY_CURRENT_USER, subKey, 0, KEY_SET_VALUE, handle) ==
          ERROR_SUCCESS) {
        final hKey = HKEY(handle.value);
        try {
          _setDWORD(hKey, arena.pcwstr('ProxyEnable'), 1, arena);
          _setString(hKey, arena.pcwstr('ProxyServer'), proxy, arena);
          _setString(hKey, arena.pcwstr('ProxyOverride'), '<local>', arena);
        } finally {
          RegCloseKey(hKey);
        }
      }
    });
    _notifyChanged();
  }

  @override
  Future<void> disable() async {
    if (!io.Platform.isWindows) return;
    using((arena) {
      final handle = arena<Pointer>();
      final subKey = arena.pcwstr(_subKey);
      if (RegOpenKeyEx(HKEY_CURRENT_USER, subKey, 0, KEY_SET_VALUE, handle) ==
          ERROR_SUCCESS) {
        final hKey = HKEY(handle.value);
        try {
          _setDWORD(hKey, arena.pcwstr('ProxyEnable'), 0, arena);
        } finally {
          RegCloseKey(hKey);
        }
      }
    });
    _notifyChanged();
  }

  void _setDWORD(HKEY hKey, PCWSTR name, int value, Arena arena) {
    final data = arena<Uint32>()..value = value;
    RegSetValueEx(
      hKey,
      name,
      REG_DWORD,
      data.cast<Uint8>(),
      sizeOf<Uint32>(),
    );
  }

  void _setString(HKEY hKey, PCWSTR name, String value, Arena arena) {
    final valuePtr = arena.pcwstr(value);
    // 含末尾 NUL 的字节数（UTF-16，每 code unit 2 字节）。
    final bytes = (value.length + 1) * sizeOf<Uint16>();
    RegSetValueEx(
      hKey,
      name,
      REG_SZ,
      valuePtr.cast<Uint8>(),
      bytes,
    );
  }

  void _notifyChanged() {
    // INTERNET_OPTION_SETTINGS_CHANGED = 39, INTERNET_OPTION_REFRESH = 37
    final wininet = DynamicLibrary.open('wininet.dll');
    final internetSetOption = wininet.lookupFunction<
        Int32 Function(IntPtr, Uint32, Pointer<Void>, Uint32),
        int Function(int, int, Pointer<Void>, int)>('InternetSetOptionW');
    internetSetOption(0, 39, nullptr, 0);
    internetSetOption(0, 37, nullptr, 0);
  }
}
