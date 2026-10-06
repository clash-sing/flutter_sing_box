# sing-box 模型生成器实施计划

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 以官方 JSON Schema 为单一来源，用纯 Dart 生成器产出 sealed 层级的 sing-box 配置模型，两阶段落地（生成器+生成物 → 切换消费侧并发版 3.0.0）。

**Architecture:** 生成器（`tool/`，纯 Dart）解析 schema 为中间表示（IR），再输出带 `@JsonSerializable` 注解的 Dart 源文件到 `lib/src/data/models/singbox/gen/`（提交进仓库）；oneOf 按 type const 判别的生成 sealed 子类 + Unknown 透传兜底，无 const 判别的（Rule 系列）字段并集拍平为单类。阶段二把插件与 App 的生产/消费侧从旧手写拍平类切换到新模型，删除旧模型，插件升 3.0.0。

**Tech Stack:** Dart（tool/ 脚本）、json_serializable + build_runner（生成物注解）、flutter_test（测试）、GitNexus（回归对比）。

**Spec:** `docs/superpowers/specs/2026-10-06-singbox-model-generator-design.md`（本计划由该 spec 推导，执行者须同时阅读两者）

## Global Constraints

- 代码注释与 Git commit 消息一律**简体中文**。
- `tool/` 下生成器代码**零 Flutter import**（只许 `dart:` 与 `package:json` 之外纯 Dart——实际只需 `dart:io`/`dart:convert`）。
- 生成物文件头带「由 tool/gen_models.dart 生成，勿手改」注释；生成物提交进仓库。
- 不修改 `SingBoxSchemaValidator` 与 `assets/schemas/singbox_schema.json`。
- 白名单 = `OutboundType`（17 项）/ `InboundType`（tun、mixed）常量表当前全集；表外类型走 Unknown 透传。
- 阶段二联调用的 `dependency_overrides` 在**验证完成后必须注释还原**并重新 `flutter pub get`（CI 不拉上级目录源码）。
- 插件版本阶段二末升 **3.0.0**（当前 2.0.4）。
- 所有 `git` 操作在 `d:\projs_dg\flutter_sing_box` 或 `d:\projs_dg\clash_sing_app` 仓库内执行（workspace 根目录不是 git 仓库）；日常开发分支为 `develop`。

## Review Focus

1. **用户配置含白名单外协议（wireguard/tor）**：fromJson → toJson 必须原样保真，不崩不丢字段——round-trip 测试（Task 6）用含 wireguard 节点的样例 pin 住。
2. **畸形输入缺 required 字段**（如 outbound 无 tag）：fromJson 应抛出清晰的类型错误而非静默产出坏对象——Task 6 加「缺 tag 抛 TypeError」断言（与现状拍平类行为等价：fail fast）。
3. **snell v4/v6 同类合并正确性**：合并类的 obfs_mode（v4）与 mode（v6）并存且互不覆盖，version 必填——Task 2 迷你 fixture 与 Task 6 round-trip 双重 pin。
4. **手改 OutboundType 后对齐测试失败并给出可读指引**（提示重跑生成器而非裸断言失败）——Task 6 对齐测试断言错误消息内容。
5. **schema 升版后结构漂移**：白名单类型在 schema 中消失/判别结构变化时生成器报错退出码非 0 且不写任何文件——Task 4 golden 测试含「白名单类型缺失 → 退出码 2」用例。

---

# 阶段一：生成器 + 生成物（纯增量，不动现有代码）

### Task 1: 生成器入口骨架 + 命名工具

**Files:**
- Create: `tool/gen_models.dart`
- Create: `tool/src/names.dart`
- Test: `test/tool/names_test.dart`

**Interfaces:**
- Produces: `String lowerCamel(String snake)`、`String pascalCase(String snake)`、`String classNameForOutbound(String type)`（`hysteria2` → `Hysteria2Outbound`）、`String classNameForInbound(String type)`、`String fileNameFor(String className)`（`Hysteria2Outbound` → `hysteria2_outbound.dart`）、`const outboundWhitelist`（17 项）、`const inboundWhitelist`（2 项）。

- [ ] **Step 1: 写失败测试**

```dart
// test/tool/names_test.dart
import 'package:flutter_test/flutter_test.dart';
import '../../tool/src/names.dart';

void main() {
  group('命名转换', () {
    test('snake_case 转 lowerCamelCase', () {
      expect(lowerCamel('server_port'), 'serverPort');
      expect(lowerCamel('tcp_fast_open'), 'tcpFastOpen');
      expect(lowerCamel('tag'), 'tag');
    });

    test('类型串转出站类名', () {
      expect(classNameForOutbound('hysteria2'), 'Hysteria2Outbound');
      expect(classNameForOutbound('urltest'), 'UrltestOutbound');
      expect(classNameForOutbound('anytls'), 'AnytlsOutbound');
      expect(classNameForOutbound('shadowtls'), 'ShadowtlsOutbound');
      expect(classNameForOutbound('snell'), 'SnellOutbound');
    });

    test('类型串转入站类名', () {
      expect(classNameForInbound('tun'), 'TunInbound');
      expect(classNameForInbound('mixed'), 'MixedInbound');
    });

    test('类名转文件名', () {
      expect(fileNameFor('Hysteria2Outbound'), 'hysteria2_outbound.dart');
      expect(fileNameFor('OutboundTLSOptions'), 'outbound_tls_options.dart');
    });

    test('白名单与常量表一致', () {
      // OutboundType 常量表全集（17 项，见 Global Constraints）
      expect(outboundWhitelist, containsAll(<String>[
        'direct', 'selector', 'urltest', 'block',
        'hysteria2', 'hysteria', 'anytls', 'trojan', 'vmess', 'vless',
        'shadowsocks', 'tuic', 'naive', 'socks', 'http', 'shadowtls', 'snell',
      ]));
      expect(outboundWhitelist.length, 17);
      expect(inboundWhitelist, ['tun', 'mixed']);
    });
  });
}
```

- [ ] **Step 2: 跑测试确认失败**

Run: `flutter test test/tool/names_test.dart`
Expected: FAIL（`tool/src/names.dart` 不存在，import 报错）

- [ ] **Step 3: 实现命名工具与白名单**

```dart
// tool/src/names.dart —— 纯 Dart，禁止 Flutter import

/// snake_case 转 lowerCamelCase：server_port -> serverPort
String lowerCamel(String snake) => snake
    .split('_')
    .mapIndexed((i, part) => i == 0 ? part : '${part[0].toUpperCase()}${part.substring(1)}')
    .join();

/// 类型串转 Pascal：hysteria2 -> Hysteria2（数字段保持原样）
String pascalCase(String s) => s
    .split('_')
    .map((part) => part.isEmpty ? part : '${part[0].toUpperCase()}${part.substring(1)}')
    .join();

String classNameForOutbound(String type) => '${pascalCase(type)}Outbound';
String classNameForInbound(String type) => '${pascalCase(type)}Inbound';

/// 类名转 snake 文件名：Hysteria2Outbound -> hysteria2_outbound.dart
/// 规则：大写字母前插入下划线（连续大写如 TLSOptions 视作一个词组）
String fileNameFor(String className) {
  final snake = className
      .replaceAllMapped(RegExp(r'([a-z0-9])([A-Z])'), (m) => '${m[1]}_${m[2]}')
      .replaceAllMapped(RegExp(r'([A-Z]+)([A-Z][a-z])'), (m) => '${m[1]}_${m[2]}')
      .toLowerCase();
  return '$snake.dart';
}

/// 白名单：见 spec「白名单」节，与 OutboundType/InboundType 常量表对齐
const outboundWhitelist = <String>{
  'direct', 'selector', 'urltest', 'block',
  'hysteria2', 'hysteria', 'anytls', 'trojan', 'vmess', 'vless',
  'shadowsocks', 'tuic', 'naive', 'socks', 'http', 'shadowtls', 'snell',
};

const inboundWhitelist = <String>{'tun', 'mixed'};
```

