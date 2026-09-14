/// Supported authentication methods for SSH connections.
enum AuthMethod {
  password,
  privateKey;

  /// Serializes the enum to a JSON string.
  String toJson() => name;

  /// Deserializes the enum with safe fallback to [AuthMethod.password].
  static AuthMethod fromJson(String? value) {
    if (value == null) return AuthMethod.password;
    return AuthMethod.values.firstWhere(
      (e) => e.name.toLowerCase() == value.toLowerCase(),
      orElse: () => AuthMethod.password,
    );
  }
}
