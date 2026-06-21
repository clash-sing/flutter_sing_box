/// The sing-box outbound type constants.
class OutboundType {
  /// Direct outbound that bypasses any proxy.
  static const String direct = "direct";

  /// A group that allows manually selecting an outbound.
  static const String selector = "selector";

  /// A group that automatically selects the lowest-latency outbound.
  static const String urltest = "urltest";

  /// Hysteria2 outbound.
  static const String hysteria2 = "hysteria2";

  /// Hysteria outbound.
  static const String hysteria = "hysteria";

  /// AnyTLS outbound.
  static const String anytls = "anytls";

  /// Trojan outbound.
  static const String trojan = "trojan";

  /// VMess outbound.
  static const String vmess = "vmess";

  /// VLESS outbound.
  static const String vless = "vless";

  /// TUIC outbound.
  static const String tuic = "tuic";
  static const String naive = "naive";
}
