import '../models/user_model.dart';

abstract class AuthRepository {
  // --- Para Alumnos ---
  Future<AppUser> loginWithAliasAndPin(String alias, String pin);
  Future<AppUser> registerWithAliasAndPin(
    String alias,
    String pin, {
    String role = 'alumno',
  });

  // --- Para Maestros ---
  Future<AppUser> loginWithEmail(String email, String password);
  Future<AppUser> registerWithEmail(
    String name,
    String email,
    String password,
  ); // Se añade el nombre

  // --- Generales ---
  Future<AppUser?> checkCurrentUser();
  Future<void> signOut();
}
