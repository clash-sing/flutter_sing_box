import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_sing_box/src/windows/helper_cli.dart';

void main() {
  group('HelperCli.buildRunasArgs', () {
    test('包含 -NoProfile / -NonInteractive 开关且共 4 段', () {
      final args = HelperCli.buildRunasArgs(r'C:\app\helper.exe', 'install');
      expect(args, hasLength(4));
      expect(args, containsAll(<String>['-NoProfile', '-NonInteractive']));
    });

    test('install 子命令正确拼入 -ArgumentList', () {
      final args = HelperCli.buildRunasArgs(r'C:\app\helper.exe', 'install');
      expect(args.last, contains('Start-Process'));
      expect(args.last, contains('-Verb RunAs'));
      expect(args.last, contains(r'C:\app\helper.exe'));
      expect(args.last, contains("-ArgumentList 'install'"));
    });

    test('uninstall / start 子命令同样拼入', () {
      expect(
        HelperCli.buildRunasArgs(r'C:\app\helper.exe', 'uninstall').last,
        contains("-ArgumentList 'uninstall'"),
      );
      expect(
        HelperCli.buildRunasArgs(r'C:\app\helper.exe', 'start').last,
        contains("-ArgumentList 'start'"),
      );
    });

    test('路径含空格时仍被单引号包裹', () {
      final args = HelperCli.buildRunasArgs(r'C:\Program Files\app\helper.exe', 'install');
      expect(args.last, contains(r"'C:\Program Files\app\helper.exe'"));
    });
  });
}
