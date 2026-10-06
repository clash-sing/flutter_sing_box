// tool/src/schema_ir.dart —— schema 解析为中间表示（IR）
// 纯 Dart，禁止 Flutter import；Task 3（Dart 输出器）的直接输入。
//
// 解析规则（任务简报第 1-10 条）：
//  1. 顶层入口仅 log/dns/route/experimental（递归收集 plain 类）；inbounds/outbounds
//     走判别收集；ntp/certificate 等未建模顶层键不进 IR。
//  2. 从顶层入口沿 $ref 递归可达收集，逐个生成 kind: plain 的类，不重复。
//  3. Outbound/Inbound/DNSServer 的 oneOf 分支按 properties.type.const 分组；
//     白名单外的 outbound/inbound 类型跳过（Unknown 兜底由 Task 3 处理，IR 不生成类）。
//  4. 分支无 properties 但含 oneOf/anyOf（snell 形状）→ 递归展开子分支。
//  5. 同判别值多分支合并：字段并集、required 交集、同 jsonName 类型冲突抛错。
//  6. 无判别 oneOf（Rule/DNSRule 形状，分支 allOf 包裹）→ 拍平为单类，
//     字段（含 allOf 子块 properties，$ref 子块解析目标 def）并集、required 交集。
//  7. const 值字段按标量的 Dart 类型映射，可空性按合并后 required。
//  8. 类型映射表见 _mapType / _mapRef。
//  9. DialerFields = $defs.DialerOptions 全字段；ListenFields = 白名单入站分支
//     properties 键交集 − {tag, type}；mixin 字段一律可空；判别类字段 =
//     分支字段 − mixin 已含字段 − type，tag 留在本类。
// 10. type 不进判别类字段（Task 3 由 typeName + getter 表达）。
import 'names.dart';

/// schema 字段规格
class FieldSpec {
  const FieldSpec({
    required this.jsonName,
    required this.dartName,
    required this.dartType,
    required this.required,
  });

  /// schema 原名（snake_case）
  final String jsonName;

  /// lowerCamelCase 字段名
  final String dartName;

  /// Dart 类型（含可空性后缀，如 `String` / `OutboundTLSOptions?` / `List<String>?`）
  final String dartType;

  /// 是否必填（决定可空性与构造函数参数）
  final bool required;
}

/// 类规格
class ClassSpec {
  const ClassSpec({
    required this.className,
    required this.typeName,
    required this.ownFields,
    required this.mixins,
    required this.kind,
  });

  /// 类名（'Hysteria2Outbound' / 'Rule' / 'OutboundTLSOptions'）
  final String className;

  /// 判别值（'hysteria2'）；普通类为 null。
  /// DNSServer 全量收集的判别类为保留判别信息也带 typeName（kind 仍为 'plain'）。
  final String? typeName;

  /// 本类字段（不含 mixin 字段）
  final List<FieldSpec> ownFields;

  /// 混入的共享块名（'DialerFields' / 'ListenFields'），仅含实际吸收了字段的
  final List<String> mixins;

  /// 'outbound' / 'inbound' / 'plain'
  final String kind;
}

/// 中间表示
class Ir {
  const Ir({required this.classes, required this.mixins});

  final List<ClassSpec> classes;

  /// mixin 名 -> 字段集（字段一律可空）
  final Map<String, List<FieldSpec>> mixins;
}

/// schema 与预期结构不符（白名单失配 / 字段类型冲突 / 未知形状）
class SchemaConflictException implements Exception {
  final String message;
  SchemaConflictException(this.message);

  @override
  String toString() => 'SchemaConflictException: $message';
}

/// 判别收集（DNSServer）/ 拍平（Rule/DNSRule）显式处理的 def 名，
/// 递归可达收集遇到时跳过，避免重复生成
const _skipDefNames = {'Outbound', 'Inbound', 'DNSServer', 'Rule', 'DNSRule'};