注意 `mapIndexed` 在纯 Dart 里不可用（那是 collection 包扩展）——手写 `.asMap().entries.map(...)` 或 for 循环。

- [ ] **Step 4: 跑测试确认通过**

Run: `flutter test test/tool/names_test.dart`
Expected: PASS（5 个用例全绿）

- [ ] **Step 5: 建入口骨架**

```dart
// tool/gen_models.dart —— 生成器入口：读 schema -> 解析 -> 输出
// 用法：dart run tool/gen_models.dart
import 'dart:convert';
import 'dart:io';

Future<void> main(List<String> args) async {
  final schemaPath = args.isNotEmpty
      ? args[0]
      : 'assets/schemas/singbox_schema.json';
  final raw = await File(schemaPath).readAsString();
  final schema = jsonDecode(raw) as Map<String, dynamic>;
  stdout.writeln('已加载 schema: $schemaPath');
  // TODO(Task2): 解析为 IR；TODO(Task3): 输出生成物
  exitCode = 0;
}
```

- [ ] **Step 6: 验证入口可运行**

Run: `dart run tool/gen_models.dart`
Expected: 输出「已加载 schema: assets/schemas/singbox_schema.json」，退出码 0

- [ ] **Step 7: Commit**

```bash
git add tool/gen_models.dart tool/src/names.dart test/tool/names_test.dart
git commit -m "feat: 生成器骨架与命名工具（schema 驱动模型生成第一步）"
```

---

### Task 2: schema 解析为 IR（判别收集 / 嵌套展开 / 合并 / 拍平 / 类型映射）

**Files:**
- Create: `tool/src/schema_ir.dart`
- Create: `test/tool/fixtures/mini_schema.json`
- Test: `test/tool/schema_ir_test.dart`

**Interfaces:**
- Consumes: Task 1 的 `classNameForOutbound` / `classNameForInbound` / `outboundWhitelist` / `inboundWhitelist`。
- Produces:

```dart
class FieldSpec {
  final String jsonName;   // schema 原名（snake_case）
  final String dartName;   // lowerCamelCase
  final String dartType;   // 'String' / 'int' / 'Object?' / 'Tls?' / 'List<String>?' 等
  final bool required;
}

class ClassSpec {
  final String className;      // 'Hysteria2Outbound' / 'Rule' / 'OutboundTLSOptions'
  final String? typeName;      // 判别值（'hysteria2'），普通类为 null
  final List<FieldSpec> ownFields;  // 本类字段（不含 mixin 字段）
  final List<String> mixins;   // 混入的共享块名（'DialerFields' / 'ListenFields'）
  final String kind;           // 'outbound' / 'inbound' / 'plain'
}

class Ir {
  final List<ClassSpec> classes;
  final Map<String, List<FieldSpec>> mixins;  // mixin 名 -> 字段集
}

/// 解析入口（后续 Task 3 的输入）
Ir buildIr(Map<String, dynamic> schema, {required Set<String> outboundWhitelist, required Set<String> inboundWhitelist});
```

**解析规则（全部必须实现并测试）：**

1. **顶层入口**：`properties.dns → $defs.DNS`、`route → $defs.RouteOptions`、`experimental/log/inbounds/outbounds`；顶层属性中未建模的（ntp/certificate/…）不进 IR（由 Task 3 的 SingBox 透传处理，IR 无需表示）。
2. **`$ref` 递归可达收集**：从顶层入口出发沿 `$ref`（`#/$defs/X`）收集所有可达 def，逐个生成 `ClassSpec`（kind: plain）。def 内字段含 `$ref` 的递归处理，已收集的不重复。
3. **判别分支收集**：`Outbound`/`Inbound`/`DNSServer` 的 oneOf 分支按 `properties.type.const` 分组。白名单外的 outbound/inbound 类型跳过（进 Unknown 兜底名单，IR 不生成类）。
4. **嵌套 oneOf 展开**：分支自身无 `properties` 但含 `oneOf`/`anyOf` 数组（snell 形状）→ 递归展开子分支，按子分支的 type const 分组。
5. **同判别值合并**：同 type const 多分支 → 一个类，`ownFields` 取并集、`required` 取交集、同 jsonName 字段 dartType 不同则抛 `SchemaConflictException`。
6. **无判别 oneOf/anyOf 拍平**：组合子分支均无 type const（`Rule`/`DNSRule` 形状，分支为 allOf 包裹）→ 拍平为单类：所有分支（含其 allOf 子块的 properties）字段并集，required 取交集（`Rule` 的实际结果近似现有手写 `RouteRule` 的宽松形态）。
7. **const 值字段**：字段 schema 为 `{"const": <标量>}`（如 snell 的 `version: const 4`）→ 生成普通字段，类型取 const 值的 Dart 类型，可空性按合并后 required。
8. **类型映射表**（`_mapType(Map node)`）：

| schema 形状 | Dart 类型 |
|---|---|
| `{"type":"string"}`（含 enum） | `String` |
| `{"type":"integer"}` | `int` |
| `{"type":"number"}` | `double` |
| `{"type":"boolean"}` | `bool` |
| `{"type":"array","items":X}` | `List<T>`（T 为 X 的映射，X 是 `$ref` 到 object 时为类名） |
| `$ref #/$defs/Duration` | `String` |
| `$ref` 到「标量或标量数组」形状的 def（IPAddress 等 oneOf[string, array]） | `Object` |
| `$ref` 到 object def | 对应 className |
| `anyOf`/`oneOf`（字段级二义，如 network、routing_mark、udp_over_tcp） | `Object` |
| 未知形状 | 抛 `SchemaConflictException` |

   可空性：`required` 含该字段 → 非空；否则类型加 `?`。
9. **共享块提取**：
   - `DialerFields` = `$defs.DialerOptions.properties` 全字段（按映射表转，**一律可空**——mixin 字段不能进构造函数）。
   - `ListenFields` = 白名单入站分支（tun/mixed）properties 键交集 − {tag, type}，同样一律可空。
   - outbound/inbound 判别类的字段 = 分支字段 − mixin 已含字段 − type；`tag` 留在本类（required、非空）。
10. **tag/type 在判别类中的表达**：`type` 不进字段（Task 3 由 `typeName` + getter 表达）；`tag` 进 ownFields（required）。

- [ ] **Step 1: 写迷你 fixture schema**

