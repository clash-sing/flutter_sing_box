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

  /// Shadowsocks outbound.
  static const String shadowsocks = "shadowsocks";

  /// TUIC outbound.
  static const String tuic = "tuic";

  /// Naive outbound.
  static const String naive = "naive";

  /// SOCKS outbound.
  static const String socks = "socks";

  /// HTTP outbound.
  static const String http = "http";

  /// ShadowTLS outbound.
  static const String shadowTLS = "shadowtls";

  /// Snell outbound.
  static const String snell = "snell";

  @Deprecated("Block outbound is deprecated. Use [Rule.action = 'reject'] instead.")
  /// Block outbound.
  static const String block = "block";
}
