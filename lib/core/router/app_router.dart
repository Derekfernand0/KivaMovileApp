import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/providers/auth_provider.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/classes/presentation/screens/dashboard_screen.dart';
// 👇 1. Agrega esta importación
import '../../features/classes/presentation/screens/class_detail_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: '/login',
    redirect: (context, state) {
      if (authState.isLoading) return null;
      final user = authState.value;
      final isLoggedIn = user != null;
      final isGoingToLogin = state.matchedLocation == '/login';

      if (!isLoggedIn && !isGoingToLogin) return '/login';
      if (isLoggedIn && isGoingToLogin) return '/dashboard';
      return null;
    },
    routes: [
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(
        path: '/dashboard',
        builder: (context, state) => const DashboardScreen(),
      ),
      // 👇 2. Agrega esta nueva ruta para la pantalla de la clase
      GoRoute(
        path: '/class/:id',
        builder: (context, state) {
          final classId = state.pathParameters['id']!;
          return ClassDetailScreen(classId: classId);
        },
      ),
    ],
  );
});