```json
// test/tool/fixtures/mini_schema.json —— 覆盖全部解析规则的缩微样本
{
  "$id": "https://example.com/mini.json",
  "type": "object",
  "properties": {
    "log": { "$ref": "#/$defs/LogOptions" },
    "outbounds": { "type": "array", "items": { "$ref": "#/$defs/Outbound" } },
    "ntp": { "type": "object" }
  },
  "$defs": {
    "LogOptions": {
      "type": "object",
      "properties": {
        "disabled": { "type": "boolean" },
        "level": { "type": "string", "enum": ["trace","debug","info"] }
      },
      "required": ["level"]
    },
    "Duration": { "oneOf": [{ "type": "string" }, { "type": "integer" }] },
    "DialerOptions": {
      "type": "object",
      "properties": {
        "detour": { "type": "string" },
        "routing_mark": { "anyOf": [{ "type": "integer" }, { "type": "string" }] },
        "connect_timeout": { "$ref": "#/$defs/Duration" }
      }
    },
    "OutboundTLSOptions": {
      "type": "object",
      "properties": {
        "enabled": { "type": "boolean" },
        "server_name": { "type": "string" }
      },
      "required": ["enabled"]
    },
    "Outbound": {
      "oneOf": [
        {
          "type": "object",
          "properties": {
            "type": { "const": "hysteria2" },
            "tag": { "type": "string" },
            "server": { "type": "string" },
            "server_port": { "type": "integer" },
            "tls": { "$ref": "#/$defs/OutboundTLSOptions" },
            "detour": { "type": "string" },
            "connect_timeout": { "$ref": "#/$defs/Duration" }
          },
          "required": ["type", "tag", "server", "server_port"]
        },
        {
          "oneOf": [
            {
              "type": "object",
              "properties": {
                "type": { "const": "snell" },
                "tag": { "type": "string" },
                "version": { "const": 4 },
                "psk": { "type": "string" },
                "obfs_mode": { "type": "string" }
              },
              "required": ["type", "version"]
            },
            {
              "type": "object",
              "properties": {
                "type": { "const": "snell" },
                "tag": { "type": "string" },
                "version": { "const": 6 },
                "psk": { "type": "string" },
                "mode": { "type": "string" }
              },
              "required": ["type", "version"]
            }
          ]
        },
        {
          "type": "object",
          "properties": {
            "type": { "const": "wireguard" },
            "tag": { "type": "string" },
            "local_address": { "type": "array", "items": { "type": "string" } }
          },
          "required": ["type"]
        },
        {
          "type": "object",
          "properties": {
            "type": { "const": "urltest" },
            "tag": { "type": "string" },
            "outbounds": { "type": "array", "items": { "type": "string" } },
            "url": { "type": "string" }
          },
          "required": ["type", "tag"]
        }
      ]
    }
  }
}
```

（fixture 中白名单设为 `{'hysteria2','snell','urltest'}`、入站白名单为空集传入测试——`buildIr` 的白名单是参数，测试自定义。）

- [ ] **Step 2: 写失败测试**

```dart
// test/tool/schema_ir_test.dart
import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import '../../tool/src/schema_ir.dart';

Ir buildFixtureIr() {
  final raw = File('test/tool/fixtures/mini_schema.json').readAsStringSync();
  return buildIr(
    jsonDecode(raw) as Map<String, dynamic>,
    outboundWhitelist: {'hysteria2', 'snell', 'urltest'},
    inboundWhitelist: {},
  );
}

void main() {
  test('判别类生成：白名单内类型各成一个 ClassSpec', () {
    final ir = buildFixtureIr();
    final names = ir.classes.map((c) => c.className).toList();
    expect(names, containsAll(['Hysteria2Outbound', 'SnellOutbound', 'UrltestOutbound']));
    expect(names, isNot(contains('WireguardOutbound'))); // 白名单外跳过
  });

  test('嵌套 oneOf 展开 + 同判别合并：snell 单类，字段并集 required 交集', () {
    final ir = buildFixtureIr();
    final snell = ir.classes.singleWhere((c) => c.className == 'SnellOutbound');
    final fieldNames = snell.ownFields.map((f) => f.jsonName).toList();
    expect(fieldNames, containsAll(['tag', 'version', 'psk', 'obfs_mode', 'mode']));
    final version = snell.ownFields.singleWhere((f) => f.jsonName == 'version');
    expect(version.dartType, 'int');          // const 标量 -> int
    expect(version.required, isTrue);         // 两分支 required 交集
    final obfs = snell.ownFields.singleWhere((f) => f.jsonName == 'obfs_mode');
    expect(obfs.required, isFalse);           // 并集后非公共字段
  });

  test('$ref 递归可达：OutboundTLSOptions 被收集', () {
    final ir = buildFixtureIr();
    final tls = ir.classes.singleWhere((c) => c.className == 'OutboundTLSOptions');
    expect(tls.kind, 'plain');
    expect(tls.ownFields.map((f) => f.dartName), containsAll(['enabled', 'serverName']));
  });

  test('Duration 映射为 String，anyOf 二义映射为 Object', () {
    final ir = buildFixtureIr();
    final h2 = ir.classes.singleWhere((c) => c.className == 'Hysteria2Outbound');
    final timeout = h2.ownFields.singleWhere((f) => f.jsonName == 'connect_timeout');
    expect(timeout.dartType, 'String?');
    final dialer = ir.mixins['DialerFields']!;
    final mark = dialer.singleWhere((f) => f.jsonName == 'routing_mark');
    expect(mark.dartType, 'Object?');         // mixin 字段一律可空
  });

  test('共享块提取：DialerFields 吸收分支内重复拨号字段', () {
    final ir = buildFixtureIr();
    final h2 = ir.classes.singleWhere((c) => c.className == 'Hysteria2Outbound');
    expect(h2.mixins, contains('DialerFields'));
    // detour/connect_timeout 已进 mixin，本类字段不再含
    expect(h2.ownFields.map((f) => f.jsonName), isNot(contains('detour')));
  });

  test('required 决定可空性', () {
    final ir = buildFixtureIr();
    final h2 = ir.classes.singleWhere((c) => c.className == 'Hysteria2Outbound');
    expect(h2.ownFields.singleWhere((f) => f.jsonName == 'server').dartType, 'String');
    expect(h2.ownFields.singleWhere((f) => f.jsonName == 'tls').dartType, 'OutboundTLSOptions?');
  });

  test('白名单类型在 schema 中缺失时报错', () {
    final raw = File('test/tool/fixtures/mini_schema.json').readAsStringSync();
    expect(
      () => buildIr(jsonDecode(raw) as Map<String, dynamic>,
          outboundWhitelist: {'hysteria2', 'trojan'}, inboundWhitelist: {}),
      throwsA(isA<SchemaConflictException>().having(
          (e) => e.message, 'message', contains('trojan'))),
    );
  });

  test('无判别 oneOf 拍平（Rule 形状）', () {
    // 在 fixture 的 $defs 加一个 Rule：oneOf 两分支均无 type const、allOf 包裹字段
    // 断言产出单个 ClassSpec，字段为两分支 allOf properties 的并集
    // （fixture 补充 Rule 定义后编写，见 Step 3 补充块）
  });
}
```

最后一个用例的 fixture 补充（追加到 mini_schema.json 的 `$defs`）：

```json
"Rule": {
  "oneOf": [
    { "type": "object", "allOf": [
      { "properties": { "outbound": { "type": "string" }, "network": {
          "anyOf": [{ "type": "string", "enum": ["tcp","udp"] }, { "type": "array" }] } } },
      { "properties": { "protocol": { "type": "string" } } }
    ] },
    { "type": "object", "properties": {
        "action": { "const": "reject" }, "network": { "type": "string" } } }
  ]
}
```

测试体：`expect(ir.classes.singleWhere((c) => c.className == 'Rule').ownFields.map((f) => f.jsonName), containsAll(['outbound', 'network', 'protocol', 'action']))`，且顶层 properties 需能触达 Rule（fixture 顶层加 `"rules": {"type":"array","items":{"$ref":"#/$defs/Rule"}}`）。

- [ ] **Step 3: 跑测试确认失败**

Run: `flutter test test/tool/schema_ir_test.dart`
Expected: FAIL（`schema_ir.dart` 不存在）

- [ ] **Step 4: 实现 schema_ir.dart**

实现要点（数据类签名见 Interfaces；核心方法骨架）：

