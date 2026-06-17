/// The Clash routing mode constants.
class ClashMode {
  /// Route traffic according to rules.
  static const String rule = "Rule";
  /// Route all traffic through the proxy.
  static const String global = "global";
  /// Bypass the proxy and connect directly.
  static const String direct = "direct";
  /// Block the traffic.
  static const String block = "block";
}
