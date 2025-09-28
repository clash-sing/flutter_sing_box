# Flutter Sing Box 项目规则

## 1. 项目概述
Flutter Sing Box 是一个 Flutter 插件项目，用于在 Flutter 应用中集成 sing-box 功能。该插件提供了跨平台的网络代理解决方案，目前主要实现了 Android 端的 VPN 服务功能。

## 2. 目录结构
项目遵循标准的 Flutter 插件架构，主要包含以下目录和文件：

```
├── android/                # Android 平台实现代码
├── ios/                    # iOS 平台实现代码
├── lib/                    # Dart API 实现
│   ├── flutter_sing_box.dart                 # 主入口文件
│   ├── flutter_sing_box_method_channel.dart  # MethodChannel 实现
│   └── flutter_sing_box_platform_interface.dart # 平台接口定义
├── example/                # 示例应用
├── test/                   # 测试代码
├── pubspec.yaml            # 项目配置和依赖声明
└── README.md               # 项目说明文档
```

## 3. 技术栈和依赖

### 核心技术栈
- **Flutter**: 跨平台 UI 框架
- **Dart**: 编程语言
- **Kotlin**: Android 平台实现语言
- **Swift**: iOS 平台实现语言

### 主要依赖
- `flutter` (SDK)
- `plugin_platform_interface` (^2.0.2)

## 4. 开发流程

### 4.1 环境准备
- 安装 Flutter SDK (>=3.3.0)
- 安装 Dart SDK (^3.9.2)
- 配置 Android Studio 和 Xcode 开发环境

### 4.2 项目初始化
1. 克隆仓库：`git clone https://github.com/clash-sing/flutter_sing_box.git`
2. 安装依赖：`flutter pub get`
3. 运行示例应用：`flutter run`

### 4.3 代码开发

#### 4.3.1 Dart API 开发
1. 在 `lib/flutter_sing_box_platform_interface.dart` 中定义平台接口
2. 在 `lib/flutter_sing_box_method_channel.dart` 中实现 MethodChannel 通信
3. 在 `lib/flutter_sing_box.dart` 中提供用户友好的 API

#### 4.3.2 平台特定实现
- **Android**: 在 `android/src/main/kotlin/com/clashsiing/flutter_sing_box/` 目录下实现
- **iOS**: 在 `ios/Classes/` 目录下实现

#### 4.3.3 示例应用开发
在 `example/lib/` 目录下开发示例应用，展示插件的使用方法

## 5. 代码规范

### 5.1 Dart 代码规范
- 遵循官方 Flutter 代码风格指南
- 使用 `flutter_lints` 进行代码检查
- 为所有公共 API 添加文档注释
- 使用类型注解提高代码可读性

### 5.2 命名规范
- 类名：使用大驼峰命名法（PascalCase）
- 方法和变量：使用小驼峰命名法（camelCase）
- 常量：使用全大写加下划线（UPPER_CASE_WITH_UNDERSCORES）
- 文件：使用小写加下划线（lowercase_with_underscores）

## 6. 版本控制
- 使用 Git 进行版本控制
- 遵循语义化版本号规范 (semver)
- 提交消息应清晰描述更改内容

## 7. 构建和发布流程

### 7.1 本地构建
```bash
# 构建 Android APK
flutter build apk

# 构建 iOS IPA
flutter build ios
```

### 7.2 发布到 pub.dev
1. 更新版本号和 changelog
2. 运行 `flutter pub publish --dry-run` 检查发布配置
3. 运行 `flutter pub publish` 发布插件

## 8. 测试指南

### 8.1 单元测试
- 在 `test/` 目录下编写单元测试
- 运行测试：`flutter test`

### 8.2 集成测试
- 在 `example/integration_test/` 目录下编写集成测试
- 运行测试：`flutter drive --driver=test_driver/integration_test.dart --target=integration_test/plugin_integration_test.dart`

## 9. 功能实现指南

### 9.1 Android VPN 服务实现
Android 平台提供了 VPN 服务的启动和停止功能，主要通过 `ClashSingVpnService` 类实现。使用方法如下：

1. 在 AndroidManifest.xml 中注册 VPN 服务
2. 通过 MethodChannel 调用 `startVpn` 和 `stopVpn` 方法控制 VPN 服务

### 9.2 跨平台方法调用
目前支持的方法调用：
- `getPlatformVersion`: 获取当前平台版本
- `startVpn`: 启动 VPN 服务（仅 Android）
- `stopVpn`: 停止 VPN 服务（仅 Android）

## 10. 注意事项和最佳实践

### 10.1 权限处理
- Android 平台需要 VPN 相关权限：`android.permission.BIND_VPN_SERVICE`
- iOS 平台可能需要网络扩展相关权限

### 10.2 性能优化
- 避免在主线程执行耗时操作
- 使用异步方法处理平台通信

### 10.3 错误处理
- 实现完整的错误处理和异常捕获机制
- 向 Flutter 端传递有意义的错误信息

### 10.4 代码维护
- 定期更新依赖库版本
- 保持平台实现的一致性
- 为新功能添加相应的测试用例

## 11. 项目状态和路线图

### 当前状态
- 基础框架已搭建完成
- Android 端实现了 VPN 服务的基本功能
- iOS 端仅实现了基础的平台版本获取功能

### 未来计划
1. 完善 iOS 平台的 sing-box 功能实现
2. 增加更多的 sing-box 配置选项
3. 提供更丰富的 API 接口
4. 优化网络性能和稳定性

---
更新日期：2024-06-10