```dart
// tool/src/schema_ir.dart —— schema 解析为中间表示
import 'names.dart';

class SchemaConflictException implements Exception {
  final String message;
  SchemaConflictException(this.message);
  @override
  String toString() => 'SchemaConflictException: $message';
}

Ir buildIr(Map<String, dynamic> schema,
    {required Set<String> outboundWhitelist, required Set<String> inboundWhitelist}) {
  final defs = (schema[r'$defs'] as Map).cast<String, dynamic>();
  final top = schema['properties'] as Map;
  final collected = <String, ClassSpec>{};
  // 1. 顶层入口：dns/route/experimental/log 递归收集 plain 类
  //    （inbounds/outbounds 由判别分支逻辑处理；ntp 等未建模键直接忽略）
  // 2. 判别类：_collectDiscriminated(defs['Outbound'], whitelist, 'Outbound')
  //            _collectDiscriminated(defs['Inbound'], whitelist, 'Inbound')
  //            _collectDiscriminated(defs['DNSServer'], defs.keys.toSet(), 'DNSServer')
  //            —— DNSServer 无白名单（全量）
  // 3. Rule/DNSRule：_flattenUndiscriminated(...) -> 单 ClassSpec(kind: plain)
  // 4. 共享块：_extractDialer(defs) / _extractListen(入站分支)
  // 5. 白名单校验：outboundWhitelist 中每个类型都必须能在分支里找到，
  //    否则抛 SchemaConflictException('白名单类型 xxx 不在 schema 中')
  // ...
}

/// 判别分支收集：返回 type const -> 分组后的字段并集
/// 分支无 properties 但有 oneOf/anyOf 时递归展开（snell 形状）
/// 分支含 allOf 时把 allOf 子块 properties 并入该分支字段集
Map<String, _Branch> _groupBranches(List branches) { /* ... */ }

/// 同判别值合并：字段并集 / required 交集 / 同名类型冲突抛错
_FieldMerge _mergeSameType(List<_Branch> same) { /* ... */ }

/// 字段级类型映射（映射表见任务描述第 8 条）
String _mapType(Map<String, dynamic> node, Map<String, dynamic> defs,
    {required bool isListItem}) { /* ... */ }
```

`_collectDiscriminated` 对 `DNSServer` 传全量集合（无白名单）。`Inbound` 判别类需应用 `ListenFields`/`DialerFields` 去重（出站类只应用 `DialerFields`）。`tag` 在 required 时非空 `String`。

- [ ] **Step 5: 跑测试确认通过**

Run: `flutter test test/tool/schema_ir_test.dart`
Expected: PASS（8 个用例全绿）

- [ ] **Step 6: Commit**

```bash
git add tool/src/schema_ir.dart test/tool/fixtures/mini_schema.json test/tool/schema_ir_test.dart
git commit -m "feat: schema 解析为 IR（判别收集/嵌套展开/同型合并/无判别拍平/类型映射）"
```

---

### Task 3: Dart 输出器（sealed + Unknown + 工厂 / mixin / 普通类 / SingBox 透传）

**Files:**
- Create: `tool/src/dart_emitter.dart`
- Test: `test/tool/dart_emitter_test.dart`

**Interfaces:**
- Consumes: Task 1/2 的 `Ir` / `ClassSpec` / `FieldSpec` / `fileNameFor`。
- Produces: `Map<String, String> emitDart(Ir ir)`——文件相对路径 → 文件内容（UTF-8 文本）。生成器入口 `gen_models.dart` 负责写盘（Task 4）。

**输出模板（必须逐字实现这些结构）：**

判别基类（`gen/outbound/outbound.dart`）：

```dart
// 本文件由 tool/gen_models.dart 生成，勿手改。
import 'package:json_annotation/json_annotation.dart';

import '../index.dart';
import 'unknown_outbound.dart';

part 'outbound.g.dart';

/// 出站配置，按 type 判别的密封类层级。
sealed class Outbound {
  const Outbound();

  String get tag;
  String get type;

  /// 按 type 判别反序列化；未知类型进 [UnknownOutbound] 透传。
  factory Outbound.fromJson(Map<String, dynamic> json) {
    final type = json['type'] as String?;
    return switch (type) {
      'direct' => DirectOutbound.fromJson(json),
      // ...全部白名单类型
      _ => UnknownOutbound.fromJson(json),
    };
  }
}

/// 白名单内全部出站类型名（对齐测试的数据源）。
const Set<String> kOutboundTypeNames = { 'direct', 'selector', /* ... */ };
```

判别子类（`gen/outbound/hysteria2_outbound.dart`）：

```dart
// 本文件由 tool/gen_models.dart 生成，勿手改。
import 'package:json_annotation/json_annotation.dart';

import '../shared/dialer_fields.dart';
import '../outbound/outbound.dart';

part 'hysteria2_outbound.g.dart';

@JsonSerializable(explicitToJson: true)
class Hysteria2Outbound extends Outbound with DialerFields {
  static const typeName = 'hysteria2';

  @override
  @JsonKey()
  String tag;

  String server;
  int serverPort;
  @JsonKey(name: 'idle_session_check_interval')
  String? idleSessionCheckInterval;
  // ...ownFields 全量

  Hysteria2Outbound({
    required this.tag,
    required this.server,
    required this.serverPort,
    // 可空字段省略（默认 null）
  });

  @override
  String get type => typeName;

  factory Hysteria2Outbound.fromJson(Map<String, dynamic> json) =>
      _$Hysteria2OutboundFromJson(json);

  Map<String, dynamic> toJson() => _$Hysteria2OutboundToJson(this);
}
```

UnknownOutbound（`gen/outbound/unknown_outbound.dart`，纯手写风格由生成器输出）：

```dart
// 本文件由 tool/gen_models.dart 生成，勿手改。
/// 未建模出站类型：持有原始 JSON 原样透传（保真读写）。
class UnknownOutbound extends Outbound {
  final Map<String, dynamic> raw;
  UnknownOutbound(this.raw);

  @override
  String get tag => raw['tag'] as String? ?? '';
  @override
  String get type => raw['type'] as String? ?? '';

  factory UnknownOutbound.fromJson(Map<String, dynamic> json) =>
      UnknownOutbound(Map<String, dynamic>.from(json));

  Map<String, dynamic> toJson() => Map<String, dynamic>.from(raw);
}
```

mixin（`gen/shared/dialer_fields.dart`）：

```dart
// 本文件由 tool/gen_models.dart 生成，勿手改。
import 'package:json_annotation/json_annotation.dart';

part 'dialer_fields.g.dart';

/// 拨号共享字段（对应官方 DialerOptions），字段一律可空。
mixin DialerFields {
  String? detour;
  @JsonKey(name: 'routing_mark')
  Object? routingMark;
  @JsonKey(name: 'connect_timeout')
  String? connectTimeout;
  // ...
}
```

注意：mixin 本身**不加** `@JsonSerializable`（无构造无工厂），`@JsonKey` 注解写在字段上即可被子类生成器读取；mixin 不需要 `.g.dart`（part 声明去掉）。

顶层 SingBox（`gen/sing_box.dart`）：

