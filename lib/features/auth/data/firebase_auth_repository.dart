import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../domain/models/user_model.dart';
import '../domain/repositories/auth_repository.dart';

class FirebaseAuthRepository implements AuthRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // --- Funciones Auxiliares Privadas ---
  String _generateEmail(String alias) {
    // Quita espacios y pone en minúsculas: "Juan Perez" -> "juanperez@kiva.app"
    final cleanAlias = alias.trim().toLowerCase().replaceAll(' ', '');
    return '$cleanAlias@kiva.app';
  }

  String _generatePassword(String pin) {
    // Firebase exige mínimo 6 caracteres, así que agregamos un sufijo fijo
    return '${pin}kiva';
  }

  Future<void> _saveLocalSession(AppUser user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('local_uid', user.uid);
    await prefs.setString('local_name', user.name);
    await prefs.setString('local_role', user.role);
  }
  // ------------------------------------

  @override
  Future<AppUser> loginWithAliasAndPin(String alias, String pin) async {
    try {
      final email = _generateEmail(alias);
      final password = _generatePassword(pin);

      UserCredential credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Obtener datos reales de Firestore
      final doc = await _firestore
          .collection('users')
          .doc(credential.user!.uid)
          .get();
      if (!doc.exists) {
        throw Exception('Usuario no encontrado en la base de datos.');
      }

      final user = AppUser.fromMap(doc.data()!, credential.user!.uid);
      await _saveLocalSession(user);

      return user;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found' || e.code == 'invalid-credential') {
        throw Exception('Alias o PIN incorrectos.');
      }
      throw Exception('Error al iniciar sesión: ${e.message}');
    }
  }

  @override
  Future<AppUser> registerWithAliasAndPin(
    String alias,
    String pin, {
    String role = 'alumno',
  }) async {
    try {
      final email = _generateEmail(alias);
      final password = _generatePassword(pin);

      UserCredential credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final newUser = AppUser(
        uid: credential.user!.uid,
        name: alias,
        role: role,
      );

      // Guardar en Firestore
      await _firestore
          .collection('users')
          .doc(newUser.uid)
          .set(newUser.toMap());
      await _saveLocalSession(newUser);

      return newUser;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        throw Exception('Este alias ya está en uso. Elige otro.');
      }
      throw Exception('Error al registrar: ${e.message}');
    }
  }

  // ==========================================
  // FLUJO PARA MAESTROS (CORREO Y CONTRASEÑA)
  // ==========================================

  @override
  Future<AppUser> loginWithEmail(String email, String password) async {
    try {
      UserCredential credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final doc = await _firestore
          .collection('users')
          .doc(credential.user!.uid)
          .get();
      if (!doc.exists) throw Exception('Usuario maestro no encontrado.');

      final user = AppUser.fromMap(doc.data()!, credential.user!.uid);
      await _saveLocalSession(user);
      return user;
    } on FirebaseAuthException {
      throw Exception('Error: Revisa tu correo o contraseña.');
    }
  }

  @override
  Future<AppUser> registerWithEmail(
    String name,
    String email,
    String password,
  ) async {
    try {
      UserCredential credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // 🔥 AQUÍ ESTÁ LA MAGIA: Forzamos el rol 'maestro'
      final newUser = AppUser(
        uid: credential.user!.uid,
        name: name,
        role: 'maestro',
      );

      await _firestore
          .collection('users')
          .doc(newUser.uid)
          .set(newUser.toMap());
      await _saveLocalSession(newUser);

      return newUser;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        throw Exception('Este correo ya está registrado.');
      }
      throw Exception('Error al registrar maestro: ${e.message}');
    }
  }

  @override
  Future<AppUser?> checkCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final uid = prefs.getString('local_uid');
    final name = prefs.getString('local_name');
    final role = prefs.getString('local_role');

    if (uid != null && name != null && role != null) {
      return AppUser(uid: uid, name: name, role: role);
    }
    return null;
  }

  @override
  Future<void> signOut() async {
    await _auth.signOut();
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
