enum ActivityLevel {
  info,
  success,
  warning,
  error;

  String toJson() => name;
  static ActivityLevel fromJson(String? value) => ActivityLevel.values.firstWhere(
        (e) => e.name.toLowerCase() == value?.toLowerCase(),
        orElse: () => ActivityLevel.info,
      );
}

enum ActivityCategory {
  ssh,
  docker,
  files,
  services,
  tunnels,
  system;

  String toJson() => name;
  static ActivityCategory fromJson(String? value) => ActivityCategory.values.firstWhere(
        (e) => e.name.toLowerCase() == value?.toLowerCase(),
        orElse: () => ActivityCategory.system,
      );
}

/// Domain model representing an audit log of actions taken within Othrys.
class ActivityLogEntity {
  final String id;
  final String? serverId;
  final DateTime timestamp;
  final ActivityLevel level;
  final ActivityCategory category;
  final String message;
  final Map<String, dynamic>? metadata;

  const ActivityLogEntity({
    required this.id,
    this.serverId,
    required this.timestamp,
    required this.level,
    required this.category,
    required this.message,
    this.metadata,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'serverId': serverId,
        'timestamp': timestamp.toIso8601String(),
        'level': level.toJson(),
        'category': category.toJson(),
        'message': message,
        'metadata': metadata,
      };

  factory ActivityLogEntity.fromJson(Map<String, dynamic> json) {
    final parsedTime = (json['timestamp'] is String)
        ? (DateTime.tryParse(json['timestamp'] as String) ?? DateTime.now())
        : DateTime.now();

    return ActivityLogEntity(
      id: json['id'] as String? ?? '',
      serverId: json['serverId'] as String?,
      timestamp: parsedTime,
      level: ActivityLevel.fromJson(json['level'] as String?),
      category: ActivityCategory.fromJson(json['category'] as String?),
      message: json['message'] as String? ?? '',
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ActivityLogEntity &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          serverId == other.serverId &&
          level == other.level &&
          category == other.category &&
          message == other.message;

  @override
  int get hashCode => Object.hash(id, serverId, level, category, message);
}