```dart
// 本文件由 tool/gen_models.dart 生成，勿手改。
import 'package:json_annotation/json_annotation.dart';

import 'dns.dart';
import 'inbound/inbound.dart';
import 'log.dart';
import 'outbound/outbound.dart';
import 'route_options.dart';
import 'experimental_options.dart';

part 'sing_box.g.dart';

@JsonSerializable(explicitToJson: true)
class SingBox {
  static const _knownKeys = {'log', 'dns', 'inbounds', 'outbounds', 'route', 'experimental'};

  Dns dns;
  List<Inbound> inbounds;
  List<Outbound> outbounds;
  RouteOptions route;
  ExperimentalOptions? experimental;
  Log? log;

  /// 未建模顶层段（ntp 等）原样透传：读入收存、输出合并。
  @JsonKey(includeFromJson: false, includeToJson: false)
  final Map<String, dynamic> unknownSections = {};

  SingBox({
    required this.dns,
    required this.inbounds,
    required this.outbounds,
    required this.route,
    this.experimental,
    this.log,
  });

  factory SingBox.fromJson(Map<String, dynamic> json) {
    final result = _$SingBoxFromJson(json);
    json.forEach((key, value) {
      if (!_knownKeys.contains(key)) result.unknownSections[key] = value;
    });
    return result;
  }

  Map<String, dynamic> toJson() {
    final result = _$SingBoxToJson(this);
    result.addAll(unknownSections);
    return result;
  }
}
```

普通类（dns.dart / route_options.dart / rule.dart 等 plain 类）参照子类模板（无 typeName/getter，构造含全部 required 字段）。

index.dart：汇总 export 全部生成文件。

`emitDart` 返回的 map 键：`outbound/outbound.dart`、`outbound/<type>_outbound.dart`、`outbound/unknown_outbound.dart`、`inbound/*`、`shared/dialer_fields.dart`、`shared/listen_fields.dart`、各 plain 类 `<snake>.dart`、`sing_box.dart`、`index.dart`。

- [ ] **Step 1: 写失败测试**

```dart
// test/tool/dart_emitter_test.dart
import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import '../../tool/src/schema_ir.dart';
import '../../tool/src/dart_emitter.dart';

Ir fixtureIr() => buildIr(
      jsonDecode(File('test/tool/fixtures/mini_schema.json').readAsStringSync())
          as Map<String, dynamic>,
      outboundWhitelist: {'hysteria2', 'snell', 'urltest'},
      inboundWhitelist: {},
    );

void main() {
  late Map<String, String> files;

  setUpAll(() => files = emitDart(fixtureIr()));

  test('产出文件清单完整', () {
    expect(files.keys, containsAll([
      'sing_box.dart',
      'outbound/outbound.dart',
      'outbound/hysteria2_outbound.dart',
      'outbound/snell_outbound.dart',
      'outbound/unknown_outbound.dart',
      'shared/dialer_fields.dart',
      'rule.dart',
      'log_options.dart',
      'index.dart',
    ]));
  });

  test('sealed 基类含判别工厂与类型注册表', () {
    final outbound = files['outbound/outbound.dart']!;
    expect(outbound, contains('sealed class Outbound'));
    expect(outbound, contains("factory Outbound.fromJson"));
    expect(outbound, contains("'hysteria2' => Hysteria2Outbound.fromJson(json)"));
    expect(outbound, contains('_ => UnknownOutbound.fromJson(json)'));
    expect(outbound, contains('kOutboundTypeNames'));
  });

  test('子类结构：typeName / type getter / mixin / JsonKey', () {
    final h2 = files['outbound/hysteria2_outbound.dart']!;
    expect(h2, contains("static const typeName = 'hysteria2'"));
    expect(h2, contains('String get type => typeName'));
    expect(h2, contains('extends Outbound with DialerFields'));
    expect(h2, contains("@JsonKey(name: 'connect_timeout')"), reason: 'mixin 字段带 JsonKey');
    // 注意 connect_timeout 在 mixin；子类断言改用 own 字段
  });

  test('mixin 无 JsonSerializable 注解且字段可空', () {
    final dialer = files['shared/dialer_fields.dart']!;
    expect(dialer, contains('mixin DialerFields'));
    expect(dialer, isNot(contains('@JsonSerializable')));
    expect(dialer, contains('Object? routingMark'));
  });

  test('SingBox 透传 unknownSections', () {
    final sb = files['sing_box.dart']!;
    expect(sb, contains('unknownSections'));
    expect(sb, contains('_knownKeys'));
    expect(sb, contains("includeFromJson: false"));
  });

  test('snell 合并类含 version 必填与 v4/v6 字段', () {
    final snell = files['outbound/snell_outbound.dart']!;
    expect(snell, contains('int version'));
    expect(snell, contains('String? obfsMode'));
    expect(snell, contains('String? mode'));
  });

  test('Rule 拍平类字段并集', () {
    expect(files['rule.dart'], contains('String? outbound'));
    expect(files['rule.dart'], contains('String? protocol'));
    expect(files['rule.dart'], contains('String? action'));
  });

  test('全部文件带勿手改头注释', () {
    for (final content in files.values) {
      expect(content, startsWith('// 本文件由 tool/gen_models.dart 生成，勿手改。'));
    }
  });
}
```

- [ ] **Step 2: 跑测试确认失败**

Run: `flutter test test/tool/dart_emitter_test.dart`
Expected: FAIL（`dart_emitter.dart` 不存在）

- [ ] **Step 3: 实现 dart_emitter.dart**

按上述模板实现字符串组装。要点：
- import 收集：每个文件按其引用的类名/文件名计算相对 import（同目录省 `./`，跨目录 `../`）。
- 构造函数参数仅含 ownFields 中 required 字段；mixin 字段与可空字段不进构造。
- `part '<file>.g.dart';` 与文件名一致；mixin 文件无 part。
- jsonName == dartName 时省略 `@JsonKey(name:)`。
- switch 工厂分支按白名单字母序排列（保证输出确定性，diff 稳定）。

- [ ] **Step 4: 跑测试确认通过**

Run: `flutter test test/tool/dart_emitter_test.dart`
Expected: PASS（8 个用例全绿）

- [ ] **Step 5: Commit**

```bash
git add tool/src/dart_emitter.dart test/tool/dart_emitter_test.dart
git commit -m "feat: Dart 输出器（sealed+Unknown 透传/mixin/普通类/SingBox 未知段保真）"
```

---

### Task 4: 入口串联 + 端到端 golden 测试 + 失败防护

**Files:**
- Modify: `tool/gen_models.dart`（替换骨架 TODO：buildIr → emitDart → 写盘）
- Test: `test/tool/gen_models_e2e_test.dart`

**Interfaces:**
- Consumes: Task 2 `buildIr`、Task 3 `emitDart`。
- Produces: CLI 行为——`dart run tool/gen_models.dart [schemaPath] [outputRoot]`；成功写盘退出 0；白名单失配抛 `SchemaConflictException` 时**不写任何文件**、退出码 2、stderr 输出错误。

- [ ] **Step 1: 写失败测试**

```dart
// test/tool/gen_models_e2e_test.dart
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late Directory tmpOut;

  setUp(() {
    tmpOut = Directory.systemTemp.createTempSync('gen_models_test');
  });
  tearDown(() => tmpOut.deleteSync(recursive: true));

  test('迷你 schema 端到端：写盘成功且文件齐全', () async {
    final result = await Process.run(
      'dart',
      ['run', 'tool/gen_models.dart', 'test/tool/fixtures/mini_schema.json', tmpOut.path],
      workingDirectory: Directory.current.path,
    );
    expect(result.exitCode, 0, reason: result.stderr as String);
    final outboundFile = File('${tmpOut.path}/outbound/outbound.dart');
    expect(outboundFile.existsSync(), isTrue);
    expect(outboundFile.readAsStringSync(), contains('sealed class Outbound'));
  });

  test('白名单失配：退出码 2 且不写任何文件', () async {
    // 用一个只有 urltest 类型的迷你 schema，但 CLI 白名单是内置的（含 hysteria2 等）
    // 失配路径：schemaPath 指向缺类型的文件。
    final broken = File('${tmpOut.path}/broken_schema.json')
      ..writeAsStringSync('{"properties": {}, "\$defs": {}}');
    final result = await Process.run(
      'dart',
      ['run', 'tool/gen_models.dart', broken.path, tmpOut.path],
      workingDirectory: Directory.current.path,
    );
    expect(result.exitCode, 2);
    expect(result.stderr as String, contains('不在 schema 中'));
    expect(File('${tmpOut.path}/outbound').existsSync(), isFalse, reason: '失败时不留半成品');
  });
}
```

