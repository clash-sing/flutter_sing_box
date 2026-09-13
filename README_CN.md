# flutter_sing_box

[![pub package](https://img.shields.io/pub/v/flutter_sing_box.svg)](https://pub.dev/packages/flutter_sing_box)
[![license](https://img.shields.io/github/license/clash-sing/flutter_sing_box.svg)](https://github.com/clash-sing/flutter_sing_box/blob/master/LICENSE)

[English](README.md) | 中文简体

一个基于 [sing-box](https://github.com/SagerNet/sing-box) 的强大 Flutter 插件，sing-box 是一个通用的代理平台。本插件在 Android 与 Windows 平台内置 sing-box `1.14.0` 内核。

## 🚀 使用此插件的项目

- [**clash-sing**](https://github.com/clash-sing/clash-sing): 一个功能齐全的基于 sing-box 和 Clash 的 GUI 客户端，提供强大直观的用户体验。

## 功能特性

- **VPN / 服务管理**: 在 Android 上通过 VpnService 启停 VPN 服务；在 Windows 上以系统服务方式托管 sing-box，提供 `installService()` / `uninstallService()` / `queryServiceStatus()` 服务生命周期管理接口。
- **双代理模式（Windows）**: Tun 模式（虚拟网卡整机透明代理）与系统代理模式（基于注册表，覆盖遵守系统代理的应用）。
- **高级配置支持**:
    - **原生 sing-box**: 直接支持原生 JSON 配置（需使用新版 DNS 格式——sing-box 1.14.0 已移除旧版 `dns.servers` 格式）。
    - **YAML 转 sing-box**: 自动转换 Clash 风格的 YAML 配置。
    - **Base64 转 sing-box**: 无缝解析 Base64 编码的订阅链接。
- **配置文件管理**: 导入、管理并在本地和远程配置文件（订阅链接）之间切换。
- **Clash API 支持**: 全面支持兼容 Clash 的 API——管理代理与策略组、切换出站节点、测试延迟，并提供基于 WebSocket 的实时日志流（断线自动重连）。
- **实时监控**: 通过流（Stream）实时监控连接状态、流量（上传/下载）和日志；代理生命周期以 `ProxyState` 密封类暴露，其 `ProxyStopped.errMessage` 携带异常停止（启动失败、内核崩溃等）的原因。
- **多协议支持**: 继承 sing-box 对各种协议的支持，包括 Hysteria, TUIC, WireGuard, Shadowsocks 等。

## 平台支持

| 平台 | 支持 | 状态 |
| :--- |:-------:| :--- |
| Android |    ✅    | 生产就绪 |
| Windows |    ✅    | 生产就绪 |
| iOS |    ☐    | 计划中 |
| macOS |   ☐️    | 计划中 |
| Linux |    ☐    | 计划中 |

## 环境要求

- Flutter `>=3.44.0` / Dart SDK `^3.12.0`

## 快速开始

### 初始化

在您的 `main()` 函数中初始化插件：

```dart
import 'package:flutter_sing_box/flutter_sing_box.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FlutterSingBox().init();
  runApp(MyApp());
}
```

### 基础用法

#### 启动 VPN

```dart
try {
  await FlutterSingBox().startVpn();
} catch (e) {
  print("启动 VPN 失败: $e");
}
```

> 自 2.0.0 起，Windows 上的启动失败不再从该 Future 抛出——改为通过 `proxyStateStream` 报告（见下文[监听代理状态](#监听代理状态)）。

#### 停止 VPN

```dart
await FlutterSingBox().stopVpn();
```

#### 监听状态

```dart
FlutterSingBox().connectedStatusStream.listen((status) {
  print("上传: ${status.uplink}, 下载: ${status.downlink}");
});
```

#### 监听代理状态

代理生命周期以 `ProxyState` **密封类**形式暴露——`ProxyStopped` / `ProxyStarting` / `ProxyStarted` / `ProxyStopping`——推荐以穷尽模式匹配消费：

```dart
FlutterSingBox().proxyStateStream.listen((state) {
  switch (state) {
    case ProxyStopped(:final errMessage) when errMessage != null:
      print("异常停止: $errMessage");
    case ProxyStopped():
      print("已停止");
    case ProxyStarting():
      print("启动中...");
    case ProxyStarted():
      print("已启动");
    case ProxyStopping():
      print("停止中...");
  }
});
```

`ProxyStopped.errMessage` 非 null 表示服务异常停止（启动失败、内核崩溃等）——在 Android 与 Windows 上，它都是启动失败的唯一事实来源。

### Windows 平台说明

在 Windows 上，sing-box 以系统服务（`clash_sing_service`）方式运行，而非 VPN 服务：

- 首次使用需调用 `installService()` 安装服务（会触发 UAC 提权确认）；可通过 `queryServiceStatus()` 查询服务状态、`uninstallService()` 卸载服务。
- `startVpn()` / `stopVpn()` 在 Windows 上映射为系统服务的启动 / 停止。
- 自 2.0.0 起，`startVpn()` / `serviceReload()` 失败不再抛出异常；失败原因以 `ProxyStopped(errMessage: ...)` 形式经 `proxyStateStream` 发出。
- 通过 `ProxyMode` 提供两种代理模式：`tun`（默认，虚拟网卡整机透明代理）与 `systemProxy`（基于注册表的系统代理，默认混合端口 `8890`）。

### 迁移到 2.0.0

- **`ProxyState` 改为密封类**——`ProxyStopped` / `ProxyStarting` / `ProxyStarted` / `ProxyStopping`，各为独立的 `final class`。对旧枚举的穷尽 `switch` 必须迁移为类型模式（`case ProxyStopped():`）；旧式 `== ProxyState.started` 比较通过保留的 `static const` 兼容常量继续可用，`name` / `fromName()` 语义不变。
- **Windows：启动失败不再抛出异常。** `startVpn()` / `serviceReload()` 将失败原因以 `ProxyStopped(errMessage: ...)` 形式经 `proxyStateStream` 发出（同时会把状态机从 `starting` 重置），状态流由此成为启动失败的唯一事实来源。

## 示例

查看 [example](https://github.com/clash-sing/flutter_sing_box/tree/master/example) 目录，了解使用 Riverpod 进行状态管理的完整演示应用程序。

## 贡献

欢迎贡献！如果您遇到任何错误或有功能请求，请随时提交 Pull Request 或开启 issue。

## 许可证

本项目采用 [GPL-3.0 许可证](LICENSE) 授权。
