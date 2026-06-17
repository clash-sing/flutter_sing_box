/// The transport security mode constants for outbounds.
class OutboundSecurity {
  /// Automatically negotiate the security mode.
  static const String auto = "auto";
  /// Disable transport security.
  static const String none = "none";
  /// Zero RTT security mode.
  static const String zero = "zero";
  /// AES-128-GCM encryption.
  static const String aes128gcm = "aes-128-gcm";
  /// ChaCha20-Poly1305 encryption.
  static const String chacha20Poly1305 = "chacha20-poly1305";
}
