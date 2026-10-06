// tool/src/dart_emitter.dart —— Dart 输出器：IR -> Dart 源码文本
// 纯 Dart，禁止 Flutter import；只做字符串组装，不写盘（写盘由 gen_models.dart 接线）。
//
// 与任务简报模板的三处语言级修正（均经最小工程实证，否则生成物无法通过
// build_runner / analyze，Task 5/6 的编译与 round-trip 前提不成立）：
//  1. sealed 类只允许同库（同 library）继承——判别族采用「库根 + part」布局：
//     outbound/outbound.dart 为库根（sealed 基类 + 全部 part 声明 + 汇总 import），
//     子类与 Unknown 是 part 文件（仅 part of 声明，无自身 import/part）。
//     简报模板的跨库 import 写法会触发 sealed 同库限制的编译错误。
//  2. 基类声明抽象 `Map<String, dynamic> toJson();`——json_serializable 才能生成
//     `List<Outbound>` / `List<DNSServer>` 等字段的序列化（e.toJson()），
//     基类 fromJson 工厂同理支撑反序列化；子类 toJson 覆写为
//     {'type': typeName, ..._$XToJson(this)}，保证 round-trip 不丢判别键。
//  3. @JsonSerializable 统一 explicitToJson: true, includeIfNull: false——
//     缺省可空字段不输出 null 键，toJson 与原配置深度相等（Task 6 的前提）。
import 'names.dart';
import 'schema_ir.dart';

/// 全部生成文件的首行头注释
const String _header = '// 本文件由 tool/gen_models.dart 生成，勿手改。';

/// 判别族描述：目录 / 基类名 / Unknown 类名 / 注册表常量名 / 文档文案
class _FamilySpec {
  const _FamilySpec({
    required this.base,
    required this.dir,
    required this.unknown,
    required this.registry,
    required this.classDoc,
    required this.unknownDoc,
    required this.registryDoc,
  });

  final String base;
  final String dir;
  final String unknown;
  final String registry;
  final String classDoc;
  final String unknownDoc;
  final String registryDoc;

  /// 库根文件（sealed 基类所在），如 outbound/outbound.dart
  String get baseFile => '$dir/${fileNameFor(base)}';
}

const _outboundFamily = _FamilySpec(
  base: 'Outbound',
  dir: 'outbound',
  unknown: 'UnknownOutbound',
  registry: 'kOutboundTypeNames',
  classDoc: '出站配置，按 type 判别的密封类层级。',
  unknownDoc: '未建模出站类型：持有原始 JSON 原样透传（保真读写）。',
  registryDoc: '白名单内全部出站类型名（对齐测试的数据源）。',
);

const _inboundFamily = _FamilySpec(
  base: 'Inbound',
  dir: 'inbound',
  unknown: 'UnknownInbound',
  registry: 'kInboundTypeNames',
  classDoc: '入站配置，按 type 判别的密封类层级。',
  unknownDoc: '未建模入站类型：持有原始 JSON 原样透传（保真读写）。',
  registryDoc: '白名单内全部入站类型名（对齐测试的数据源）。',
);

const _dnsServerFamily = _FamilySpec(
  base: 'DNSServer',
  dir: 'dns_server',
  unknown: 'UnknownDnsServer',
  registry: 'kDnsServerTypeNames',
  classDoc: 'DNS 服务器配置，按 type 判别的密封类层级。',
  unknownDoc: '未建模 DNS 服务器类型：持有原始 JSON 原样透传（保真读写）。',
  registryDoc: '全部 DNS 服务器类型名（schema 全量收集，无白名单）。',
);

/// 顶层段固定清单：(json 键, 候选类名表, 是否可空)。
/// 简报模板中的 Dns/Log 是示意名，真实 schema 的 def 名为 DNS/LogOptions，
/// 故按候选表解析；IR 中不存在的段（迷你 fixture 无 route 等）整体省略，
/// _knownKeys 随之收缩，inbounds/outbounds 仅在对应判别族存在时出现。
const List<(String, List<String>, bool)> _topSections = [
  ('log', ['LogOptions', 'Log'], true),
  ('dns', ['DNS', 'Dns'], false),
  ('inbounds', ['Inbound'], false),
  ('outbounds', ['Outbound'], false),
  ('route', ['RouteOptions'], false),
  ('experimental', ['ExperimentalOptions'], true),
];

