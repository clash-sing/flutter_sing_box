# sing-box 模型生成器设计（schema → sealed Dart 模型）

- 日期：2026-10-06
- 状态：待审阅
- 工程仓库：flutter_sing_box（生成器与生成物均在本插件内）

## 背景与目标

插件内现有 sing-box 配置模型（`lib/src/data/models/singbox/`）为手写
`@JsonSerializable` 类，存在三个结构性问题：

1. **字段靠人肉对齐**：`Outbound` 把全部协议字段拍平进一个上帝类（200+ 行
   全可空字段），每支持新协议都要对照官方文档逐字段抄写，易漏易错
   （此前 transport 映射缺口即此类产物）。
2. **类型不安全**：任何协议的字段可以塞给任何其他协议（如给 `selector`
   设 `password`），编译器不拦截。
3. **未知字段静默丢失**：`fromJson` 只读取已声明字段，`toJson` 只输出已声明
   字段；用户 sing-box 配置中含模型未声明的协议或字段时，经
   `MergeSingboxConfig` 读改写回后**静默丢弃**。

而官方 JSON Schema（`assets/schemas/singbox_schema.json`，497KB，随内核
版本更新）已经是配置结构的权威单一来源，且已被
`SingBoxSchemaValidator` 用于运行时校验。

**目标**：以该 schema 为单一来源，用生成器产出类型安全的 Dart 模型层，
一次性投入换长期「升版重跑即对齐」的维护收益。

### 已验证的 schema 事实（设计依据）

- Outbound oneOf 共 21 个分支槽位，其中 20 种类型；判别字段一律为
  `properties.type.const`，分支为完整内联对象（`additionalProperties:
  false`）。
- **snell 为嵌套判别**：外层 `type: "snell"` 内部再按 `version`（const 4/6）
  分两支，v4 有 `obfs_mode`/`obfs_host`，v6 有 `mode`。
- **共享块被展开**：`$defs.DialerOptions`（21 字段）定义存在但几乎无
  `$ref` 引用（仅 `control_dialer`/`tunnel_dialer`），出站/入站分支全部
  逐字段内联；`ListenOptions` 连定义都不存在。
- 字段重叠高度规则：Outbound 各分支与 DialerOptions 的重叠呈二值分布
  ——16 个分支 **21/21 全量重叠**，其余槽位零重叠（逻辑出站；snell
  槽位因嵌套结构统计落零，其子分支实际内联全套拨号字段）。
- Inbound oneOf 20 分支，重叠呈 11~12/21 三档（listen+dial 混合展开）。

## 总体架构

```
flutter_sing_box/
├── tool/
│   └── gen_models.dart          # 生成器（纯 Dart，无 Flutter 依赖）
├── assets/schemas/singbox_schema.json     # 单一来源（已有）
└── lib/src/data/models/singbox/gen/       # 生成物（提交进仓库）
```

- 生成器手动执行：`dart run tool/gen_models.dart`，输出 `.dart` 源文件后
  再跑 `dart run build_runner build` 生成 `.g.dart`。
- **生成物提交进仓库**而非构建时生成：CI 无需跑生成器，schema 升级时
  diff 可 review。
- 生成物文件头自动加「本文件由 tool/gen_models.dart 生成，勿手改」注释。

## 生成器设计

### 白名单

白名单 = `OutboundType` 常量表全集，硬编码在生成器配置区：

- 逻辑出站（4）：direct / selector / urltest / block（block 用于低版本
  内核：其规则语法无 `action: reject`，拒绝需经 `outbound: block` 表达，
  对应 `OutboundType.block` 已标注 `@Deprecated`）
- 网络出站（13）：hysteria2 / hysteria / anytls / trojan / vmess / vless /
  shadowsocks / tuic / naive / socks / http / shadowtls / snell
- 入站（2）：tun / mixed
- 顶层结构：SingBox / Dns / Route / RouteRule / DNSServer / DNSRule /
  Experimental / Log 及其经 `$ref` 递归可达的 `$defs`（生成器自动收集，
  无需逐一枚举）

dns 出站、endpoints / services / ntp 等不在白名单内，经透传机制兜底
（见下文）。将来需要时加入白名单重跑生成器即可。

**防漂移**：白名单与 schema 对不齐（类型不存在、判别结构变化）→ 生成器
报错退出；`OutboundType` 常量表与生成子类的对齐由单元测试拦截（见测试
策略）。

### 共享块提取（混合策略）

| 共享块 | 提取来源 | 产物 |
|--------|----------|------|
| 拨号字段 | `$defs.DialerOptions`（现成定义，直接采用其 21 字段） | `mixin DialerFields` |
| 出站 TLS | `$defs.OutboundTLSOptions` | 独立类，组合使用 |
| 入站 TLS | `$defs.InboundTLSOptions` | 独立类，组合使用 |
| multiplex | `$defs` 相应定义 | 独立类 |
| 监听字段 | `$defs` 无定义 → 从白名单入站分支字段交集提取 | `mixin ListenFields` |

各协议类字段 = 分支内联字段 − 已进 mixin/组合的字段，无重复。

### 同类型合并规则

同一 `type` const 出现在多个 oneOf 子分支（如 snell v4/v6）时合并为一个
类：**字段取并集、required 取交集、同名字段类型冲突则报错**。
`SnellOutbound` 为单类，`version` 为 int 必填字段，v4/v6 特有字段各自
可空。

### 类型映射规则

