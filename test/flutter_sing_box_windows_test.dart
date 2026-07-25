import 'package:flutter_sing_box/flutter_sing_box.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('FlutterSingBoxWindows.clashModeStream', () {
    test('emitClashMode 后 stream 推送该模式（缓存路径）', () async {
      final platform = FlutterSingBoxWindows();
      final mode = ClientClashMode(
        modes: ['rule', 'global', 'direct'],
        currentMode: 'global',
      );

      platform.emitClashMode(mode);

      final result = await platform.clashModeStream.first;
      expect(result.currentMode, 'global');
      expect(result.modes, ['rule', 'global', 'direct']);
    });
  });
}
