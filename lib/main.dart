import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart'; // Para inicializar Firebase
import 'firebase_options.dart'; // Archivo generado por FlutterFire CLI
import 'core/theme/app_theme.dart';
import 'core/router/app_router.dart';

void main() async {
  // Aseguramos que Flutter esté inicializado antes de ejecutar código nativo (Firebase)
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializamos Firebase con las opciones de la plataforma actual
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Envolvemos la app en ProviderScope para usar Riverpod
  runApp(const ProviderScope(child: KivaApp()));
}

// IMPORTANTE: Asegúrate de importar el router arriba:
// import 'core/router/app_router.dart';

class KivaApp extends ConsumerWidget {
  // 💡 Cambiamos StatelessWidget por ConsumerWidget
  const KivaApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 💡 Obtenemos el router que creamos
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      // 💡 Usamos .router en lugar de constructor normal
      title: 'Kiva App',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      debugShowCheckedModeBanner: false,

      // 💡 Configuramos el router
      routerConfig: router,
    );
  }
}
