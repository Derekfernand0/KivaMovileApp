import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/firebase_auth_repository.dart';
import '../../domain/models/user_model.dart';

final authRepositoryProvider = Provider((ref) => FirebaseAuthRepository());

final authStateProvider =
    StateNotifierProvider<AuthNotifier, AsyncValue<AppUser?>>((ref) {
      final repository = ref.watch(authRepositoryProvider);
      return AuthNotifier(repository);
    });

class AuthNotifier extends StateNotifier<AsyncValue<AppUser?>> {
  final FirebaseAuthRepository _repository;

  AuthNotifier(this._repository) : super(const AsyncValue.loading()) {
    checkSession();
  }

  Future<void> checkSession() async {
    state = const AsyncValue.loading();
    try {
      final user = await _repository.checkCurrentUser();
      state = AsyncValue.data(user);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> login(String alias, String pin) async {
    state = const AsyncValue.loading();
    try {
      final user = await _repository.loginWithAliasAndPin(alias, pin);
      state = AsyncValue.data(user);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> register(String alias, String pin) async {
    state = const AsyncValue.loading();
    try {
      final user = await _repository.registerWithAliasAndPin(alias, pin);
      state = AsyncValue.data(user);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  // --- Métodos para Maestros ---
  Future<void> loginTeacher(String email, String password) async {
    state = const AsyncValue.loading();
    try {
      final user = await _repository.loginWithEmail(email, password);
      state = AsyncValue.data(user);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> registerTeacher(
    String name,
    String email,
    String password,
  ) async {
    state = const AsyncValue.loading();
    try {
      final user = await _repository.registerWithEmail(name, email, password);
      state = AsyncValue.data(user);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}
