import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_sing_box/src/constants/windows_service.dart';
import 'package:flutter_sing_box/flutter_sing_box_windows.dart';

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
  });

  group('FlutterSingBoxWindows.buildRunasArgs', () {
    late FlutterSingBoxWindows inst;

    setUp(() {
      inst = FlutterSingBoxWindows();
    });

    test('包含 -NoProfile / -NonInteractive 开关', () {
      final args = inst.buildRunasArgs(r'C:\app\helper.exe');
      expect(args, containsAll(<String>['-NoProfile', '-NonInteractive']));
    });

    test('末位 -Command 含 Start-Process、-Verb RunAs、路径与 install 参数', () {
      final args = inst.buildRunasArgs(r'C:\app\helper.exe');
      expect(args, hasLength(4));
      final cmd = args.last;
      expect(cmd, contains('Start-Process'));
      expect(cmd, contains('-Verb RunAs'));
      expect(cmd, contains(r'C:\app\helper.exe'));
      expect(cmd, contains("-ArgumentList 'install'"));
    });

    test('路径含空格时仍被单引号包裹', () {
      final args = inst.buildRunasArgs(r'C:\Program Files\app\helper.exe');
      expect(args.last, contains(r"'C:\Program Files\app\helper.exe'"));
    });
  });
}