/// 解析入口：schema JSON -> IR
Ir buildIr(
  Map<String, dynamic> schema, {
  required Set<String> outboundWhitelist,
  required Set<String> inboundWhitelist,
}) {
  final defs = _asMap(schema[r'$defs']);
  final top = _asMap(schema['properties']);
  final classes = <ClassSpec>[];
  final mixins = <String, List<FieldSpec>>{};
  final refQueue = <String>[];

  // ---- 判别分支展开 + 白名单校验（失配即抛，消息含「不在 schema 中」）----
  final outboundGroups = _groupedByType(defs, 'Outbound');
  final inboundGroups = _groupedByType(defs, 'Inbound');
  _validateWhitelist(outboundWhitelist, outboundGroups, '出站');
  _validateWhitelist(inboundWhitelist, inboundGroups, '入站');

  // ---- 共享块提取（规则 9）----
  final dialerKeys = <String>{};
  if (defs.containsKey('DialerOptions')) {
    final merged = _flattenDef('DialerOptions', defs);
    // mixin 字段一律可空：进 mixin 的字段 required 降级为 false
    mixins['DialerFields'] = _toFieldSpecs(merged, forceNullable: true);
    dialerKeys.addAll(merged.props.keys);
    _collectRefTargets(merged.props, defs, refQueue);
  }

  final listenKeys = <String>{};
  final whitelistedInbound = <_BranchFields>[];
  inboundGroups.forEach((type, branches) {
    if (inboundWhitelist.contains(type)) whitelistedInbound.addAll(branches);
  });
  if (whitelistedInbound.isNotEmpty) {
    // 白名单入站分支 properties 键交集 − {tag, type}；字段节点取首个分支
    //（交集保证每个键在所有分支都存在；跨类型同名字段类型可能不同，此处取首分支形状）
    var keys = whitelistedInbound.first.props.keys.toSet();
    for (var i = 1; i < whitelistedInbound.length; i++) {
      keys = keys.intersection(whitelistedInbound[i].props.keys.toSet());
    }
    keys
      ..remove('tag')
      ..remove('type');
    if (keys.isNotEmpty) {
      final listenProps = <String, Map<String, dynamic>>{
        for (final k in keys) k: whitelistedInbound.first.props[k]!,
      };
      mixins['ListenFields'] = [
        for (final entry in listenProps.entries)
          FieldSpec(
            jsonName: entry.key,
            dartName: lowerCamel(entry.key),
            dartType: _nullable(_mapType(entry.value, defs, isListItem: false)),
            required: false, // 一律可空
          ),
      ];
      listenKeys.addAll(keys);
      _collectRefTargets(listenProps, defs, refQueue);
    }
  }

  // ---- 判别类（规则 3/4/5/10）：出站只吸收 DialerFields，入站再吸收 ListenFields ----
  classes.addAll(_discriminatedClasses(
    outboundGroups,
    outboundWhitelist,
    'outbound',
    classNameForOutbound,
    defs,
    ['DialerFields'],
    {'DialerFields': dialerKeys},
    refQueue,
    forceTagRequired: true,
  ));
  classes.addAll(_discriminatedClasses(
    inboundGroups,
    inboundWhitelist,
    'inbound',
    classNameForInbound,
    defs,
    ['ListenFields', 'DialerFields'],
    {'ListenFields': listenKeys, 'DialerFields': dialerKeys},
    refQueue,
    forceTagRequired: true,
  ));
  // DNSServer 无白名单（全量）；类名如 HttpsDNSServer，kind 为 'plain' 但保留 typeName
  classes.addAll(_discriminatedClasses(
    _groupedByType(defs, 'DNSServer'),
    null,
    'plain',
    (type) => '${pascalCase(type)}DNSServer',
    defs,
    const [],
    const {},
    refQueue,
    forceTagRequired: false, // DNSServer 类 tag 跟随 schema required
  ));

  // ---- 无判别 oneOf 拍平（规则 6）：Rule / DNSRule ----
  for (final name in const ['Rule', 'DNSRule']) {
    if (!defs.containsKey(name)) continue;
    classes.add(_flattenClass(name, defs, refQueue));
  }

  // ---- 顶层入口（规则 1）：log/dns/route/experimental 递归可达收集（规则 2）----
  for (final entry in const ['log', 'dns', 'route', 'experimental']) {
    final ref = _asMap(top[entry])[r'$ref'] as String?;
    if (ref != null) {
      final name = _refName(ref);
      if (defs.containsKey(name)) refQueue.add(name);
    }
  }

  // ---- 队列消费：plain 类逐个生成，字段 $ref 目标继续入队（不重复）----
  final seen = <String>{};
  for (var i = 0; i < refQueue.length; i++) {
    final name = refQueue[i];
    if (_skipDefNames.contains(name) || !seen.add(name)) continue;
    classes.add(_flattenClass(name, defs, refQueue));
  }

  return Ir(classes: classes, mixins: mixins);
}

// ---------------------------------------------------------------------------
// 分支展开与合并（规则 4/5/6）
// ---------------------------------------------------------------------------

/// 一个展开后的分支：字段节点集 + required 集（自身与 allOf 子块拼合结果）
class _BranchFields {
  const _BranchFields(this.props, this.required);
  final Map<String, Map<String, dynamic>> props;
  final Set<String> required;
}

