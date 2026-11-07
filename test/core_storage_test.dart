import 'package:flutter_sing_box/flutter_sing_box.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  setUp(CoreStorage.mockInit); // 注入 MemoryStorage,隔离 MMKV

  group('setSelectedProfileName', () {
    test('写入交接键 selected_profile_name', () {
      CoreStorage().setSelectedProfileName('x');

      expect(CoreStorage.storage.getString('selected_profile_name'), 'x');
    });
  });

  group('usingConfig', () {
    test('setUsingConfig 后 getUsingConfig 路径含 using_config.json', () async {
      CoreStorage().setUsingConfig('/tmp');

      final file = await CoreStorage().getUsingConfig();

      expect(file.path, contains('using_config.json'));
    });
  });
}
