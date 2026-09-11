/// The lifecycle state of the proxy (VPN) service.
enum ProxyState {
  /// The proxy is stopped.
  stopped('Stopped'),

  /// The proxy is starting.
  starting('Starting'),

  /// The proxy is started.
  started('Started'),

  /// The proxy is stopping.
  stopping('Stopping');

  const ProxyState(this.name);

  /// The display name of this state.
  final String name;

  /// Returns the [ProxyState] corresponding to the given display name.
  static ProxyState fromName(String name) {
    for (var state in ProxyState.values) {
      if (state.name == name) return state;
    }
    return ProxyState.stopped;
  }
}