/// 同组分支合并结果
class _Merged {
  const _Merged(this.props, this.baseTypes, this.required);
  final Map<String, Map<String, dynamic>> props;
  final Map<String, String> baseTypes; // jsonName -> 基类型（不含可空性）
  final Set<String> required;
}

/// 递归展开 oneOf/anyOf 分支列表（snell 形状：分支无 properties/allOf 但含
/// oneOf/anyOf 时递归展开子分支）；无字段可贡献的分支被丢弃
List<_BranchFields> _expandBranches(
    List<Object?> branches, Map<String, dynamic> defs, Set<String> resolving) {
  final out = <_BranchFields>[];
  for (final raw in branches) {
    final node = _asMap(raw);
    final nested = [..._asList(node['oneOf']), ..._asList(node['anyOf'])];
    final hasOwn = node['properties'] != null || node['allOf'] != null;
    if (!hasOwn && nested.isNotEmpty) {
      out.addAll(_expandBranches(nested, defs, resolving));
      continue;
    }
    final bf = _absorbBranch(node, defs, resolving);
    if (bf != null) out.add(bf);
  }
  return out;
}

/// 拼合单个分支的字段：自身 properties/required + allOf 子块
///（内联子块直接并入；$ref 子块解析目标 def 后并入）
_BranchFields? _absorbBranch(
    Map<String, dynamic> node, Map<String, dynamic> defs, Set<String> resolving) {
  final props = <String, Map<String, dynamic>>{};
  final required = <String>{};
  _absorbObject(node, props, required, defs, resolving);
  if (props.isEmpty) return null;
  return _BranchFields(props, required);
}

void _absorbObject(Map<String, dynamic> node, Map<String, Map<String, dynamic>> props,
    Set<String> required, Map<String, dynamic> defs, Set<String> resolving) {
  _asMap(node['properties']).forEach((k, v) => props[k] = _asMap(v));
  required.addAll(_asList(node['required']).whereType<String>());
  for (final rawSub in _asList(node['allOf'])) {
    final sub = _asMap(rawSub);
    final ref = sub[r'$ref'] as String?;
    if (ref == null) {
      _absorbObject(sub, props, required, defs, resolving);
    } else {
      _absorbDefRef(_refName(ref), props, required, defs, resolving);
    }
  }
}

/// allOf 的 $ref 子块：目标为 object def 时直接并入字段；
/// 目标为 oneOf/anyOf 根 def（如 RuleAction）时展开后取并集，
/// required 取交集（OR 语义下仅全分支必填的字段保持必填）
void _absorbDefRef(String name, Map<String, Map<String, dynamic>> props,
    Set<String> required, Map<String, dynamic> defs, Set<String> resolving) {
  if (!defs.containsKey(name) || !resolving.add(name)) return;
  final def = _asMap(defs[name]);
  final nested = [..._asList(def['oneOf']), ..._asList(def['anyOf'])];
  if (nested.isEmpty) {
    _absorbObject(def, props, required, defs, resolving);
  } else {
    final branches = _expandBranches(nested, defs, resolving);
    for (final b in branches) {
      b.props.forEach((k, v) => props.putIfAbsent(k, () => v));
    }
    if (branches.isNotEmpty) {
      var inter = branches.first.required.toSet();
      for (var i = 1; i < branches.length; i++) {
        inter = inter.intersection(branches[i].required);
      }
      required.addAll(inter);
    }
  }
  resolving.remove(name);
}

/// 同组分支合并（规则 5）：字段并集、required 交集。
/// strict = true（同判别值合并）：同 jsonName 字段基类型不同抛错；
/// strict = false（无判别拍平）：类型冲突泛化为 Object（宽松形态）
_Merged _mergeBranches(List<_BranchFields> branches, Map<String, dynamic> defs,
    {required bool strict}) {
  final props = <String, Map<String, dynamic>>{};
  final baseTypes = <String, String>{};
  var required =
      branches.isNotEmpty ? branches.first.required.toSet() : <String>{};
  for (var i = 0; i < branches.length; i++) {
    final b = branches[i];
    if (i > 0) required = required.intersection(b.required);
    b.props.forEach((name, node) {
      final t = _mapType(node, defs, isListItem: false);
      final prev = baseTypes[name];
      if (prev == null) {
        baseTypes[name] = t;
        props[name] = node;
      } else if (prev != t) {
        if (strict) {
          throw SchemaConflictException('同判别值分支的字段「$name」类型冲突：$prev / $t');
        }
        baseTypes[name] = 'Object';
      }
    });
  }
  return _Merged(props, baseTypes, required);
}

