// tool/src/names.dart —— 纯 Dart，禁止 Flutter import

/// snake_case 转 lowerCamelCase：server_port -> serverPort
String lowerCamel(String snake) => snake
    .split('_')
    .asMap()
    .entries
    .map((e) => e.key == 0
        ? e.value
        : '${e.value[0].toUpperCase()}${e.value.substring(1)}')
    .join();

/// 类型串转 Pascal：hysteria2 -> Hysteria2（数字段保持原样）
String pascalCase(String s) => s
    .split('_')
    .map((part) => part.isEmpty ? part : '${part[0].toUpperCase()}${part.substring(1)}')
    .join();

String classNameForOutbound(String type) => '${pascalCase(type)}Outbound';
String classNameForInbound(String type) => '${pascalCase(type)}Inbound';

/// 类名转 snake 文件名：Hysteria2Outbound -> hysteria2_outbound.dart
/// 规则：小写/数字后跟大写处插下划线（连续大写如 TLSOptions 视作一个词组）
String fileNameFor(String className) {
  final snake = className
      .replaceAllMapped(RegExp(r'([a-z0-9])([A-Z])'), (m) => '${m[1]}_${m[2]}')
      .replaceAllMapped(RegExp(r'([A-Z]+)([A-Z][a-z])'), (m) => '${m[1]}_${m[2]}')
      .toLowerCase();
  return '$snake.dart';
}

/// 白名单：见 spec「白名单」节，与 OutboundType/InboundType 常量表对齐
const outboundWhitelist = <String>{
  'direct', 'selector', 'urltest', 'block',
  'hysteria2', 'hysteria', 'anytls', 'trojan', 'vmess', 'vless',
  'shadowsocks', 'tuic', 'naive', 'socks', 'http', 'shadowtls', 'snell',
};

const inboundWhitelist = <String>{'tun', 'mixed'};