注意：CLI 的白名单是内置常量（真实 17+2），对迷你 schema 会失配——第一个用例需给入口加 `--whitelist-outbound hysteria2,snell,urltest --whitelist-inbound` 覆盖参数（入口解析这两个可选 flag，缺省用内置白名单）。测试命令补上该 flag。

- [ ] **Step 2: 跑测试确认失败**

Run: `flutter test test/tool/gen_models_e2e_test.dart`
Expected: FAIL（入口尚未串联）

- [ ] **Step 3: 实现入口串联**

```dart
// tool/gen_models.dart 核心流程（骨架已有，替换 TODO 段）
// 参数：[schemaPath] [outputRoot] [--whitelist-outbound a,b,c] [--whitelist-inbound x,y]
try {
  final ir = buildIr(schema, outboundWhitelist: obWhitelist, inboundWhitelist: inWhitelist);
  final files = emitDart(ir);
  // 先全部写入 .tmp 再统一 rename？更简单：buildIr 成功后才可能写盘，
  // emitDart 若抛错则此时尚未写任何文件——直接循环写即可满足「失败不留半成品」。
  for (final entry in files.entries) {
    final f = File('${outputRoot}${Platform.pathSeparator}${entry.key}');
    f.createSync(recursive: true);
    f.writeAsStringSync(entry.value);
  }
  stdout.writeln('已生成 ${files.length} 个文件到 $outputRoot');
} on SchemaConflictException catch (e) {
  stderr.writeln(e);
  exitCode = 2;
}
```

- [ ] **Step 4: 跑测试确认通过**

Run: `flutter test test/tool/gen_models_e2e_test.dart`
Expected: PASS（2 个用例）

- [ ] **Step 5: Commit**

```bash
git add tool/gen_models.dart test/tool/gen_models_e2e_test.dart
git commit -m "feat: 生成器入口串联（写盘/白名单失配退出码 2 不留半成品）"
```

---

### Task 5: 真实 schema 生成 + build_runner + 静态分析

**Files:**
- Create: `lib/src/data/models/singbox/gen/`（生成器输出，约 40+ 文件）
- Create: `lib/src/data/models/singbox/gen/**/*.g.dart`（build_runner 输出）

**Interfaces:**
- Consumes: Task 4 的 CLI。
- Produces: `package:flutter_sing_box/src/data/models/singbox/gen/index.dart` 的公开导出（后续 Task 6/7 的依赖）。

- [ ] **Step 1: 运行生成器（真实 schema）**

Run: `dart run tool/gen_models.dart`
Expected: 「已生成 N 个文件到 lib/src/data/models/singbox/gen」（N 预计 50–70；DNSServer 15 类 + 出站 17+unknown + 入站 2+unknown + plain 类若干）

- [ ] **Step 2: 代码生成 .g.dart**

Run: `dart run build_runner build --delete-conflicting-outputs 2>&1 | tail -5`

注意：当前版本 build_runner 若提示 `--delete-conflicting-outputs` 已移除则去掉该参数重跑（见仓库 CLAUDE.md 约定）。
Expected: `Succeeded`（无 error；warning 若来自旧手写文件可忽略，来自 gen/ 的必须修生成器后重跑）

- [ ] **Step 3: 静态分析**

Run: `flutter analyze`
Expected: gen/ 下零 error 零 warning。若 analyzer 报 mixin 字段序列化问题或 import 缺失——回到 Task 3 修 emitter 重生成（这正是 TDD 循环：生成器是「实现」，analyze 是「测试」）。

- [ ] **Step 4: 人工抽查生成物**

打开 `gen/outbound/hysteria2_outbound.dart` 与 `gen/outbound/snell_outbound.dart` 对照 schema：字段名/JsonKey/可空性正确；`gen/rule.dart` 为并集拍平形态。

- [ ] **Step 5: Commit**

```bash
git add lib/src/data/models/singbox/gen/ tool/
git commit -m "feat: 真实 schema 首次生成 sealed 模型层（白名单 17 出站 + 2 入站 + plain 类）"
```

---

### Task 6: 生成物单测（round-trip 保真 / schema 反向校验闭环 / 对齐测试）

**Files:**
- Test: `test/src/data/models/singbox/gen/round_trip_test.dart`
- Test: `test/src/data/models/singbox/gen/schema_validate_test.dart`
- Test: `test/src/data/models/singbox/gen/whitelist_align_test.dart`
- Create: `test/src/data/models/singbox/gen/fixtures/user_config.json`（含白名单外协议与未知顶层段的样例配置）

**Interfaces:**
- Consumes: `gen/index.dart` 导出、`SingBoxSchemaValidator.fromMap`、`OutboundType`/`InboundType` 常量、`kOutboundTypeNames`/`kInboundTypeNames` 注册表。

- [ ] **Step 1: 写用户配置 fixture（覆盖 Review Focus 1/2/3/5）**

```json
// fixtures/user_config.json —— 模拟用户 sing-box 配置：白名单内协议 + wireguard（白名单外）
// + snell v4 + 顶层未知段 ntp + network 双形态字段
{
  "log": { "level": "info", "timestamp": true },
  "dns": {
    "servers": [
      { "tag": "local-dns", "type": "local" },
      { "tag": "remote", "type": "udp", "server": "8.8.8.8", "server_port": 53 }
    ],
    "final": "remote"
  },
  "ntp": { "server": "time.apple.com", "server_port": 123 },
  "inbounds": [
    { "type": "tun", "tag": "tun-in", "address": ["172.19.0.1/30"], "auto_route": true }
  ],
  "outbounds": [
    { "type": "urltest", "tag": "auto", "outbounds": ["h2-node", "wg"], "url": "https://g.cn" },
    { "type": "hysteria2", "tag": "h2-node", "server": "a.cn", "server_port": 443,
      "password": "pw", "network": "tcp", "tls": { "enabled": true, "server_name": "a.cn" } },
    { "type": "snell", "tag": "sn", "server": "b.cn", "server_port": 6160,
      "version": 4, "psk": "k", "obfs_mode": "http" },
    { "type": "wireguard", "tag": "wg", "local_address": ["10.0.0.2/32"],
      "private_key": "AAA", "peer": [{}] }
  ],
  "route": {
    "rules": [ { "protocol": "dns", "action": "hijack-dns" },
               { "ip_is_private": true, "outbound": "direct" } ],
    "final": "auto",
    "auto_detect_interface": true
  }
}
```

（fixture 写完后先用 `SingBoxSchemaValidator` 手工核验合法，再用于 round-trip——若个别字段不被当前 schema 接受，微调至校验通过。）

- [ ] **Step 2: 写 round-trip 测试**

