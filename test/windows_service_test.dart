import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:flutter_sing_box/flutter_sing_box_windows.dart';
import 'package:flutter_sing_box/src/constants/windows_service.dart';

void main() {
  group('WindowsServiceStatus.fromHelperOutput', () {
    test('映射 helper 的已知返回值', () {
      expect(WindowsServiceStatus.fromHelperOutput('running'), WindowsServiceStatus.running);
      expect(WindowsServiceStatus.fromHelperOutput('stopped'), WindowsServiceStatus.stopped);
      expect(WindowsServiceStatus.fromHelperOutput('notInstalled'), WindowsServiceStatus.notInstalled);
      expect(WindowsServiceStatus.fromHelperOutput('unknown'), WindowsServiceStatus.unknown);
      expect(WindowsServiceStatus.fromHelperOutput('error'), WindowsServiceStatus.error);
    });

    test('未识别值（含空串）一律映射为 unknown', () {
      expect(WindowsServiceStatus.fromHelperOutput('whatever'), WindowsServiceStatus.unknown);
      expect(WindowsServiceStatus.fromHelperOutput(''), WindowsServiceStatus.unknown);
    });
  });

  group('FlutterSingBoxWindows.ensureHelperJson', () {
    late Directory tmp;

    setUp(() async {
      tmp = await Directory.systemTemp.createTemp('helper_json_test_');
    });

    tearDown(() async {
      if (await tmp.exists()) await tmp.delete(recursive: true);
    });

    test('helper.json 不存在时按规则生成', () async {
      await FlutterSingBoxWindows().ensureHelperJson(dir: tmp.path);

      final file = File(p.join(tmp.path, 'helper.json'));
      expect(await file.exists(), isTrue);

      final json = jsonDecode(await file.readAsString()) as Map<String, dynamic>;
      expect(json['helperName'], windowsServiceName);
      expect(json['helperDisplayName'], windowsServiceDisplayName);
      expect(json['helperDescription'], windowsServiceDescription);
      expect(json['execute'], p.join(tmp.path, 'sing-box.exe'));
      expect(json['config'], p.join(tmp.path, 'sing-box-config.json'));
      expect(json['port'], 0);
    });

    test('helper.json 已存在时不覆盖（保护服务回写的 port）', () async {
      final file = File(p.join(tmp.path, 'helper.json'));
      await file.writeAsString('{"existing":"value","port":9999}');

      await FlutterSingBoxWindows().ensureHelperJson(dir: tmp.path);

      final json = jsonDecode(await file.readAsString()) as Map<String, dynamic>;
      expect(json['existing'], 'value');
      expect(json['port'], 9999);
    });
  });
}
