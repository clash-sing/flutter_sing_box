/// The action constants applied to a matched routing rule.
class RuleAction {
  /// Route the matched traffic to an outbound.
  static const String route = "route";
  /// Bypass the proxy for the matched traffic.
  static const String bypass = "bypass";
  /// Reject the matched traffic.
  static const String reject = "reject";
  /// Hijack DNS queries for the matched traffic.
  static const String hijackDns = "hijack-dns";
  /// 仅对 dns.rule 有效
  static const String predefined = "predefined";
  /// Apply route options to the matched traffic.
  static const String routeOptions = "route-options";
  /// Sniff the protocol of the matched traffic.
  static const String sniff = "sniff";
  /// Resolve the domain of the matched traffic.
  static const String resolve = "resolve";
}
