/// Domain entity representing a Systemd service unit on the remote server.
class ServiceEntryEntity {
  final String unit;
  final String load;
  final String active;
  final String sub;
  final String description;
  final bool isEnabled;

  const ServiceEntryEntity({
    required this.unit,
    required this.load,
    required this.active,
    required this.sub,
    required this.description,
    this.isEnabled = false,
  });

  bool get isRunning => active.toLowerCase() == 'active';

  ServiceEntryEntity copyWith({
    String? unit,
    String? load,
    String? active,
    String? sub,
    String? description,
    bool? isEnabled,
  }) =>
      ServiceEntryEntity(
        unit: unit ?? this.unit,
        load: load ?? this.load,
        active: active ?? this.active,
        sub: sub ?? this.sub,
        description: description ?? this.description,
        isEnabled: isEnabled ?? this.isEnabled,
      );

  factory ServiceEntryEntity.fromJson(Map<String, dynamic> json) => ServiceEntryEntity(
        unit: json['unit'] as String? ?? '',
        load: json['load'] as String? ?? '',
        active: json['active'] as String? ?? '',
        sub: json['sub'] as String? ?? '',
        description: json['description'] as String? ?? '',
        isEnabled: json['isEnabled'] as bool? ?? false,
      );

  Map<String, dynamic> toJson() => {
        'unit': unit,
        'load': load,
        'active': active,
        'sub': sub,
        'description': description,
        'isEnabled': isEnabled,
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ServiceEntryEntity &&
          runtimeType == other.runtimeType &&
          unit == other.unit &&
          active == other.active &&
          sub == other.sub;

  @override
  int get hashCode => Object.hash(unit, active, sub);
}