/// IR -> Dart 源码文本集合（相对路径 -> 文件内容），不写盘。
/// 路径一律用 `/` 分隔（Task 4 写盘时按平台处理分隔符）。
Map<String, String> emitDart(Ir ir) {
  final files = <String, String>{};

  // ---- 分类：outbound / inbound / DNSServer 族（kind='plain' 且带 typeName）/ 普通类 ----
  _FamilySpec? familyOf(ClassSpec c) => switch (c.kind) {
    'outbound' => _outboundFamily,
    'inbound' => _inboundFamily,
    _ when _isDnsServerFamily(c) => _dnsServerFamily,
    _ => null,
  };

  final families = const [_outboundFamily, _inboundFamily, _dnsServerFamily];

  // ---- 类名 -> 文件路径索引（import 计算 + 顶层段解析）----
  final pathOf = <String, String>{};
  for (final c in ir.classes) {
    final fam = familyOf(c);
    pathOf[c.className] = fam == null
        ? fileNameFor(c.className)
        : '${fam.dir}/${fileNameFor(c.className)}';
  }
  for (final m in ir.mixins.keys) {
    pathOf[m] = 'shared/${fileNameFor(m)}';
  }
  for (final fam in families) {
    if (ir.classes.any((c) => familyOf(c) == fam)) {
      pathOf[fam.base] = fam.baseFile;
    }
  }

  // ---- mixin 文件（独立库：无 part、无 @JsonSerializable，仅字段带 @JsonKey）----
  for (final entry in ir.mixins.entries) {
    final file = 'shared/${fileNameFor(entry.key)}';
    files[file] = _emitMixin(entry.key, entry.value, file, pathOf);
  }

  // ---- 判别族：库根（sealed 基类 + part 声明）+ 子类/Unknown part 文件 ----
  for (final fam in families) {
    // 按类型名字母序（switch 分支与 part 声明同序，输出确定性）
    final subs = ir.classes.where((c) => familyOf(c) == fam).toList()
      ..sort((a, b) => a.typeName!.compareTo(b.typeName!));
    if (subs.isEmpty) continue;
    files[fam.baseFile] = _emitFamilyRoot(fam, subs, pathOf);
    for (final s in subs) {
      files['${fam.dir}/${fileNameFor(s.className)}'] = _emitSubclassPart(
        s,
        fam,
      );
    }
    files['${fam.dir}/${fileNameFor(fam.unknown)}'] = _emitUnknownPart(fam);
  }

  // ---- 普通类（根目录，独立库自带 part）----
  for (final c in ir.classes.where((c) => familyOf(c) == null)) {
    files[fileNameFor(c.className)] = _emitPlainClass(c, pathOf);
  }

  // ---- 顶层 SingBox（未知段透传）----
  files['sing_box.dart'] = _emitSingBox(pathOf);

  // ---- index：只导出库根（part 文件不可被 export，随库根一并导出）----
  final baseFileOfDir = <String, String>{
    for (final fam in families) fam.dir: fam.baseFile,
  };
  final partFiles = <String>{};
  for (final key in files.keys) {
    final slash = key.indexOf('/');
    if (slash <= 0) continue;
    final base = baseFileOfDir[key.substring(0, slash)];
    if (base != null && key != base) partFiles.add(key);
  }
  final roots =
      files.keys
          .where((k) => k != 'index.dart' && !partFiles.contains(k))
          .toList()
        ..sort();
  files['index.dart'] = _emitIndex(roots);

  return files;
}

/// DNSServer 判别族识别：IR 中 kind='plain'、typeName 非 null 且类名以 DNSServer 结尾
bool _isDnsServerFamily(ClassSpec c) =>
    c.kind == 'plain' &&
    c.typeName != null &&
    c.className.endsWith('DNSServer');

// ---------------------------------------------------------------------------
// mixin 文件
// ---------------------------------------------------------------------------

String _emitMixin(
  String name,
  List<FieldSpec> fields,
  String selfPath,
  Map<String, String> pathOf,
) {
  final imports = _collectImports(
    fields.map((f) => f.dartType),
    selfPath,
    pathOf,
  );
  final b = StringBuffer();
  b.writeln(_header);
  b.writeln("import 'package:json_annotation/json_annotation.dart';");
  b.writeln();
  _writeImports(b, imports);
  b.writeln(_mixinDoc(name));
  b.writeln('mixin $name {');
  for (final f in fields) {
    if (f.jsonName != f.dartName) {
      b.writeln("  @JsonKey(name: '${f.jsonName}')");
    }
    b.writeln('  ${f.dartType} ${f.dartName};');
  }
  b.writeln('}');
  return b.toString();
}

