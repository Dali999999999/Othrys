/// Connection state lifecycle for an SSH session.
enum ConnectionState {
  disconnected,
  connecting,
  connected,
  reconnecting,
  error;

  /// Returns `true` if session is in active connected state.
  bool get isConnected => this == ConnectionState.connected;

  /// Returns `true` if an operation is in progress.
  bool get isBusy => this == ConnectionState.connecting || this == ConnectionState.reconnecting;
}
