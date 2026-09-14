/// Domain entity representing a remote SFTP file or directory entry.
class FileEntryEntity {
  final String name;
  final String path;
  final bool isDirectory;
  final int size;
  final DateTime? modifiedTime;

  const FileEntryEntity({
    required this.name,
    required this.path,
    required this.isDirectory,
    required this.size,
    this.modifiedTime,
  });

  factory FileEntryEntity.fromJson(Map<String, dynamic> json) => FileEntryEntity(
        name: json['name'] as String? ?? '',
        path: json['path'] as String? ?? '',
        isDirectory: json['isDirectory'] as bool? ?? false,
        size: (json['size'] as num?)?.toInt() ?? 0,
        modifiedTime: json['modifiedTime'] != null ? DateTime.tryParse(json['modifiedTime'] as String) : null,
      );

  Map<String, dynamic> toJson() => {
        'name': name,
        'path': path,
        'isDirectory': isDirectory,
        'size': size,
        'modifiedTime': modifiedTime?.toIso8601String(),
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FileEntryEntity &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          path == other.path &&
          isDirectory == other.isDirectory &&
          size == other.size;

  @override
  int get hashCode => Object.hash(name, path, isDirectory, size);
}
