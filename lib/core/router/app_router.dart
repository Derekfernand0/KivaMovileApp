import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/providers/auth_provider.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
// 👇 Importamos la nueva pantalla Splash
import '../../features/auth/presentation/screens/splash_screen.dart';
import '../../features/classes/presentation/screens/dashboard_screen.dart';
import '../../features/classes/presentation/screens/class_detail_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    // 👇 1. Ahora la app arranca SIEMPRE en el splash screen
    initialLocation: '/splash',

    redirect: (context, state) {
      if (authState.isLoading) return null;

      final user = authState.value;
      final isLoggedIn = user != null;

      final isGoingToLogin = state.matchedLocation == '/login';
      final isGoingToSplash = state.matchedLocation == '/splash';

      // 👇 2. REGLA DE ORO: Si está en el splash, NO lo interrumpas. Deja que termine la animación.
      if (isGoingToSplash) return null;

      // Si no está logueado y no va al login, lo mandamos al login
      if (!isLoggedIn && !isGoingToLogin) return '/login';

      // Si ya está logueado y trata de ir al login, lo mandamos al dashboard
      if (isLoggedIn && isGoingToLogin) return '/dashboard';

      return null;
    },
    routes: [
      // 👇 3. Agregamos la ruta del Splash
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(
        path: '/dashboard',
        builder: (context, state) => const DashboardScreen(),
      ),
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