String _mixinDoc(String name) => switch (name) {
  'DialerFields' => '/// 拨号共享字段（对应官方 DialerOptions），字段一律可空。',
  'ListenFields' => '/// 监听共享字段（白名单入站分支共有属性），字段一律可空。',
  _ => '/// 共享字段块（$name），字段一律可空。',
};

// ---------------------------------------------------------------------------
// 判别族：库根 / 子类 part / Unknown part
// ---------------------------------------------------------------------------

String _emitFamilyRoot(
  _FamilySpec fam,
  List<ClassSpec> subs,
  Map<String, String> pathOf,
) {
  // 库根汇总 import：json_annotation + 子类混入的 mixin + 子类字段引用的类型
  final imports = <String>{};
  for (final s in subs) {
    for (final m in s.mixins) {
      imports.add(_importFor(fam.baseFile, pathOf[m]!));
    }
    imports.addAll(
      _collectImports(s.ownFields.map((f) => f.dartType), fam.baseFile, pathOf),
    );
  }

  final b = StringBuffer();
  b.writeln(_header);
  b.writeln("import 'package:json_annotation/json_annotation.dart';");
  b.writeln();
  _writeImports(b, imports);
  for (final s in subs) {
    b.writeln("part '${fileNameFor(s.className)}';");
  }
  b.writeln("part '${fileNameFor(fam.unknown)}';");
  b.writeln();
  b.writeln("part '${_stripExt(fileNameFor(fam.base))}.g.dart';");
  b.writeln();
  b.writeln('/// ${fam.classDoc}');
  b.writeln('sealed class ${fam.base} {');
  b.writeln('  const ${fam.base}();');
  b.writeln();
  b.writeln('  String get tag;');
  b.writeln('  String get type;');
  b.writeln();
  b.writeln('  /// 子类输出须带 type 判别键（round-trip 保真的关键）。');
  b.writeln('  Map<String, dynamic> toJson();');
  b.writeln();
  b.writeln('  /// 按 type 判别反序列化；未知类型进 [${fam.unknown}] 透传。');
  b.writeln('  factory ${fam.base}.fromJson(Map<String, dynamic> json) {');
  b.writeln("    final type = json['type'] as String?;");
  b.writeln('    return switch (type) {');
  for (final s in subs) {
    b.writeln("      '${s.typeName}' => ${s.className}.fromJson(json),");
  }
  b.writeln('      _ => ${fam.unknown}.fromJson(json),');
  b.writeln('    };');
  b.writeln('  }');
  b.writeln('}');
  b.writeln();
  b.writeln('/// ${fam.registryDoc}');
  b.writeln(
    'const Set<String> ${fam.registry} = ${_setLiteral(subs.map((s) => s.typeName!))};',
  );
  return b.toString();
}

String _emitSubclassPart(ClassSpec spec, _FamilySpec fam) {
  final b = StringBuffer();
  b.writeln(_header);
  b.writeln("part of '${fileNameFor(fam.base)}';");
  b.writeln();
  b.writeln('@JsonSerializable(explicitToJson: true, includeIfNull: false)');
  final mixins = spec.mixins.isEmpty ? '' : ' with ${spec.mixins.join(', ')}';
  b.writeln('class ${spec.className} extends ${fam.base}$mixins {');
  b.writeln("  static const typeName = '${spec.typeName}';");
  b.writeln();
  for (final f in spec.ownFields) {
    // 无参 @JsonKey() 与不写等价（公开字段默认序列化），一律不生成；
    // tag 仅需 @override（覆写基类抽象 getter）
    if (f.jsonName == 'tag') {
      b.writeln('  @override');
    } else if (f.jsonName != f.dartName) {
      b.writeln("  @JsonKey(name: '${f.jsonName}')");
    }
    b.writeln('  ${f.dartType} ${f.dartName};');
  }
  _writeConstructor(b, spec);
  b.writeln();
  b.writeln('  @override');
  b.writeln('  String get type => typeName;');
  b.writeln();
  b.writeln(
    '  factory ${spec.className}.fromJson(Map<String, dynamic> json) =>',
  );
  b.writeln('      _\$${spec.className}FromJson(json);');
  b.writeln();
  b.writeln('  @override');
  b.writeln('  Map<String, dynamic> toJson() =>');
  b.writeln("      {'type': typeName, ..._\$${spec.className}ToJson(this)};");
  b.writeln('}');
  return b.toString();
}

