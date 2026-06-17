## 1.1.0
### ⚠️ 重要变更（Breaking Changes）
* 最低环境要求提升：Dart SDK `^3.9.0` → `^3.11.0`，Flutter `>=3.3.0` → `>=3.41.0`
* 修正 Android 插件包名拼写：`com.clashsiing.flutter_sing_box` → `com.clashsing.flutter_sing_box`（如有原生层引用或 consumer-rules 配置，请同步更新）
* 引入 freezed 代码生成框架，新增 `freezed` 与 `freezed_annotation` 依赖

### Features
* 新增 Rule Set（规则集）配置支持，并优化 sing-box 配置模板结构
* 支持自定义订阅请求的 User-Agent，并内置默认 User-Agent 生成工具
* 大幅扩展 sing-box 配置模型字段：Outbound 新增 `username`、`quic` 等出站配置；DNS / Route 模型补充多项字段
* 新增独立 storage 存储模块，引入 `KeyValueStorage` 抽象接口（支持 MMKV / Memory 等实现）
* 新增 `CsSettingsStorage`，用于管理按应用代理设置
* 新增 `ClientLog` 数据模型
* Profile 新增 `outboundsCount` 出站数量统计字段，并支持获取所有 Profile ID
* 新增 `defaultTestUrl` 常量

### Improvements
* 缓存 sing-box 版本号，避免重复获取（性能优化）
* 为模型添加 `explicitToJson` 配置，修复嵌套模型的 JSON 序列化问题
* 重构 VPN 服务启动逻辑，缓存事件流状态
* 升级 JSON 序列化依赖：`json_annotation` → 4.12.0、`json_serializable` → 6.14.0
* 移除 VpnService 的 `android:process=":remote"` 属性

### Fixes
* 修复 VPN 服务重启功能
* 修复 Clash 模式设置与连接管理问题
* 修复 Android 端关闭服务的逻辑
* `appendLogs` 方法增加 `logSink` 空值保护，避免空指针异常

### Refactoring
* 重构存储层：`ProfileManager` 重命名为 `ProfileStorage`，以 `KeyValueStorage` 抽象接口替代 MMKV 直接调用
* `ClientGroupItem` / `ClientGroup` 迁移至 freezed 数据类
* 将 Route 与 RuleSet 部分必填字段改为可选，提升配置灵活性
* 重构 Android 服务实现并更新依赖
* 清理废弃的 custom 模块及调试代码


## 1.0.12
### Features
* 新增应用级代理模式功能（禁用/排除/包含三种模式）
* 支持按应用列表配置代理规则

### Improvements
* 更新 MMKV 依赖至 2.4.0
* 优化应用列表存储方式（使用 JSON 数组格式）
* 更新 Android 构建环境（Kotlin 2.3.20, Gradle 8.14.4）

### Refactoring
* 移除 Inbound 模型中的 sniff 字段
* 重构应用列表数据结构（List 与 Set 转换优化）


## 1.0.11

* Update `sing-box` dependency to `1.12.25` for Android.

## 1.0.10

- **Route Rule**: Added IP CIDR and port filtering support
    - New fields: `ip_cidr`, `source_ip_cidr`, `port`, `port_range`, `source_port`, `source_port_range`
    - Enhanced traffic matching with IP and port-based routing
    - Full JSON serialization support with backward compatibility

## 1.0.9

### Features
* Add DNS rule action configuration and new domain matching fields
* Add `RuleAction` constants for routing rules

### Improvements
* Optimize proxy configuration template and simplify DNS/route rules
* Adjust default log level from `trace` to `info`
* Update User-Agent string for better compatibility

### Refactoring
* Remove remote rule set configuration (geoip-cn, geosite-cn)
* Simplify configuration structure and improve performance
* Make Route fields optional for flexibility

## 1.0.8

* Update `sing-box` dependency to `1.12.24` for Android.

## 1.0.7

* Update `sing-box` dependency to `1.12.23` for Android.
 
## 1.0.6

* Update `sing-box` dependency to `1.12.22` for Android.

## 1.0.5

* Update `sing-box` dependency to `1.12.20` for Android.

## 1.0.4

* Update `libbox` dependency to `1.12.19` for Android.
* Update documentation and project links in README.
* Bump version to 1.0.4.

## 1.0.3

* Add `getSingBoxVersion()` API to retrieve the underlying sing-box core version.
* Optimize memory usage and stability for long-running VPN services.
* Improve error handling during remote profile synchronization.
* Update dependencies to latest versions (dio, mmkv, package_info_plus, etc.).
* Minor bug fixes and performance improvements.

## 1.0.2

* Improve package description and API documentation coverage to increase pub score.
* Add comprehensive README with features, platform support, and basic usage.
* Add Chinese documentation (`README_CN.md`).
* Showcase projects using this plugin (clash_sing_app).

## 1.0.0

* Initial release of the `flutter_sing_box` plugin.
* Support for sing-box as a VPN service.
* Ability to import remote profiles.
* Clash API support for managing proxies and groups.
* UI for managing profiles and viewing connection status.
* Support for various protocols like Hysteria, TUIC, etc.
* Core functionalities like network service, profile management, and custom logging.
* Many bug fixes and performance improvements.
