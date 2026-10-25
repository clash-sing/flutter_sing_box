/// Clash 代理节点类型名常量。
class ClashProxyType {
  /// Hysteria2 协议。
  static const String hysteria2 = "hysteria2";
  /// Hysteria 协议。
  static const String hysteria = "hysteria";
  /// AnyTLS 协议。
  static const String anytls = "anytls";
  /// Trojan 协议。
  static const String trojan = "trojan";
  /// TUIC 协议。
  static const String tuic = "tuic";
  /// VMess 协议。
  static const String vmess = "vmess";
  /// VLESS 协议。
  static const String vless = "vless";
  /// Shadowsocks 协议（Clash 键名为 `ss`）。
  static const String shadowsocks = "ss";
  /// SOCKS5 协议。
  static const String socks5 = "socks5";
  /// HTTP 代理。
  static const String http = "http";
  /// Snell 协议。
  static const String snell = "snell";
}

/// Clash 分组类型名常量。
class ClashGroupType {
  /// 手动选择分组。
  static const String select = "select";
  /// 自动测速分组。
  static const String urlTest = "url-test";
  /// 故障转移分组。
  static const String fallback = "fallback";
}
