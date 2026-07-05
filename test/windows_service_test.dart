import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
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
}
