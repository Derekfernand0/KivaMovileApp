class AppUser {
  final String uid;
  final String name;
  final String role; // 'alumno', 'admin', 'maestro'

  AppUser({
    required this.uid,
    required this.name,
    this.role = 'alumno', // Por defecto todos entran como alumnos
  });

  // Para convertir fácilmente entre Firebase/Tu VPS y nuestra App
  factory AppUser.fromMap(Map<String, dynamic> map, String uid) {
    return AppUser(
      uid: uid,
      name: map['name'] ?? '',
      role: map['role'] ?? 'alumno',
    );
  }

  Map<String, dynamic> toMap() {
    return {'name': name, 'role': role};
  }
}