```dart
// round_trip_test.dart 核心断言
test('未知协议 wireguard 原样透传', () {
  final sb = SingBox.fromJson(deepCopy(userConfig));
  final wg = sb.outbounds.singleWhere((o) => o.type == 'wireguard');
  expect(wg, isA<UnknownOutbound>());
  final out = sb.toJson();
  final wgJson = (out['outbounds'] as List).singleWhere((o) => o['tag'] == 'wg');
  expect(wgJson['private_key'], 'AAA');           // 未建模字段不丢
  expect(wgJson['peer'], [{}]);
});

test('未知顶层段 ntp 原样透传', () {
  final out = SingBox.fromJson(deepCopy(userConfig)).toJson();
  expect(out['ntp'], { 'server': 'time.apple.com', 'server_port': 123 });
});

test('snell v4 合并类正确解析', () {
  final sn = SingBox.fromJson(deepCopy(userConfig)).outbounds
      .singleWhere((o) => o.type == 'snell') as SnellOutbound;
  expect(sn.version, 4);
  expect(sn.obfsMode, 'http');
  expect(sn.mode, isNull);
});

test('Duration 与 network 双形态字段 round-trip 不变形', () {
  final out = SingBox.fromJson(deepCopy(userConfig)).toJson();
  final h2 = (out['outbounds'] as List).singleWhere((o) => o['tag'] == 'h2-node');
  expect(h2['network'], 'tcp');
});

test('整体 round-trip 深度相等', () {
  expect(SingBox.fromJson(deepCopy(userConfig)).toJson(), deepCopy(userConfig));
});

test('畸形输入：缺 tag 抛类型错误', () {
  expect(() => Outbound.fromJson({'type': 'hysteria2'}),
      throwsA(isA<TypeError>()));
});
```

（`deepCopy` 用 `jsonDecode(jsonEncode(x))` 实现。）

- [ ] **Step 3: 写 schema 反向校验闭环测试**

```dart
// schema_validate_test.dart —— 生成物 toJson 必须通过官方 schema 校验
test('生成配置通过官方 schema 校验', () async {
  final validator = await SingBoxSchemaValidator.instance(
    assetLoader: (path) => File('assets/schemas/singbox_schema.json').readAsString(),
  );
  final out = SingBox.fromJson(deepCopy(userConfig)).toJson();
  final errors = validator.validateSync(out);
  expect(errors, isEmpty,
      reason: errors.take(5).map((e) => e.toErrorString()).join('\n'));
});

test('构建典型配置（direct+selector+urltest+tun+mixed）通过校验', () {
  // 用生成类手工构建 sing_box_config_provider 等价的典型配置 -> toJson -> 校验
  // 断言零错误（此用例同时预演阶段二的构建侧用法）
});
```

- [ ] **Step 4: 写白名单对齐测试**

```dart
// whitelist_align_test.dart
test('OutboundType 常量表与生成注册表一致，失配时给出重跑指引', () {
  const expected = { OutboundType.direct, OutboundType.selector, /* 全 17 项 */ };
  expect(kOutboundTypeNames, expected,
      reason: 'OutboundType 与生成物不一致：请修改 tool/src/names.dart 白名单后'
          '运行 dart run tool/gen_models.dart 并重新 build_runner');
});
test('InboundType 常量表与生成注册表一致', () {
  expect(kInboundTypeNames, {InboundType.tun, InboundType.mixed});
});
```

- [ ] **Step 5: 跑全部新测试**

Run: `flutter test test/src/data/models/singbox/gen/`
Expected: PASS（round-trip 6 + validate 2 + align 2）。round-trip 深度相等若失败，逐字段定位是生成器问题（回 Task 2/3 修）还是 fixture 问题（对照 schema 修正）。

- [ ] **Step 6: 全量测试 + 回归检查**

Run: `flutter test && flutter analyze`
Expected: 全绿（旧手写模型仍在、未被引用新模型不影响既有测试）

Run: GitNexus `detect_changes()`（flutter_sing_app 仓库视角无需——本任务纯增量，在 flutter_sing_box 仓库跑其 GitNexus 回归；若该仓库未配 GitNexus 则以 `flutter test` 全绿为准）
Expected: 变更仅含 tool/、gen/、test/ 新增文件，无既有符号受影响

- [ ] **Step 7: Commit**

```bash
git add test/src/data/models/singbox/gen/
git commit -m "test: 生成物三重测试（round-trip 保真/schema 反向校验闭环/白名单对齐）"
```

**阶段一完成标志：生成器 + 生成物 + 测试全绿落地，现有代码零改动。此处是 spec 规定的阶段门禁——停下来让用户 review 阶段一再进入阶段二。**

---

# 阶段二：切换消费侧 + 删除旧模型 + 发版 3.0.0

> 阶段二开始前：确认阶段一已 review 合入；`clash_sing_app` 的 `pubspec.yaml` 启用 `dependency_overrides: flutter_sing_box: path: ../flutter_sing_box` 并 `flutter pub get`（工作目录切到 `d:\projs_dg\clash_sing_app` 执行 App 侧命令）。

### Task 7: 插件内生产侧切换（三个 provider 重写）

**Files:**
- Modify: `lib/src/core/provider/clash_provider.dart`（`toOutbound()` 两处，约 12 个协议分支）
- Modify: `lib/src/core/provider/base64_provider.dart`（6 处 `Outbound(...)` 构造）
- Modify: `lib/src/core/provider/sing_box_config_provider.dart`（3 处构造 + 配置组装处对 SingBox/Route/Dns 的构建）
- Modify: `lib/src/windows/clash_http_client.dart:183-187`（`OutboundType.selector/urltest/direct` 比较处——若沿用 `type` 字符串比较则无需改动，验证即可）

**Interfaces:**
- Consumes: `gen/index.dart` 全部类型。
- Produces: 三个 provider 输出 `gen` 模型实例（App 侧 Task 8 依赖）。

**改写模式（机械转换）：**

```dart
// 旧（拍平构造）：
ClashProxyType.hysteria2 => Outbound(
  tag: name, type: OutboundType.hysteria2,
  server: server, serverPort: port, password: up, upMbps: up, downMbps: down),

// 新（sealed 子类构造）：
ClashProxyType.hysteria2 => Hysteria2Outbound(
  tag: name, server: server, serverPort: port, password: up,
  upMbps: up, downMbps: down),
```

- `type:` 参数一律删除（子类自带）；`selector/urltest` 组 → `SelectorOutbound/UrltestOutbound`；`direct` → `DirectOutbound`。
- import 从 `flutter_sing_box.dart` 的旧导出换到 gen 导出（见 Task 9 导出汇总，本任务先直接 import gen/index.dart，Task 9 统一收口到包级导出）。
- 逐文件小步改：每改完一个 provider 立即 `flutter analyze`，全部改完后跑插件全部测试。

- [ ] **Step 1: 重写 clash_provider.dart 的 toOutbound()**

按上述模式转换 12 个分支。hysteria 分支注意 `auth_str`/`authStr` 等字段名在 `HysteriaOutbound` 中的准确 dart 名（以 gen 生成物为准，字段名与旧类一致的直接映射）。

- [ ] **Step 2: flutter analyze 确认该文件零新增告警**

Run: `flutter analyze | grep clash_provider`
Expected: 无输出（零告警）

- [ ] **Step 3: 重写 base64_provider.dart 六处构造**（同模式）

- [ ] **Step 4: 重写 sing_box_config_provider.dart**

配置组装处 `SingBox(dns: ..., inbounds: [TunInbound/MixedInbound(...)], ...)`——Inbound 同样 sealed 化：`TunInbound(tag: ...)`（type 自带）。Route/Dns/Log/Experimental 用 gen 对应类，字段名 snake→camel 对齐生成物。

- [ ] **Step 5: 跑插件全部测试**