/// def 拍平为合并字段（规则 6）：object def 取自身（含 allOf 拼合）；
/// oneOf/anyOf 根 def 展开全部分支后并集（required 交集）
_Merged _flattenDef(String name, Map<String, dynamic> defs) {
  final def = _asMap(defs[name]);
  final nested = [..._asList(def['oneOf']), ..._asList(def['anyOf'])];
  final resolving = <String>{name};
  final branches = nested.isEmpty
      ? ([_absorbBranch(def, defs, resolving)]..removeWhere((b) => b == null))
          .cast<_BranchFields>()
      : _expandBranches(nested, defs, resolving);
  return _mergeBranches(branches, defs, strict: false);
}

/// 拍平产物 -> kind: plain 的 ClassSpec，并把字段 $ref 目标入队
ClassSpec _flattenClass(
    String name, Map<String, dynamic> defs, List<String> refQueue) {
  final merged = _flattenDef(name, defs);
  _collectRefTargets(merged.props, defs, refQueue);
  return ClassSpec(
    className: name,
    typeName: null,
    ownFields: _toFieldSpecs(merged, forceNullable: false),
    mixins: const [],
    kind: 'plain',
  );
}

// ---------------------------------------------------------------------------
// 判别收集（规则 3/4/5/10）
// ---------------------------------------------------------------------------

/// oneOf 根 def 的分支按 type const 分组；def 缺失返回空表。
/// 无 type const 的分支不属于判别收集（Rule 形状走拍平路径），跳过
Map<String, List<_BranchFields>> _groupedByType(
    Map<String, dynamic> defs, String defName) {
  final def = _asMap(defs[defName]);
  final branches = _expandBranches(
      [..._asList(def['oneOf']), ..._asList(def['anyOf'])], defs, <String>{defName});
  final groups = <String, List<_BranchFields>>{};
  for (final b in branches) {
    final disc = _asMap(b.props['type'])['const'] as String?;
    if (disc == null) continue;
    groups.putIfAbsent(disc, () => []).add(b);
  }
  return groups;
}

void _validateWhitelist(Set<String> whitelist,
    Map<String, List<_BranchFields>> groups, String label) {
  for (final type in whitelist) {
    if (!groups.containsKey(type)) {
      throw SchemaConflictException('$label白名单类型「$type」不在 schema 中');
    }
  }
}

/// 判别类生成：白名单（null 为全量）过滤 -> 合并 -> 去掉 type 字段 ->
/// 依序吸收 mixin 字段（仅记录实际吸收了字段的 mixin 名）。
/// forceTagRequired：tag 强制必填非空（规则 9，出站/入站类；DNSServer 类跟随 schema）
List<ClassSpec> _discriminatedClasses(
    Map<String, List<_BranchFields>> groups,
    Set<String>? whitelist,
    String kind,
    String Function(String type) classNameOf,
    Map<String, dynamic> defs,
    List<String> mixinOrder,
    Map<String, Set<String>> mixinKeys,
    List<String> refQueue,
    {required bool forceTagRequired}) {
  final out = <ClassSpec>[];
  groups.forEach((type, branches) {
    if (whitelist != null && !whitelist.contains(type)) return;
    final merged = _mergeBranches(branches, defs, strict: true);
    _collectRefTargets(merged.props, defs, refQueue);

    final absorbed = <String>[];
    for (final m in mixinOrder) {
      if (mixinKeys[m]!.any((k) => k != 'type' && merged.props.containsKey(k))) {
        absorbed.add(m);
      }
    }
    final removed = <String>{'type', for (final m in absorbed) ...mixinKeys[m]!};
    final fields = <FieldSpec>[];
    merged.props.forEach((name, _) {
      if (removed.contains(name)) return; // type 不进字段；mixin 字段已吸收
      final forceRequired = forceTagRequired && name == 'tag';
      fields.add(_fieldSpec(merged, name,
          forceNullable: false, forceRequired: forceRequired));
    });
    out.add(ClassSpec(
      className: classNameOf(type),
      typeName: type,
      ownFields: fields,
      mixins: absorbed,
      kind: kind,
    ));
  });
  return out;
}

// ---------------------------------------------------------------------------
// 类型映射（规则 7/8）
// ---------------------------------------------------------------------------

List<FieldSpec> _toFieldSpecs(_Merged merged, {required bool forceNullable}) {
  return [
    for (final name in merged.props.keys)
      _fieldSpec(merged, name, forceNullable: forceNullable),
  ];
}

