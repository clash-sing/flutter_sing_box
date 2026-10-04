// 宿主 app 视角的端到端验证：schema 经 rootBundle 真实 asset 路径加载并可用。
// 纯 dart 单测（插件 test/）走的是文件读取，覆盖不到 asset 打包链路，
// 此测试在 example（宿主）环境的 asset bundle 里验证生产路径。
import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_sing_box/flutter_sing_box.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('schema asset 经 rootBundle 可加载，instance() 直接可用', () async {
    // 路径与常量一致，且 asset 真的被打进了宿主 bundle
    final raw =
        await rootBundle.loadString(FlutterSingBoxConstants.schemaConfig);
    final map = jsonDecode(raw) as Map<String, dynamic>;
    expect(map[r'$id'], 'https://sing-box.sagernet.org/schema.json');

    // 生产入口 instance() 全链路（rootBundle 加载 + 构建 + 校验）
    final validator = await SingBoxSchemaValidator.instance();
    final templateRaw = await rootBundle
        .loadString(FlutterSingBoxConstants.templateConfig);
    final errors = validator
        .validateSync(jsonDecode(templateRaw) as Map<String, dynamic>);
    expect(errors, isEmpty,
        reason: errors.map((e) => e.toErrorString()).join('\n'));
  });
}