String _emitUnknownPart(_FamilySpec fam) {
  final b = StringBuffer();
  b.writeln(_header);
  b.writeln("part of '${fileNameFor(fam.base)}';");
  b.writeln();
  b.writeln('/// ${fam.unknownDoc}');
  b.writeln('class ${fam.unknown} extends ${fam.base} {');
  b.writeln('  final Map<String, dynamic> raw;');
  b.writeln('  ${fam.unknown}(this.raw);');
  b.writeln();
  b.writeln('  @override');
  b.writeln("  String get tag => raw['tag'] as String? ?? '';");
  b.writeln('  @override');
  b.writeln("  String get type => raw['type'] as String? ?? '';");
  b.writeln();
  b.writeln('  factory ${fam.unknown}.fromJson(Map<String, dynamic> json) =>');
  b.writeln('      ${fam.unknown}(Map<String, dynamic>.from(json));');
  b.writeln();
  b.writeln('  @override');
  b.writeln(
    '  Map<String, dynamic> toJson() => Map<String, dynamic>.from(raw);',
  );
  b.writeln('}');
  return b.toString();
}

// ---------------------------------------------------------------------------
// 普通类（根目录）
// ---------------------------------------------------------------------------

String _emitPlainClass(ClassSpec spec, Map<String, String> pathOf) {
  final selfPath = fileNameFor(spec.className);
  final imports = _collectImports(
    spec.ownFields.map((f) => f.dartType),
    selfPath,
    pathOf,
  );
  final b = StringBuffer();
  b.writeln(_header);
  b.writeln("import 'package:json_annotation/json_annotation.dart';");
  b.writeln();
  _writeImports(b, imports);
  b.writeln("part '${_stripExt(selfPath)}.g.dart';");
  b.writeln();
  b.writeln('@JsonSerializable(explicitToJson: true, includeIfNull: false)');
  b.writeln('class ${spec.className} {');
  for (final f in spec.ownFields) {
    if (f.jsonName != f.dartName) {
      b.writeln("  @JsonKey(name: '${f.jsonName}')");
    }
    b.writeln('  ${f.dartType} ${f.dartName};');
  }
  _writeConstructor(b, spec);
  b.writeln();
  b.writeln(
    '  factory ${spec.className}.fromJson(Map<String, dynamic> json) =>',
  );
  b.writeln('      _\$${spec.className}FromJson(json);');
  b.writeln();
  b.writeln(
    '  Map<String, dynamic> toJson() => _\$${spec.className}ToJson(this);',
  );
  b.writeln('}');
  return b.toString();
}

/// 构造函数：仅含 required 字段；可空字段与 mixin 字段不进构造（默认 null）
void _writeConstructor(StringBuffer b, ClassSpec spec) {
  final requiredFields = spec.ownFields.where((f) => f.required).toList();
  final hasOmitted =
      spec.ownFields.any((f) => !f.required) || spec.mixins.isNotEmpty;
  b.writeln();
  if (requiredFields.isEmpty) {
    b.writeln('  ${spec.className}();');
    return;
  }
  b.writeln('  ${spec.className}({');
  for (final f in requiredFields) {
    b.writeln('    required this.${f.dartName},');
  }
  if (hasOmitted) {
    b.writeln('    // 可空字段省略（默认 null）');
  }
  b.writeln('  });');
}

// ---------------------------------------------------------------------------
// 顶层 SingBox（未建模段原样透传）
// ---------------------------------------------------------------------------