| schema 结构 | Dart 产物 |
|-------------|-----------|
| oneOf 按 `type` const 判别 | sealed 子类；`fromJson` 读 `type` 后 switch 分发 |
| `required` 属性 | 构造函数必填参数 |
| 可选属性 | 可空字段 |
| `$defs.Duration` | `String`（Go 时长字符串原样保留） |
| anyOf 标量二义（network / routing_mark / udp_over_tcp 等） | `Object?` |
| snake_case | lowerCamelCase + `@JsonKey(name:)` |
| 可变性 | 普通可变类 + `@JsonSerializable(explicitToJson: true)`（非 freezed） |
| 子类 `type` 值 | 子类内 `static const typeName` + 实例 `String get type` 返回之 |

## 生成物结构

```
gen/
├── sing_box.dart       # 顶层配置：已建模属性 + 未知属性原样透传
├── shared/
│   ├── dialer_fields.dart
│   ├── listen_fields.dart
│   ├── tls.dart
│   └── multiplex.dart
├── outbound/
│   ├── outbound.dart   # sealed Outbound + fromJson 判别工厂 + UnknownOutbound
│   ├── direct_outbound.dart
│   ├── selector_outbound.dart
│   ├── urltest_outbound.dart
│   ├── block_outbound.dart
│   └── ...（13 个网络协议，snell 单类合并 v4/v6）
├── inbound/
│   ├── inbound.dart    # sealed Inbound + 工厂 + UnknownInbound
│   ├── tun_inbound.dart
│   └── mixed_inbound.dart
├── dns.dart / route.dart / experimental.dart / log.dart
└── index.dart          # 汇总导出
```

### 未知类型与未知字段的保真透传（关键设计）

`MergeSingboxConfig` 会解析用户自己的 sing-box 配置文件，其中可能含 App
不支持的协议：

- **未知 `type`**（如 wireguard、tor）→ `UnknownOutbound`（持有原始
  `Map<String, dynamic>`），`toJson` 原样回写，不丢字段不报错。入站同理
  （`UnknownInbound`）。
- **顶层未建模段**（ntp / endpoints / services / certificate…）→
  `SingBox` 持有 `unknownSections` map，读入时收存、输出时原样合并。
- 已建模类型的未知**字段**仍会丢弃（json_serializable 默认行为）——该类
  字段本就被 schema 严格模式禁止，可接受。

此设计同时修复现状缺陷 3（未知内容静默丢失）。

### 消费侧兼容性

sealed 基类暴露 `String get tag` 与 `String get type`，现有
`outbound.type == OutboundType.urltest` 比较模式与 `element.tag` 读取
继续可用；模式匹配处可用 `whereType<UrltestOutbound>()` 收紧。

## 迁移策略（两阶段交付，各自独立可 review）

### 阶段一：生成器 + 生成物落地

纯增量：新增 `tool/gen_models.dart` 与 `gen/` 目录，生成物带单测。不动
任何现有代码。

### 阶段二：切换

1. 插件内生产侧重写：`clash_provider` / `base64_provider` /
   `sing_box_config_provider` 中约 20 处 `Outbound(...)` 构造改为子类
   构造（机械改写）。
2. App 侧适配：`MergeSingboxConfig`（tag/type 读取不变，
   `outbound.url = x` 改为对 `UrltestOutbound` 的可变赋值）及
   `home_proxies_vm` 等少量消费点。
3. 删除旧手写模型文件（`models/singbox/` 下被 gen/ 取代者）。
4. 联调验证：启用 `clash_sing_app` 的 `dependency_overrides` 指向本地
   插件源码；**验证完成后必须注释还原并重新 `flutter pub get`**（CI 不拉
   上级目录源码，启用态构建必然失败）。

## 测试策略

1. **生成器单测**：迷你 fixture schema → 断言输出文本（快照测试）；含
   嵌套 oneOf 合并、白名单外类型忽略、类型冲突报错等边界用例。
2. **生成物单测**：
   - `fromJson`/`toJson` round-trip 保真（含 UnknownOutbound 透传）。
   - **schema 反向校验闭环**：生成物 `toJson()` →
     `SingBoxSchemaValidator.validateSync` 零错误（用官方 schema 反向
     验证生成器，闭环自证）。
3. **白名单对齐测试**：断言 `OutboundType` 常量全集 == 生成子类
   typeName 注册表全集——任一侧手动增删，测试立即拦截并提示重跑生成器。
4. **迁移回归**：现有 `test/` 全绿；提交前 GitNexus
   `detect_changes(scope: compare, base_ref: main)` 复核影响面。

## schema 升级流程

sing-box 内核升版 → 用官方新版 `singbox_schema.json` 覆盖
`assets/schemas/` → `dart run tool/gen_models.dart` → review 生成物
diff → `dart run build_runner build` → 全量测试 → 提交。

## 版本与发布

- 阶段二为公开 API 破坏性变更（`Outbound` 由可实例化的拍平类改为
  sealed 层级），按语义化版本插件应升 **3.0.0**（当前 2.0.4）。
- App 侧 `pubspec.yaml` 依赖相应提升；发布顺序沿用既有流程（插件发版 →
  App 升级依赖）。

## 非目标（明确不做）

- **全量生成** 97 个 defs：白名单外类型经透传兜底，不为死协议生成类。
- **freezed / 不可变模型**：merge 流程依赖可变赋值，不可变化收益边际。
- **endpoints / services / ntp 深度建模**：顶层透传已保真，需要时再入
  白名单。
- **生成 `OutboundType` 常量表本身**：常量表保留手写（带文档注释），
  由对齐测试防漂移。
- **修改 `SingBoxSchemaValidator`**：校验器保持现状，与生成物形成
  「写出合法配置 + 运行时兜底」双保险。
