/// flutter_sing_box 插件全局共享常量。
abstract class FlutterSingBoxConstants {
  /// 插件内置 sing-box 配置模板的资产路径。
  static const templateConfig =
      'packages/flutter_sing_box/assets/configs/singbox_config_template.json';

  /// 插件内置 sing-box JSON Schema（draft 2020-12）的资产路径，
  /// 供订阅导入时校验配置。
  ///
  /// schema 与 sing-box 内核版本强绑定，升级内核时需同步替换本文件
  /// （test/ 下的校验测试是替换后的回归闸门）。
  static const schemaConfig =
      'packages/flutter_sing_box/assets/schemas/singbox_schema.json';

  /// 标记本地文件订阅的 URI 前缀（全平台统一）。
  ///
  /// 本地文件路径一律经 [Uri.file] 归一化为 file:///... 形式后存储，
  /// 不再按平台区分（Windows 原始盘符路径会被 [Uri.parse] 误判为
  /// 单字母 scheme，导致识别失败）。
  static const String localFilePrefix = 'file://';

  /// 本地订阅文件可接受的扩展名。
  static const List<String> localSubscriptionFileExtensions = ['json', 'yaml', 'yml', 'txt'];

  /// 默认出站分组标签。
  static const String defaultGroup = 'proxy';

  /// 默认 URL 测速间隔。
  static const String defaultUrlTestInterval = '3m';

  /// 默认 URL 测速时延容差（毫秒）。
  static const int defaultUrlTestTolerance = 50;

  /// 默认测速 URL。
  static const String defaultTestUrl = 'https://www.gstatic.com/generate_204';

  /// 插件打包资产基路径。
  static const String assetBasePath = 'packages/flutter_sing_box/assets/';

  /// Clash API 默认监听端口。
  static const int defaultClashApiPort = 9090;

  /// mixed 入站（HTTP+SOCKS 合一）默认监听端口。
  static const int defaultMixedPort = 8890;
}
