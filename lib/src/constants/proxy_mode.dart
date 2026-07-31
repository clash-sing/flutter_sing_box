/// Windows 桌面端的代理模式。
enum ProxyMode {
  /// Tun 虚拟网卡模式（默认，整机流量透明代理）。
  tun,

  /// 系统代理模式（写注册表设 IE/系统代理，仅覆盖遵守系统代理的应用）。
  systemProxy,
}
