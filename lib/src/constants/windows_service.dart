/// Windows 端 `clash_sing_service` 系统服务的可观测状态。
///
/// 取值与 `clash_sing_helper.exe status` 的 stdout 一一对应；
/// [unsupported] 表示当前平台非 Windows，不存在该服务概念。
enum WindowsServiceStatus {
  /// 服务未安装
  notInstalled,
  /// 服务已安装但未运行
  stopped,
  /// 服务运行中
  running,
  /// helper 返回 unknown，或 stdout 未识别
  unknown,
  /// 调用异常 / 超时 / helper.exe 缺失 / helper.json 生成失败
  error,
  /// 当前平台不是 Windows
  unsupported;

  /// 将 `clash_sing_helper.exe status` 的 stdout（调用方负责 trim）映射为枚举。
  /// 未识别值统一归为 [unknown]。
  static WindowsServiceStatus fromHelperOutput(String raw) {
    switch (raw) {
      case 'running':
        return WindowsServiceStatus.running;
      case 'stopped':
        return WindowsServiceStatus.stopped;
      case 'notInstalled':
        return WindowsServiceStatus.notInstalled;
      case 'unknown':
        return WindowsServiceStatus.unknown;
      case 'error':
        return WindowsServiceStatus.error;
      default:
        return WindowsServiceStatus.unknown;
    }
  }
}

/// Windows 系统服务名（与 `clash_sing_helper.exe` 注册的服务一致）。
const windowsServiceName = 'clash_sing_service';

/// Windows 系统服务展示名。
const windowsServiceDisplayName = 'Clash Sing Service';

/// Windows 系统服务描述。
const windowsServiceDescription = 'Clash Sing Service helps to launch Clash Sing core';
