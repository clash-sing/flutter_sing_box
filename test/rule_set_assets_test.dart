import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_sing_box/flutter_sing_box.dart'
    hide Inbound, Outbound, RuleSet, SingBox;
import 'package:flutter_sing_box/src/data/models/singbox/gen/index.dart';
import 'package:flutter_sing_box/src/utils/rule_set_assets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;

/// 构造只含 route.rule_set 的最小配置。
SingBox _configWith(List<Map<String, dynamic>> ruleSets) {
  return SingBox.fromJson({
    'dns': <String, dynamic>{},
    'inbounds': <dynamic>[],
    'outbounds': <dynamic>[],
    'route': {'rule_set': ruleSets},
  });
}

Map<String, dynamic> _remoteRuleSet({
  required String tag,
  required String url,
  String? format = 'binary',
  String? initialPath,
}) {
  return {
    'tag': tag,
    'type': 'remote',
    'format': ?format,
    'url': url,
    'initial_path': ?initialPath,
  };
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory tmp;
  late Directory ruleSetDir;

  setUp(() async {
    tmp = await Directory.systemTemp.createTemp('rule_set_assets_test_');
    ruleSetDir = Directory(p.join(tmp.path, 'rule-sets'));
    await ruleSetDir.create(recursive: true);
    await File(p.join(ruleSetDir.path, 'geoip-cn.srs')).writeAsBytes([1, 2, 3]);
    await File(
      p.join(ruleSetDir.path, 'geosite-cn.srs'),
    ).writeAsBytes([4, 5, 6]);
  });

  tearDown(() async {
    if (await tmp.exists()) await tmp.delete(recursive: true);
  });

  group('applyInitialPaths', () {
    test('官方 SagerNet 规则集缺少 initial_path 时注入本地绝对路径', () async {
      final singBox = _configWith([
        _remoteRuleSet(
          tag: 'geoip-cn',
          url:
              'https://testingcf.jsdelivr.net/gh/SagerNet/sing-geoip@rule-set/geoip-cn.srs',
        ),
        _remoteRuleSet(
          tag: 'geosite-cn',
          url:
              'https://testingcf.jsdelivr.net/gh/SagerNet/sing-geosite@rule-set/geosite-cn.srs',
        ),
      ]);

      await RuleSetAssets.applyInitialPaths(singBox, directory: ruleSetDir);

      final ruleSets = singBox.route.ruleSet!;
      expect(ruleSets[0].initialPath, p.join(ruleSetDir.path, 'geoip-cn.srs'));
      expect(
        ruleSets[1].initialPath,
        p.join(ruleSetDir.path, 'geosite-cn.srs'),
      );
      expect(p.isAbsolute(ruleSets[0].initialPath!), isTrue);
    });

    test('已有且文件有效的 initial_path 不覆盖', () async {
      final custom = File(p.join(tmp.path, 'custom.srs'));
      await custom.writeAsBytes([9]);
      final singBox = _configWith([
        _remoteRuleSet(
          tag: 'geoip-cn',
          url:
              'https://testingcf.jsdelivr.net/gh/SagerNet/sing-geoip@rule-set/geoip-cn.srs',
          initialPath: custom.path,
        ),
      ]);

      await RuleSetAssets.applyInitialPaths(singBox, directory: ruleSetDir);

      expect(singBox.route.ruleSet!.single.initialPath, custom.path);
    });

    test('已有 initial_path 指向的文件失效时替换为内置路径', () async {
      final singBox = _configWith([
        _remoteRuleSet(
          tag: 'geoip-cn',
          url:
              'https://testingcf.jsdelivr.net/gh/SagerNet/sing-geoip@rule-set/geoip-cn.srs',
          initialPath: p.join(tmp.path, 'missing.srs'),
        ),
      ]);

      await RuleSetAssets.applyInitialPaths(singBox, directory: ruleSetDir);

      expect(
        singBox.route.ruleSet!.single.initialPath,
        p.join(ruleSetDir.path, 'geoip-cn.srs'),
      );
    });

    test('非官方来源、不同文件名、source 格式均不注入', () async {
      final singBox = _configWith([
        _remoteRuleSet(
          tag: 'geoip-cn',
          url: 'https://example.com/geoip-cn.srs',
        ),
        _remoteRuleSet(
          tag: 'geoip-us',
          url:
              'https://testingcf.jsdelivr.net/gh/SagerNet/sing-geoip@rule-set/geoip-us.srs',
        ),
        _remoteRuleSet(
          tag: 'geosite-cn',
          url:
              'https://testingcf.jsdelivr.net/gh/SagerNet/sing-geosite@rule-set/geosite-cn.json',
          format: 'source',
        ),
      ]);

      await RuleSetAssets.applyInitialPaths(singBox, directory: ruleSetDir);

      expect(
        singBox.route.ruleSet!.map((e) => e.initialPath),
        everyElement(isNull),
      );
    });

    test('本地内置文件不存在时不注入，也不抛异常', () async {
      await File(p.join(ruleSetDir.path, 'geoip-cn.srs')).delete();
      final singBox = _configWith([
        _remoteRuleSet(
          tag: 'geoip-cn',
          url:
              'https://testingcf.jsdelivr.net/gh/SagerNet/sing-geoip@rule-set/geoip-cn.srs',
        ),
      ]);

      await RuleSetAssets.applyInitialPaths(singBox, directory: ruleSetDir);

      expect(singBox.route.ruleSet!.single.initialPath, isNull);
    });

    test('路径解析失败时静默跳过（不向导入流程冒泡）', () async {
      final singBox = _configWith([
        _remoteRuleSet(
          tag: 'geoip-cn',
          url:
              'https://testingcf.jsdelivr.net/gh/SagerNet/sing-geoip@rule-set/geoip-cn.srs',
        ),
      ]);

      // 不传 directory，也不 mock path_provider：默认路径解析必然失败
      final originalDebugPrint = debugPrint;
      debugPrint = (String? message, {int? wrapWidth}) {};
      try {
        await RuleSetAssets.applyInitialPaths(singBox);
      } finally {
        debugPrint = originalDebugPrint;
      }

      expect(singBox.route.ruleSet!.single.initialPath, isNull);
    });
  });

  group('ensureExtracted', () {
    test('两个规则集资产已打包且为 SRS 二进制格式', () async {
      for (final String name in RuleSetAssets.fileNames) {
        final ByteData data = await rootBundle.load(
          RuleSetAssets.assetPathOf(name),
        );
        final Uint8List bytes = data.buffer.asUint8List(
          data.offsetInBytes,
          data.lengthInBytes,
        );
        expect(bytes.length, greaterThan(1024), reason: '$name 体积异常');
        expect(bytes.sublist(0, 3), [0x53, 0x52, 0x53], reason: '$name 不是 SRS');
      }
    });

    test('把资产写入目标目录，重复调用保持内容一致', () async {
      final bytes = Uint8List.fromList([0x53, 0x52, 0x53, 0x01]);
      var loadCount = 0;

      final ok = await RuleSetAssets.ensureExtracted(
        directory: ruleSetDir,
        loader: (assetPath) async {
          loadCount++;
          expect(assetPath, contains('/rulesets/'));
          return ByteData.sublistView(bytes);
        },
      );

      expect(ok, isTrue);
      expect(loadCount, RuleSetAssets.fileNames.length);
      for (final name in RuleSetAssets.fileNames) {
        expect(await File(p.join(ruleSetDir.path, name)).readAsBytes(), bytes);
      }

      // 再次调用：内容一致，仍应成功
      expect(
        await RuleSetAssets.ensureExtracted(
          directory: ruleSetDir,
          loader: (_) async => ByteData.sublistView(bytes),
        ),
        isTrue,
      );
    });
  });
}