Run: `flutter test`
Expected: 既有 provider 测试若有对旧拍平类的断言，按新类型同步修正断言（构造与字段读取语法变化，语义不变）；修正后全绿。

- [ ] **Step 6: Commit**

```bash
git add lib/src/core/provider/ test/
git commit -m "refactor: 三个 provider 切换到生成的 sealed 模型（clash/base64/sing_box_config）"
```

---

### Task 8: App 侧适配 + 联调验证

**工作目录：`d:\projs_dg\clash_sing_app`（独立 git 仓库）**

**Files:**
- Modify: `lib/src/utils/merge_singbox_config.dart`
- Modify: `lib/src/utils/sing_box_ext.dart`
- Modify: `lib/src/vm/state_wrapper_vm.dart`
- Modify: `lib/src/ui/global_settings/vm/global_settings_vm.dart`
- Modify: `lib/src/ui/home/vm/home_proxies_vm.dart`
- Modify: `pubspec.yaml`（启用 dependency_overrides——联调临时态）

**Interfaces:**
- Consumes: Task 7 的 gen 模型（经 override path 依赖）。
- Produces: App 全链路使用 gen 模型。

**改写模式：**

```dart
// merge_singbox_config.dart —— 可变赋值保留，仅类型收紧：
// 旧：
final List<Outbound> outbounds = singBox.outbounds
    .where((outbound) => outbound.type == OutboundType.urltest).toList();
for (var outbound in outbounds) { outbound.url = ...; }
// 新：
final urltests = singBox.outbounds.whereType<UrltestOutbound>().toList();
for (final outbound in urltests) { outbound.url = ...; }   // 可变类，直接赋值不变

// 旧：singBox.outbounds.where((e) => e.outbounds?.isNotEmpty == true).first.tag
// 新：不变（tag/outbounds 在基类/子类均有）——验证即可
```

- [ ] **Step 1: 启用 override 并 pub get**

`pubspec.yaml` 取消 `dependency_overrides` 段注释 → `flutter pub get`。

- [ ] **Step 2: 按模式改五个文件**，每文件改完 `flutter analyze` 零新增告警。

- [ ] **Step 3: 跑 App 全部测试**

Run: `flutter test`
Expected: 全绿（涉旧模型断言按新类型修正）

- [ ] **Step 4: 双端联调验证**

Run: `flutter run -d windows`（App 侧）
手动验证：导入含 wireguard+snell 的订阅/配置 → 合并配置 → 启动内核 → 连接正常；退出重进设置无损。若 Android 真机在手：`flutter run` 复验 VPN 路径。

- [ ] **Step 5: Commit（App 仓库）**

```bash
git add lib/ pubspec.yaml pubspec.lock
git commit -m "refactor: App 切换到 flutter_sing_box 生成的 sealed 模型"
```

注意：**此 commit 包含 override 启用态**，Task 10 末尾还原 override 时再单独提交还原 commit。

---

### Task 9: 删除旧模型 + 导出收口 + 版本 3.0.0

**工作目录：`d:\projs_dg\flutter_sing_box`**

**Files:**
- Delete: `lib/src/data/models/singbox/outbound.dart` / `inbound.dart` / `dns.dart` / `route.dart` / `tls.dart` / `log.dart` / `experimental.dart` / `sing_box.dart` 及对应 `.g.dart`（保留 `schema_validator.dart` 与其 asset 逻辑）
- Modify: `lib/src/data/models/singbox/index.dart`（改为 export `gen/index.dart` 等）
- Modify: `lib/flutter_sing_box.dart`（顶层导出不变，经 index 传导）
- Modify: `pubspec.yaml`（version: 3.0.0）、`CHANGELOG.md`

**Interfaces:**
- Produces: 包级公开 API——`Outbound`/`Inbound`/`SingBox`/`Dns`/`RouteOptions`/`Rule` 等名字不变（类型来自 gen），App 现有 import `package:flutter_sing_box/flutter_sing_box.dart` 无需改动。

- [ ] **Step 1: 删除旧模型文件，index.dart 改为导出 gen**

```dart
// lib/src/data/models/singbox/index.dart
export 'schema_validator.dart';
export 'gen/index.dart';
```

- [ ] **Step 2: build_runner + analyze + test**

Run: `dart run build_runner build && flutter analyze && flutter test`
Expected: 全绿（无 dangling import；clash/ 目录常量 `OutboundType` 等仍在 constants/，未删）

- [ ] **Step 3: 版本与变更日志**

`pubspec.yaml`: `version: 3.0.0`；`CHANGELOG.md` 顶部新增 3.0.0 段（破坏性变更：模型层 schema 生成化、Outbound/Inbound sealed 化、新增 Unknown 透传与未知顶层段保真）。

- [ ] **Step 4: Commit**

```bash
git add -A
git commit -m "refactor!: 移除旧手写 sing-box 模型，gen 模型收口为公开 API，版本 3.0.0"
```

---

### Task 10: 全量回归 + 还原 override + 收尾

**Files:**
- Modify: `clash_sing_app/pubspec.yaml`（注释还原 dependency_overrides）

- [ ] **Step 1: 插件仓库最终回归**

Run（flutter_sing_box）: `flutter analyze && flutter test`
Expected: 全绿
Run: GitNexus `detect_changes({scope: "compare", base_ref: "main"})`
Expected: 变更集中于 models/singbox/（gen 新增+旧删除）、core/provider/、tool/、test/；无 schema_validator 与无关模块变更

- [ ] **Step 2: App 仓库最终回归（override 还原前，用 path 依赖跑全量）**

Run（clash_sing_app）: `flutter analyze && flutter test`
Expected: 全绿

- [ ] **Step 3: 还原 override**

`pubspec.yaml` 重新注释 `dependency_overrides` 段 → `flutter pub get` → `flutter analyze`。
注意：还原后 App 依赖 pub.dev 的 2.0.4（不含新模型），编译会失败是**预期**——发布 3.0.0 后升 App 依赖即恢复。因此本步骤只在**准备发版时**执行；若阶段二合入后暂不发版，保持 override 启用态合入 develop 亦可（发布门禁前必须还原，见仓库 CLAUDE.md）。

- [ ] **Step 4: 结尾 commit（如执行了 Step 3）**

```bash
git add pubspec.yaml pubspec.lock
git commit -m "chore: 联调完成，还原 dependency_overrides（待 3.0.0 发版后升级依赖）"
```

---

## 自审记录（Self-Review）

1. **Spec 覆盖**：生成器架构（Task 1-4）、生成物与 Unknown 透传（Task 3/5/6）、共享块提取（Task 2 规则 9）、snell 合并（Task 2 规则 5）、两阶段迁移（Task 7-8）、删旧+3.0.0（Task 9）、四层测试（Task 2/3/4 单测 + Task 6 三重测试）、升级流程（Task 4 CLI 化 + 文档头注释）、override 还原约束（Global Constraints + Task 8/10）——均有对应任务。
2. **占位符扫描**：Task 2 Step 4 骨架含 `/* ... */` 注释段——这是实现引导注释而非「待补内容」，规则表在任务描述中完整给出；其余无 TBD/TODO。
3. **类型一致性**：`buildIr`/`emitDart`/`SchemaConflictException`/`kOutboundTypeNames`/`kInboundTypeNames` 在 Task 2/3/4/6 间签名一致；`RouteOptions`（非 `Route`）与 schema `$defs` 键名对齐。
4. **Review Focus 落位**：5 项分别 pin 在 Task 6（round-trip 3 项 + 对齐指引）与 Task 4（失败防护）。
