import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/firebase_class_repository.dart';
import '../../domain/models/class_model.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

// Proveedor del repositorio
final classRepositoryProvider = Provider((ref) => FirebaseClassRepository());

// Proveedor que escucha las clases del usuario actual en tiempo real
final userClassesProvider = StreamProvider<List<AppClass>>((ref) {
  final user = ref.watch(authStateProvider).value;
  final repository = ref.watch(classRepositoryProvider);

  if (user == null) {
    return Stream.value([]); // Si no hay usuario, no hay clases
  }

  return repository.getUserClasses(user.uid);
});