String _emitSingBox(Map<String, String> pathOf) {
  final sections = <({String key, String type, bool nullable})>[];
  for (final (key, candidates, nullable) in _topSections) {
    String? matched;
    for (final name in candidates) {
      if (pathOf.containsKey(name)) {
        matched = name;
        break;
      }
    }
    if (matched == null) continue; // IR 缺该段则整体省略
    final isList = key == 'inbounds' || key == 'outbounds';
    sections.add((
      key: key,
      type: isList ? 'List<$matched>' : matched,
      nullable: nullable,
    ));
  }

  final imports = _collectImports(
    sections.map((s) => s.type),
    'sing_box.dart',
    pathOf,
  );
  final b = StringBuffer();
  b.writeln(_header);
  b.writeln("import 'package:json_annotation/json_annotation.dart';");
  b.writeln();
  _writeImports(b, imports);
  b.writeln("part 'sing_box.g.dart';");
  b.writeln();
  b.writeln('@JsonSerializable(explicitToJson: true, includeIfNull: false)');
  b.writeln('class SingBox {');
  b.writeln(
    "  static const _knownKeys = {${sections.map((s) => "'${s.key}'").join(', ')}};",
  );
  b.writeln();
  for (final s in sections) {
    b.writeln('  ${s.nullable ? '${s.type}?' : s.type} ${s.key};');
  }
  b.writeln();
  b.writeln('  /// 未建模顶层段（ntp 等）原样透传：读入收存、输出合并。');
  b.writeln('  @JsonKey(includeFromJson: false, includeToJson: false)');
  b.writeln('  final Map<String, dynamic> unknownSections = {};');
  b.writeln();
  b.writeln('  SingBox({');
  for (final s in sections) {
    b.writeln(
      s.nullable ? '    this.${s.key},' : '    required this.${s.key},',
    );
  }
  b.writeln('  });');
  b.writeln();
  b.writeln('  factory SingBox.fromJson(Map<String, dynamic> json) {');
  b.writeln('    final result = _\$SingBoxFromJson(json);');
  b.writeln('    json.forEach((key, value) {');
  b.writeln(
    '      if (!_knownKeys.contains(key)) result.unknownSections[key] = value;',
  );
  b.writeln('    });');
  b.writeln('    return result;');
  b.writeln('  }');
  b.writeln();
  b.writeln('  Map<String, dynamic> toJson() {');
  b.writeln('    final result = _\$SingBoxToJson(this);');
  b.writeln('    result.addAll(unknownSections);');
  b.writeln('    return result;');
  b.writeln('  }');
  b.writeln('}');
  return b.toString();
}

// ---------------------------------------------------------------------------
// index 汇总
// ---------------------------------------------------------------------------

String _emitIndex(List<String> libraryRoots) {
  final b = StringBuffer();
  b.writeln(_header);
  b.writeln();
  b.writeln('// 汇总导出全部生成库（判别族的 part 文件随库根一并导出，按路径排序）。');
  for (final p in libraryRoots) {
    b.writeln("export '$p';");
  }
  return b.toString();
}

// ---------------------------------------------------------------------------
// import 计算与基础工具
// ---------------------------------------------------------------------------

/// 从字段类型串提取引用到的生成类，换算为相对 import 路径（去重集合）
Set<String> _collectImports(
  Iterable<String> dartTypes,
  String selfPath,
  Map<String, String> pathOf,
) {
  final imports = <String>{};
  for (final type in dartTypes) {
    for (final m in RegExp(r'[A-Za-z_][A-Za-z0-9_]*').allMatches(type)) {
      final target = pathOf[m.group(0)!];
      if (target != null && target != selfPath) {
        imports.add(_importFor(selfPath, target));
      }
    }
  }
  return imports;
}

/// 计算 fromFile -> toFile 的相对 import：同目录剩文件名，跨目录 `../` 前缀
String _importFor(String fromFile, String toFile) {
  final fromDir = fromFile.split('/')..removeLast();
  final toParts = toFile.split('/');
  final toName = toParts.removeLast();
  var common = 0;
  while (common < fromDir.length &&
      common < toParts.length &&
      fromDir[common] == toParts[common]) {
    common++;
  }
  return [
    for (var i = common; i < fromDir.length; i++) '..',
    ...toParts.sublist(common),
    toName,
  ].join('/');
}

/// 写入排序后的相对 import 块（空集合不输出）
void _writeImports(StringBuffer b, Set<String> imports) {
  if (imports.isEmpty) return;
  final sorted = imports.toList()..sort();
  for (final i in sorted) {
    b.writeln("import '$i';");
  }
  b.writeln();
}

/// Set 字面量：短集合单行，长集合逐行（均排序，保证输出确定性）
String _setLiteral(Iterable<String> values) {
  final sorted = values.toList()..sort();
  if (sorted.length <= 8) {
    return '{${sorted.map((v) => "'$v'").join(', ')}}';
  }
  return '{\n${sorted.map((v) => "  '$v',").join('\n')}\n}';
}

String _stripExt(String fileName) =>
    fileName.replaceFirst(RegExp(r'\.dart$'), '');
