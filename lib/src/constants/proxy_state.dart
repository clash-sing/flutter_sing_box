enum ProxyState {
  /// The proxy is stopped.
  stopped('Stopped'),

  /// The proxy is starting.
  starting('Starting'),

  /// The proxy is started.
  started('Started'),

  /// The proxy is stopping.
  stopping('Stopping'),

  /// The proxy is in an unknown state.
  unknown('Unknown');

  const ProxyState(this.name);

  final String name;
}