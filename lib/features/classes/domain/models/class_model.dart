class AppClass {
  final String id;
  final String name;
  final String code; // El código corto para unirse (ej. "A3F8K")
  final String hostId; // El UID del maestro
  final List<String> memberIds; // Lista de UIDs de los alumnos

  AppClass({
    required this.id,
    required this.name,
    required this.code,
    required this.hostId,
    required this.memberIds,
  });

  factory AppClass.fromMap(Map<String, dynamic> map, String id) {
    return AppClass(
      id: id,
      name: map['name'] ?? '',
      code: map['code'] ?? '',
      hostId: map['hostId'] ?? '',
      memberIds: List<String>.from(map['memberIds'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'code': code,
      'hostId': hostId,
      'memberIds': memberIds,
    };
  }
}
