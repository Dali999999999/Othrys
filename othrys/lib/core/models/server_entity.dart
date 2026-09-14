import '../enums/auth_method.dart';

export '../enums/auth_method.dart';
typedef SSHAuthType = AuthMethod;

const Object _sentinel = Object();

/// Domain model representing a managed Linux VPS server.
class ServerEntity {
  final String id;
  final String name;
  final String host;
  final int port;
  final String username;
  final AuthMethod authType;
  final String? password;
  final String? privateKey;
  final String? passphrase;
  final String? group;
  final List<String> pinnedServices;
  final String? bastionId;
  final DateTime? lastConnected;
  final String? osName;

  const ServerEntity({
    required this.id,
    required this.name,
    required this.host,
    this.port = 22,
    required this.username,
    this.authType = AuthMethod.password,
    this.password,
    this.privateKey,
    this.passphrase,
    this.group,
    this.pinnedServices = const [],
    this.bastionId,
    this.lastConnected,
    this.osName,
  });

  /// Validates basic host, port, and username constraints. Returns error message or null.
  static String? validate({required String host, required int port, required String username}) {
    if (host.trim().isEmpty) return 'Host address is required.';
    if (port < 1 || port > 65535) return 'Port must be between 1 and 65535.';
    if (username.trim().isEmpty) return 'Username is required.';
    return null;
  }

  ServerEntity copyWith({
    String? id,
    String? name,
    String? host,
    int? port,
    String? username,
    AuthMethod? authType,
    Object? password = _sentinel,
    Object? privateKey = _sentinel,
    Object? passphrase = _sentinel,
    Object? group = _sentinel,
    List<String>? pinnedServices,
    Object? bastionId = _sentinel,
    Object? lastConnected = _sentinel,
    Object? osName = _sentinel,
  }) {
    return ServerEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      host: host ?? this.host,
      port: port ?? this.port,
      username: username ?? this.username,
      authType: authType ?? this.authType,
      password: password == _sentinel ? this.password : (password as String?),
      privateKey: privateKey == _sentinel ? this.privateKey : (privateKey as String?),
      passphrase: passphrase == _sentinel ? this.passphrase : (passphrase as String?),
      group: group == _sentinel ? this.group : (group as String?),
      pinnedServices: pinnedServices ?? this.pinnedServices,
      bastionId: bastionId == _sentinel ? this.bastionId : (bastionId as String?),
      lastConnected: lastConnected == _sentinel ? this.lastConnected : (lastConnected as DateTime?),
      osName: osName == _sentinel ? this.osName : (osName as String?),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'host': host,
        'port': port,
        'username': username,
        'authType': authType.toJson(),
        'password': password,
        'privateKey': privateKey,
        'passphrase': passphrase,
        'group': group,
        'pinnedServices': pinnedServices,
        'bastionId': bastionId,
        'lastConnected': lastConnected?.toIso8601String(),
        'osName': osName,
      };

  factory ServerEntity.fromJson(Map<String, dynamic> json) => ServerEntity(
        id: json['id'] as String? ?? '',
        name: json['name'] as String? ?? '',
        host: json['host'] as String? ?? '',
        port: (json['port'] as num?)?.toInt() ?? 22,
        username: json['username'] as String? ?? '',
        authType: AuthMethod.fromJson(json['authType'] as String?),
        password: json['password'] as String?,
        privateKey: json['privateKey'] as String?,
        passphrase: json['passphrase'] as String?,
        group: json['group'] as String?,
        pinnedServices: (json['pinnedServices'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? const [],
        bastionId: json['bastionId'] as String?,
        lastConnected: json['lastConnected'] != null ? DateTime.tryParse(json['lastConnected'] as String) : null,
        osName: json['osName'] as String?,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ServerEntity &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          host == other.host &&
          port == other.port &&
          username == other.username &&
          authType == other.authType &&
          password == other.password &&
          privateKey == other.privateKey &&
          passphrase == other.passphrase &&
          group == other.group &&
          bastionId == other.bastionId &&
          osName == other.osName;

  @override
  int get hashCode => Object.hash(id, name, host, port, username, authType, password, privateKey, passphrase, group, bastionId, osName);

  @override
  String toString() {
    final hasPass = password != null && password!.isNotEmpty ? '***' : 'none';
    final hasKey = privateKey != null && privateKey!.isNotEmpty ? '***' : 'none';
    return 'ServerEntity(id: $id, name: $name, host: $host:$port, user: $username, auth: ${authType.name}, password: $hasPass, key: $hasKey)';
  }
}
