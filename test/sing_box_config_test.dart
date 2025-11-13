import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_sing_box/flutter_sing_box.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('SingBoxConfig', () {
    const defaultConfig = '''
{
  "dns": {
    "servers": [
      {
        "tag": "google",
        "address": "8.8.8.8"
      },
      {
        "tag": "local",
        "address": "223.5.5.5"
      }
    ],
    "rules": [],
    "final": "google"
  },
  "inbounds": [
    {
      "type": "tun",
      "tag": "tun-in",
      "interface_name": "tun0",
      "inet4_address": "172.19.0.1/30",
      "auto_route": true,
      "strict_route": true,
      "stack": "mixed",
      "sniff": true
    }
  ],
  "route": {
    "default_domain_resolver": "google",
    "rules": [
      {
        "protocol": "dns",
        "action": "hijack-dns"
      }
    ],
    "final": "proxy",
    "auto_detect_interface": true,
    "rule_set": []
  },
  "experimental": {
    "clash_api": {
      "external_controller": "127.0.0.1:9090",
      "secret": ""
    }
  },
  "outbounds": [
    {
      "tag": "proxy",
      "type": "selector",
      "outbounds": [
        "vmess-out",
        "trojan-out"
      ],
      "default": "vmess-out"
    },
    {
      "tag": "vmess-out",
      "type": "vmess",
      "server": "example.com",
      "server_port": 443,
      "uuid": "uuid",
      "security": "auto"
    },
    {
      "tag": "trojan-out",
      "type": "trojan",
      "server": "example2.com",
      "server_port": 443,
      "password": "password"
    }
  ],
  "log": {
    "level": "info",
    "timestamp": true
  }
}
''';

    setUp(() {
      // 设置默认配置的模拟数据
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
        SystemChannels.platform,
        (MethodCall methodCall) async {
          if (methodCall.method == 'loadString') {
            return defaultConfig;
          }
          return null;
        },
      );
    });

    tearDown(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(SystemChannels.platform, null);
    });

    test('buildConfig with valid JSON string', () async {
      final jsonString = '''
{
  "dns": {
    "servers": [
      {
        "tag": "google",
        "address": "8.8.8.8"
      }
    ],
    "rules": [],
    "final": "google"
  },
  "inbounds": [],
  "route": {
    "default_domain_resolver": "google",
    "rules": [],
    "final": "direct",
    "auto_detect_interface": true,
    "rule_set": []
  },
  "experimental": {
    "clash_api": {
      "external_controller": "127.0.0.1:9090",
      "secret": ""
    }
  },
  "outbounds": [
    {
      "tag": "direct",
      "type": "direct"
    }
  ],
  "log": {
    "level": "info",
    "timestamp": true
  }
}
''';

      final result = await SingBoxConfigProvider.provide(jsonString);
      expect(result, isA<SingBox>());
      expect(result.route.routeFinal, equals('direct'));
      expect(result.outbounds.length, equals(1));
      expect(result.outbounds.first.tag, equals('direct'));
      expect(result.outbounds.first.type, equals('direct'));
    });

    test('buildConfig with valid Map data', () async {
      final jsonData = jsonDecode(defaultConfig) as Map<String, dynamic>;
      final result = await SingBoxConfigProvider.provide(jsonData);

      expect(result, isA<SingBox>());
      expect(result.route.routeFinal, equals('proxy'));
      expect(result.outbounds.length, greaterThanOrEqualTo(3));
    });

    test('buildConfig throws exception for invalid content', () async {
      expect(
        () => SingBoxConfigProvider.provide('invalid content'),
        throwsException,
      );
    });

    test('_fixOutboundInRoute updates route final to valid outbound', () async {
      final jsonData = jsonDecode(defaultConfig) as Map<String, dynamic>;
      // 修改route.final为无效值
      jsonData['route']['final'] = 'invalid-outbound';

      final result = await SingBoxConfigProvider.provide(jsonData);

      // 应该自动修复为第一个selector类型的outbound
      expect(result.route.routeFinal, equals('proxy'));
    });
  });
}
