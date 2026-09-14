import '../enums/tunnel_type.dart';

export '../enums/tunnel_type.dart';

/// Domain model representing an SSH port forwarding tunnel.
class TunnelEntity {
  final String id;
  final String serverId;
  final String name;
  final String? label;
  final TunnelType type;
  final String bindAddress;
  final int localPort;
  final String remoteHost;
  final int remotePort;
  final bool isSystemInternal;

  const TunnelEntity({
    required this.id,
    required this.serverId,
    required this.name,
    this.label,
    this.type = TunnelType.local,
    this.bindAddress = '127.0.0.1',
    required this.localPort,
    required this.remoteHost,
    required this.remotePort,
    this.isSystemInternal = false,
  });

  /// Validates port numbers and destination host format.
  static String? validate({required int localPort, required int remotePort, required String remoteHost}) {
    if (localPort < 1 || localPort > 65535) return 'Local port must be between 1 and 65535.';
    if (remotePort < 1 || remotePort > 65535) return 'Remote port must be between 1 and 65535.';
    if (remoteHost.trim().isEmpty) return 'Remote host address cannot be empty.';
    return null;
  }

  TunnelEntity copyWith({
    String? id,
    String? serverId,
    String? name,
    String? label,
    TunnelType? type,
    String? bindAddress,
    int? localPort,
    String? remoteHost,
    int? remotePort,
    bool? isSystemInternal,
  }) {
    return TunnelEntity(
      id: id ?? this.id,
      serverId: serverId ?? this.serverId,
      name: name ?? this.name,
      label: label ?? this.label,
      type: type ?? this.type,
      bindAddress: bindAddress ?? this.bindAddress,
      localPort: localPort ?? this.localPort,
      remoteHost: remoteHost ?? this.remoteHost,
      remotePort: remotePort ?? this.remotePort,
      isSystemInternal: isSystemInternal ?? this.isSystemInternal,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'serverId': serverId,
        'name': name,
        'label': label,
        'type': type.toJson(),
        'bindAddress': bindAddress,
        'localPort': localPort,
        'remoteHost': remoteHost,
        'remotePort': remotePort,
        'isSystemInternal': isSystemInternal,
      };

  factory TunnelEntity.fromJson(Map<String, dynamic> json) => TunnelEntity(
        id: json['id'] as String? ?? '',
        serverId: json['serverId'] as String? ?? '',
        name: json['name'] as String? ?? '',
        label: json['label'] as String?,
        type: TunnelType.fromJson(json['type'] as String?),
        bindAddress: json['bindAddress'] as String? ?? '127.0.0.1',
        localPort: (json['localPort'] as num?)?.toInt() ?? 8080,
        remoteHost: json['remoteHost'] as String? ?? '127.0.0.1',
        remotePort: (json['remotePort'] as num?)?.toInt() ?? 80,
        isSystemInternal: json['isSystemInternal'] as bool? ?? false,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TunnelEntity &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          serverId == other.serverId &&
          name == other.name &&
          label == other.label &&
          type == other.type &&
          bindAddress == other.bindAddress &&
          localPort == other.localPort &&
          remoteHost == other.remoteHost &&
          remotePort == other.remotePort &&
          isSystemInternal == other.isSystemInternal;

  @override
  int get hashCode => Object.hash(id, serverId, name, label, type, bindAddress, localPort, remoteHost, remotePort, isSystemInternal);
}
