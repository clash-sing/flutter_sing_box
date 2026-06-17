/// Shared constant values used across the flutter_sing_box plugin.
class FlutterSingBoxConstants {
  /// The asset path of the sing-box config template bundled with the plugin.
  static const templateConfig =
      'packages/flutter_sing_box/assets/configs/singbox_config_template.json';
  /// The URI scheme prefix that marks a local file subscription.
  static const String localFilePrefix = 'file://';
  /// The file extensions accepted for local subscription files.
  static const List<String> localSubscriptionFileExtensions = ['yaml', 'json', 'txt'];
  /// The default outbound group tag.
  static const String defaultGroup = 'proxy';
  /// The default URL test interval.
  static const String defaultUrlTestInterval = '3m';
  /// The default URL test latency tolerance in milliseconds.
  static const int defaultUrlTestTolerance = 50;
  /// The default URL used for latency testing.
  static const String defaultTestUrl = 'https://www.gstatic.com/generate_204';
}