FieldSpec _fieldSpec(_Merged merged, String name,
    {required bool forceNullable, bool forceRequired = false}) {
  final base = merged.baseTypes[name]!;
  final req = forceRequired || (!forceNullable && merged.required.contains(name));
  return FieldSpec(
    jsonName: name,
    dartName: lowerCamel(name),
    dartType: req ? base : _nullable(base),
    required: req,
  );
}

String _nullable(String t) => t.endsWith('?') ? t : '$t?';

/// 字段级类型映射（规则 8 映射表），返回基类型（不含可空性）
String _mapType(Map<String, dynamic> node, Map<String, dynamic> defs,
    {required bool isListItem}) {
  final ref = node[r'$ref'] as String?;
  if (ref != null) return _mapRef(ref, defs);
  if (node.containsKey('const')) {
    // const 值字段（规则 7）：类型取 const 标量的 Dart 类型
    final v = node['const'];
    if (v is String) return 'String';
    if (v is int) return 'int';
    if (v is double) return 'double';
    if (v is bool) return 'bool';
    throw SchemaConflictException('const 值非标量，无法映射（${_pos(isListItem)}）');
  }
  switch (node['type'] as String?) {
    case 'string':
      return 'String'; // 含 enum：枚举字符串仍映射 String
    case 'integer':
      return 'int';
    case 'number':
      return 'double';
    case 'boolean':
      return 'bool';
    case 'object':
      return 'Object'; // 裸 object（无 $ref）：不透明 JSON 对象
    case 'array':
      final items = _asMap(node['items']);
      if (items.isEmpty) return 'List<Object>';
      return 'List<${_mapType(items, defs, isListItem: true)}>';
  }
  if (node.containsKey('anyOf') || node.containsKey('oneOf')) {
    return 'Object'; // 字段级二义（network / routing_mark / udp_over_tcp 等）
  }
  throw SchemaConflictException(
      '未知 schema 形状（${_pos(isListItem)}）：${node.keys.toList()}');
}

/// $ref 目标 def 的类型映射：
/// - Duration -> String（Go 时长字符串原样保留）
/// - object def（含 properties 或 type=object）-> 类名（def 名）
/// - oneOf/anyOf 且全部分支为 object 形状（Rule/DNSServer/V2RayTransport 等）-> 类名
/// - 其余（标量根 / 标量或对象混合 union，如 IPAddress / DomainResolver）-> Object
String _mapRef(String ref, Map<String, dynamic> defs) {
  final name = _refName(ref);
  if (name == 'Duration') return 'String';
  if (!defs.containsKey(name)) {
    throw SchemaConflictException('\$ref「$ref」指向的 def 不在 schema 中');
  }
  final def = _asMap(defs[name]);
  if (_isObjectShaped(def) || _allBranchesObject(def)) return name;
  return 'Object';
}

bool _isObjectShaped(Map<String, dynamic> def) =>
    def['properties'] != null || def['type'] == 'object';

bool _allBranchesObject(Map<String, dynamic> def) {
  final branches = [..._asList(def['oneOf']), ..._asList(def['anyOf'])];
  if (branches.isEmpty) return false;
  return branches.every((b) => _isObjectShaped(_asMap(b)));
}

/// 从字段节点收集应作为 plain 类收集的 $ref 目标：
/// 仅 object 形状 / 全 object 分支的 def；数组看 items；
/// 字段级 union（anyOf/oneOf）不深入（其字段整体映射为 Object）
void _collectRefTargets(Map<String, Map<String, dynamic>> props,
    Map<String, dynamic> defs, List<String> out) {
  void walk(Map<String, dynamic> node) {
    final ref = node[r'$ref'] as String?;
    if (ref != null) {
      final name = _refName(ref);
      if (!defs.containsKey(name)) return;
      final def = _asMap(defs[name]);
      if (_isObjectShaped(def) || _allBranchesObject(def)) out.add(name);
      return;
    }
    final items = _asMap(node['items']);
    if (items.isNotEmpty) walk(items);
  }

  props.forEach((_, node) => walk(node));
}

// ---------------------------------------------------------------------------
// 基础工具
// ---------------------------------------------------------------------------

/// 解析 `#/$defs/X` 形式的 ref 为 def 名
String _refName(String ref) {
  final m = RegExp(r'^#/\$defs/(.+)$').firstMatch(ref);
  if (m == null) {
    throw SchemaConflictException('不支持的 \$ref 形式：「$ref」');
  }
  return m.group(1)!;
}

String _pos(bool isListItem) => isListItem ? '数组 items 位置' : '字段位置';

Map<String, dynamic> _asMap(Object? v) => (v as Map?)?.cast<String, dynamic>() ?? {};

List<Object?> _asList(Object? v) => v as List? ?? const [];
