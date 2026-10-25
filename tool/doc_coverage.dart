// tool/doc_coverage.dart —— dartdoc 覆盖率统计：解析 lib 下公共 API 与注释情况
// 用法：dart run tool/doc_coverage.dart [--verbose]
// 口径说明：
//  - 排除 *.g.dart / *.freezed.dart（build_runner 产物，pana 同样排除）
//  - gen/ 生成模型计入统计（pana 按文件名/内容识别生成物，此处保守全计入）
//  - 统计单元：顶层函数/变量/typedef 与类（class/mixin/enum/extension）及其
//    公共成员（字段/方法/getter/setter/构造器/枚举值）；仅认声明上直接附着
//    的 /// 注释，不追踪跨文件继承（比 dartdoc 的继承口径略保守）
//  - --verbose 按文件输出未注释声明清单
import 'dart:io';

import 'package:analyzer/dart/analysis/features.dart';
import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:analyzer/dart/ast/ast.dart';

void main(List<String> args) {
  final verbose = args.contains('--verbose');
  final libDir = Directory('lib');
  if (!libDir.existsSync()) {
    stderr.writeln('未找到 lib 目录，请在包根目录运行。');
    exitCode = 1;
    return;
  }

  var total = 0, documented = 0;
  final fileStats =
      <({String file, int total, int documented, List<String> missing})>[];

  final files = libDir
      .listSync(recursive: true)
      .whereType<File>()
      .where((f) => f.path.endsWith('.dart'))
      .where((f) => !f.path.endsWith('.g.dart'))
      .where((f) => !f.path.endsWith('.freezed.dart'))
      .toList()
    ..sort((a, b) => a.path.compareTo(b.path));

  for (final file in files) {
    // 单文件解析无需精确语言版本，按最新语言特性解析即可（更省去 SDK 分析）
    final unit = parseFile(
      path: file.path,
      featureSet: FeatureSet.latestLanguageVersion(),
      throwIfDiagnostics: false, // 统计注释无需语法诊断
    ).unit;
    var fileTotal = 0, fileDoc = 0;
    final missing = <String>[];

    // 计数单个声明：私有名（_ 开头）跳过；有 /// 文档注释才算已注释
    void count(AnnotatedNode? node, String kind, String name) {
      if (node == null || name.startsWith('_')) return;
      fileTotal++;
      if (node.documentationComment != null) {
        fileDoc++;
      } else {
        missing.add('$kind $name');
      }
    }

    for (final decl in unit.declarations) {
      switch (decl) {
        case ClassDeclaration():
          count(decl, 'class', decl.namePart.typeName.lexeme);
          _countMembers(decl.body.members, count);
        case MixinDeclaration():
          count(decl, 'mixin', decl.name.lexeme);
          _countMembers(decl.body.members, count);
        case EnumDeclaration():
          count(decl, 'enum', decl.namePart.typeName.lexeme);
          for (final c in decl.body.constants) {
            count(c, 'enum-value', c.name.lexeme);
          }
          _countMembers(decl.body.members, count);
        case ExtensionDeclaration():
          // analyzer 14 起 extension 成员移入 body
          _countMembers(decl.body.members, count);
        case FunctionDeclaration():
          count(
            decl,
            decl.functionExpression.parameters == null ? 'variable' : 'function',
            decl.name.lexeme,
          );
        case TopLevelVariableDeclaration():
          for (final v in decl.variables.variables) {
            count(decl, 'variable', v.name.lexeme);
          }
        case TypeAlias():
          count(decl, 'typedef', decl.name.lexeme);
      }
    }

    total += fileTotal;
    documented += fileDoc;
    if (missing.isNotEmpty) {
      fileStats.add(
        (file: file.path, total: fileTotal, documented: fileDoc, missing: missing),
      );
    }
  }

  final pct = total == 0 ? 0.0 : documented / total * 100;
  stdout
    ..writeln('公共 API 总数: $total')
    ..writeln('已注释: $documented (${pct.toStringAsFixed(1)}%)')
    ..writeln('目标 >= 20%: ${pct >= 20 ? '已达标' : '未达标'}');
  if (verbose) {
    stdout.writeln('---- 未注释清单（按文件） ----');
    for (final s in fileStats) {
      stdout.writeln('${s.file}  (${s.documented}/${s.total})');
      for (final m in s.missing) {
        stdout.writeln('    $m');
      }
    }
  }
}

typedef _Counter = void Function(AnnotatedNode node, String kind, String name);

void _countMembers(List<ClassMember> members, _Counter count) {
  for (final member in members) {
    switch (member) {
      case MethodDeclaration():
        final kind = member.isGetter
            ? 'getter'
            : member.isSetter
                  ? 'setter'
                  : 'method';
        count(member, kind, member.name.lexeme);
      case ConstructorDeclaration():
        final name = member.name?.lexeme ?? 'new';
        count(member, 'constructor', '.$name');
      case FieldDeclaration():
        for (final v in member.fields.variables) {
          count(member, 'field', v.name.lexeme);
        }
      case _:
        // 其余成员形态（PrimaryConstructorBody 等）无文档注释位，跳过
        break;
    }
  }
}
