import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_sing_box/flutter_sing_box.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  setUpAll(() {
    // fetchAndParse 末端的 schema 校验经 rootBundle 加载 asset；纯 dart
    // 测试环境走 'flutter/assets' 通道 mock，按 asset key 直接读插件仓库
    // 内真实文件（与 sing_box_config_provider_test 同一套路）
    TestWidgetsFlutterBinding.ensureInitialized();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMessageHandler('flutter/assets', (ByteData? message) async {
      final key = utf8.decode(message!.buffer.asUint8List());
      final file = File(key.replaceFirst(RegExp(r'^packages/[^/]+/'), ''));
      if (!file.existsSync()) return null;
      final bytes = utf8.encode(file.readAsStringSync());
      return ByteData.view(Uint8List.fromList(bytes).buffer);
    });
  });

  group('fetchAndParse', () {
    test('本地文件订阅：解析出配置、isLocalFile 为真、name 为文件名', () async {
      final dir = await Directory.systemTemp.createTemp('fsb_fetch_test');
      addTearDown(() => dir.delete(recursive: true));
      // 最小可直解的 sing-box JSON（不触发模板修复路径）：
      // direct 与带成员的 selector 不计入节点数，block 计入 → outboundsCount 为 1
      final file = File('${dir.path}${Platform.pathSeparator}我的订阅.json');
      await file.writeAsString(
        jsonEncode({
          'dns': <String, dynamic>{},
          'inbounds': <dynamic>[],
          'outbounds': <dynamic>[
            {'type': 'selector', 'tag': 'proxy', 'outbounds': ['direct', 'reject']},
            {'type': 'direct', 'tag': 'direct'},
            {'type': 'block', 'tag': 'reject'},
          ],
          'route': <String, dynamic>{},
        }),
      );

      // POSIX 绝对路径不被 parseSubscribeLink 归一化（仅 Windows 盘符/UNC），
      // 本地文件用例直接构造规范 file URI（与 Android/Windows 宿主实际传入一致）
      final link = Uri.file(file.path);
      final result = await ProfileService().fetchAndParse(link: link);

      expect(result.singBox.outbounds, hasLength(3));
      expect(result.isLocalFile, isTrue);
      expect(result.name, '我的订阅.json');
      expect(result.subscribeUrl, link.toString());
      expect(result.outboundsCount, 1);
      // 本地文件无响应头：webPageUrl 回退 host（file URI 的 host 为空串）、无用量信息
      expect(result.webPageUrl, link.host);
      expect(result.userInfo, isNull);
      expect(result.lastUpdated, greaterThan(0));
    });

    test('本地文件不存在时抛出 File not exists', () async {
      final link = Uri.file('/nonexistent/sub.json');
      await expectLater(
        ProfileService().fetchAndParse(link: link),
        throwsA(
          isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('File not exists'),
          ),
        ),
      );
    });
  });
}
