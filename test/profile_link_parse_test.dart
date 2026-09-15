import 'package:flutter_sing_box/flutter_sing_box.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('parseSubscribeLink', () {
    test('Windows 盘符路径（反斜杠）归一化为 file URI 并可还原', () {
      final uri = ProfileService.parseSubscribeLink(r'C:\Users\haoco\配置.yaml');
      expect(uri.isScheme('file'), isTrue);
      expect(uri.toFilePath(windows: true), r'C:\Users\haoco\配置.yaml');
    });

    test('Windows 盘符路径（正斜杠）归一化为 file URI', () {
      final uri = ProfileService.parseSubscribeLink('C:/Users/haoco/config.yaml');
      expect(uri.isScheme('file'), isTrue);
      expect(uri.toFilePath(windows: true), r'C:\Users\haoco\config.yaml');
    });

    test('UNC 路径归一化为 file URI 并可还原', () {
      final uri = ProfileService.parseSubscribeLink(r'\\server\share\config.yaml');
      expect(uri.isScheme('file'), isTrue);
      expect(uri.toFilePath(windows: true), r'\\server\share\config.yaml');
    });

    test('路径中的 # 与空格被正确编码而非截断', () {
      final uri = ProfileService.parseSubscribeLink(r'C:\my config#a.yaml');
      expect(uri.isScheme('file'), isTrue);
      expect(uri.toFilePath(windows: true), r'C:\my config#a.yaml');
    });

    test('已是 file:// 的输入原样保留', () {
      final uri = ProfileService.parseSubscribeLink('file:///storage/emulated/0/a.yaml');
      expect(uri.isScheme('file'), isTrue);
      expect(uri.toString(), 'file:///storage/emulated/0/a.yaml');
    });

    test('http URL 按普通 URL 解析', () {
      final uri = ProfileService.parseSubscribeLink('https://example.com/sub?x=1');
      expect(uri.isScheme('file'), isFalse);
      expect(uri.host, 'example.com');
    });

    test('冒号后非分隔符的单字母 scheme（如 d:443）不误判为本地文件', () {
      final uri = ProfileService.parseSubscribeLink('d:443/path');
      expect(uri.isScheme('file'), isFalse);
    });
  });

  group('isLocalFile', () {
    test('file URI 判定为本地文件', () {
      expect(ProfileService().isLocalFile(Uri.file(r'C:\a.yaml', windows: true)), isTrue);
      expect(ProfileService().isLocalFile(Uri.parse('file:///storage/x.yaml')), isTrue);
    });

    test('http 与单字母 scheme 不判定为本地文件', () {
      expect(ProfileService().isLocalFile(Uri.parse('https://example.com')), isFalse);
      expect(ProfileService().isLocalFile(Uri.parse('c:/foo')), isFalse);
    });
  });

  test('localFilePrefix 全平台统一为 file://', () {
    expect(FlutterSingBoxConstants.localFilePrefix, 'file://');
  });
}
