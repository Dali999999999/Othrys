/// Domain entity representing a Docker container on the remote server.
class DockerContainerEntity {
  final String id;
  final String names;
  final String image;
  final String status;
  final String state;
  final String ports;

  const DockerContainerEntity({
    required this.id,
    required this.names,
    required this.image,
    required this.status,
    required this.state,
    required this.ports,
  });

  bool get isRunning => state.toLowerCase() == 'running';

  factory DockerContainerEntity.fromJson(Map<String, dynamic> json) => DockerContainerEntity(
        id: json['ID'] as String? ?? json['id'] as String? ?? '',
        names: json['Names'] as String? ?? json['names'] as String? ?? '',
        image: json['Image'] as String? ?? json['image'] as String? ?? '',
        status: json['Status'] as String? ?? json['status'] as String? ?? '',
        state: json['State'] as String? ?? json['state'] as String? ?? 'unknown',
        ports: json['Ports'] as String? ?? json['ports'] as String? ?? '',
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'names': names,
        'image': image,
        'status': status,
        'state': state,
        'ports': ports,
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DockerContainerEntity &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          names == other.names &&
          image == other.image &&
          status == other.status &&
          state == other.state;

  @override
  int get hashCode => Object.hash(id, names, image, status, state);
}
