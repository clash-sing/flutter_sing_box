/// Shared constant values used across the flutter_sing_box plugin.
abstract class FlutterSingBoxConstants {
  /// The asset path of the sing-box config template bundled with the plugin.
  static const templateConfig =
      'packages/flutter_sing_box/assets/configs/singbox_config_template.json';

  /// 标记本地文件订阅的 URI 前缀（全平台统一）。
  ///
  /// 本地文件路径一律经 [Uri.file] 归一化为 file:///... 形式后存储，
  /// 不再按平台区分（Windows 原始盘符路径会被 [Uri.parse] 误判为
  /// 单字母 scheme，导致识别失败）。
  static const String localFilePrefix = 'file://';

  /// The file extensions accepted for local subscription files.
  static const List<String> localSubscriptionFileExtensions = ['json', 'yaml', 'yml', 'txt'];

  /// The default outbound group tag.
  static const String defaultGroup = 'proxy';

  /// The default URL test interval.
  static const String defaultUrlTestInterval = '3m';

  /// The default URL test latency tolerance in milliseconds.
  static const int defaultUrlTestTolerance = 50;

  /// The default URL used for latency testing.
  static const String defaultTestUrl = 'https://www.gstatic.com/generate_204';

  static const String assetBasePath = 'packages/flutter_sing_box/assets/';

  static const int defaultClashApiPort = 9090;

  /// mixed 入站（HTTP+SOCKS 合一）默认监听端口。
  static const int defaultMixedPort = 8890;
}
