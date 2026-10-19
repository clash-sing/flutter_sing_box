// 订阅样本库的驱动：tools/subcheck.py 运行时复制进插件导出目录的 test/，不属于插件。
// 对 SUBCHECK_INPUT 列出的每个样本，把原文按字符串交给 SingBoxConfigProvider.provide()
// （ProfileService 导入订阅时调用的就是它），结果写到 SUBCHECK_OUT/<id>.json：
// 成功 {"ok": true, "config": ...}，失败 {"ok": false, "error": "..."}。
import 'dart:convert';
import 'dart:io' as io;

import 'package:flutter/services.dart';
import 'package:flutter_sing_box/flutter_sing_box.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    final bytes = io.File('assets/configs/singbox_config_template.json').readAsBytesSync();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMessageHandler(
      'flutter/assets',
      (message) async {
        final key = utf8.decode(message!.buffer.asUint8List());
        if (key == FlutterSingBoxConstants.templateConfig) {
          return ByteData.view(bytes.buffer);
        }
        return null;
      },
    );
  });

  test('subcheck samples', () async {
    final input = jsonDecode(io.File(io.Platform.environment['SUBCHECK_INPUT']!).readAsStringSync()) as List;
    final outDir = io.Platform.environment['SUBCHECK_OUT']!;
    for (final item in input) {
      final id = item['id'] as String;
      final text = io.File(item['path'] as String).readAsStringSync();
      Map<String, dynamic> out;
      try {
        final singBox = await SingBoxConfigProvider.provide(text);
        out = {'ok': true, 'config': singBox.toJson()};
      } catch (e) {
        out = {'ok': false, 'error': '$e'};
      }
      io.File('$outDir/$id.json').writeAsStringSync(jsonEncode(out));
    }
  }, timeout: const Timeout(Duration(minutes: 20)));
}
