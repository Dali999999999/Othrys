/// Types of SSH Port Forwarding tunnels.
enum TunnelType {
  local,
  remote,
  dynamic;

  /// Serializes the enum to a JSON string.
  String toJson() => name;

  /// Deserializes the enum with safe fallback to [TunnelType.local].
  static TunnelType fromJson(String? value) {
    if (value == null) return TunnelType.local;
    return TunnelType.values.firstWhere(
      (e) => e.name.toLowerCase() == value.toLowerCase(),
      orElse: () => TunnelType.local,
    );
  }
}
