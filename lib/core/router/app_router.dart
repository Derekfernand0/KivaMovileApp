import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/providers/auth_provider.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/splash_screen.dart';
import '../../features/classes/presentation/screens/dashboard_screen.dart';
import '../../features/classes/presentation/screens/class_detail_screen.dart';
import '../../features/auth/domain/models/user_model.dart';

final routerProvider = Provider<GoRouter>((ref) {
  // 🔥 1. Leemos el estado inicial SIN reconstruir el router a cada rato
  final authState = ref.read(authStateProvider);

  // 🔥 2. Creamos un Notifier silencioso para que GoRouter se entere de los cambios
  final authNotifier = ValueNotifier<AsyncValue<AppUser?>>(authState);

  ref.listen<AsyncValue<AppUser?>>(authStateProvider, (_, next) {
    authNotifier.value = next;
  });

  return GoRouter(
    initialLocation: '/splash',
    refreshListenable: authNotifier, // GoRouter reacciona a este Notifier
    redirect: (context, state) {
      final currentAuth = authNotifier.value;
      if (currentAuth.isLoading) return null;

      final user = currentAuth.value;
      final isLoggedIn = user != null;

      final isGoingToLogin = state.matchedLocation == '/login';
      final isGoingToSplash = state.matchedLocation == '/splash';

      // REGLA 1: Si la app acaba de abrir y está en el splash, déjala terminar su magia.
      if (isGoingToSplash) return null;

      // REGLA 2: Si no tiene sesión, mándalo al login
      if (!isLoggedIn && !isGoingToLogin) return '/login';

      // REGLA 3: Si ya tiene sesión, mándalo al dashboard
      if (isLoggedIn && isGoingToLogin) return '/dashboard';

      return null;
    },
    routes: [
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
