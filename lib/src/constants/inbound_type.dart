/// 入站类型名常量（与生成模型的 `type` 判别值对齐）。
abstract class InboundType {
  /// TUN 入站（虚拟网卡，接管全局流量）。
  static const String tun = "tun";
  /// mixed 入站（HTTP + SOCKS 合一监听）。
  static const String mixed = "mixed";
}
