import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_theme.dart';
import '../providers/auth_provider.dart';
import '../../domain/models/user_model.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  // Controladores para Alumnos
  final _aliasController = TextEditingController();
  final _pinController = TextEditingController();

  // Controladores para Maestros
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLogin = true;
  bool _isTeacherMode =
      false; // 🔥 Nuevo control para saber qué formulario mostrar

  @override
  void dispose() {
    _aliasController.dispose();
    _pinController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_isTeacherMode) {
      // VALIDACIÓN MAESTRO
      final name = _nameController.text.trim();
      final email = _emailController.text.trim();
      final password = _passwordController.text.trim();

      if (email.isEmpty || password.length < 6) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Ingresa un correo y contraseña válida (mín. 6 caracteres).',
            ),
          ),
        );
        return;
      }
      if (!_isLogin && name.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Por favor, ingresa tu nombre.')),
        );
        return;
      }

      if (_isLogin) {
        ref.read(authStateProvider.notifier).loginTeacher(email, password);
      } else {
        ref
            .read(authStateProvider.notifier)
            .registerTeacher(name, email, password);
      }
    } else {
      // VALIDACIÓN ALUMNO (Como lo teníamos antes)
      final alias = _aliasController.text.trim();
      final pin = _pinController.text.trim();

      if (alias.isEmpty || pin.length < 4) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Escribe tu Alias y un PIN de 4 números.'),
          ),
        );
        return;
      }

      if (_isLogin) {
        ref.read(authStateProvider.notifier).login(alias, pin);
      } else {
        ref.read(authStateProvider.notifier).register(alias, pin);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);

    ref.listen<AsyncValue<AppUser?>>(authStateProvider, (previous, next) {
      if (next is AsyncError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.error.toString().replaceAll('Exception: ', '')),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    });

    return AppTheme.buildWebBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 30.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 60),
                Center(
                      child: Image.asset(
                        'assets/images/kiva logo.png',
                        height: 120,
                        fit: BoxFit.contain,
                      ),
                    )
                    .animate()
                    .fadeIn(duration: 600.ms)
                    .scale(duration: 600.ms, curve: Curves.easeOutBack),
                const SizedBox(height: 40),
                Center(
                      child: Text(
                        '¡Bienvenidos!',
                        style: GoogleFonts.fredoka(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.kivaBlue,
                        ),
                      ),
                    )
                    .animate()
                    .fadeIn(delay: 300.ms, duration: 500.ms)
                    .slideY(begin: 0.2, end: 0),
                const SizedBox(height: 10),
                Center(
                      child: Text(
                        _isTeacherMode
                            ? (_isLogin ? 'Portal maestro' : 'Registro maestro')
                            : 'Hola de nuevo...',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.nunito(
                          fontSize: 18,
                          color: AppTheme.kivaPurple,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )
                    .animate()
                    .fadeIn(delay: 500.ms, duration: 500.ms)
                    .slideY(begin: 0.2, end: 0),
                const SizedBox(height: 50),
                Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.92),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppTheme.lineLight),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.06),
                            blurRadius: 18,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          if (_isTeacherMode) ...[
                            if (!_isLogin) ...[
                              TextField(
                                controller: _nameController,
                                decoration: _inputDeco(
                                  'Tu Nombre y Apellido',
                                  Icons.person,
                                ),
                              ),
                              const SizedBox(height: 16),
                            ],
                            TextField(
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              decoration: _inputDeco(
                                'Correo Electrónico',
                                Icons.email,
                              ),
                            ),
                            const SizedBox(height: 16),
                            TextField(
                              controller: _passwordController,
                              obscureText: true,
                              decoration: _inputDeco('Contraseña', Icons.lock),
                            ),
                          ] else ...[
                            TextField(
                              controller: _aliasController,
                              decoration: _inputDeco(
                                'Tu Alias (ej. Juan)',
                                Icons.face,
                              ),
                            ),
                            const SizedBox(height: 16),
                            TextField(
                              controller: _pinController,
                              keyboardType: TextInputType.number,
                              obscureText: true,
                              maxLength: 4,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                              ],
                              decoration: _inputDeco(
                                'PIN Secreto (4 números)',
                                Icons.dialpad,
                              ).copyWith(counterText: ''),
                            ),
                          ],
                        ],
                      ),
                    )
                    .animate()
                    .fadeIn(delay: 700.ms, duration: 500.ms)
                    .slideY(begin: 0.12, end: 0),
                const SizedBox(height: 40),
                ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.kivaPurple,
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        elevation: 5,
                      ),
                      onPressed: authState.isLoading ? null : _submit,
                      child: authState.isLoading
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.2,
                                color: Colors.white,
                              ),
                            )
                          : Text(
                              _isTeacherMode
                                  ? (_isLogin
                                        ? 'Entrar al portal maestro'
                                        : 'Crear cuenta de maestro')
                                  : (_isLogin ? 'Entrar' : 'Crear mi cuenta'),
                              style: GoogleFonts.fredoka(
                                fontSize: 20,
                                color: Colors.white,
                              ),
                            ),
                    )
                    .animate()
                    .fadeIn(delay: 900.ms, duration: 500.ms)
                    .scale(
                      delay: 900.ms,
                      duration: 500.ms,
                      curve: Curves.easeOutBack,
                    ),
                const SizedBox(height: 16),
                Center(
                  child: TextButton(
                    onPressed: () {
                      setState(() {
                        _isLogin = !_isLogin;
                      });
                    },
                    child: Text(
                      _isTeacherMode
                          ? (_isLogin
                                ? 'Registro maestro'
                                : 'Ya tengo cuenta de maestro')
                          : (_isLogin
                                ? '¿No tienes cuenta? Regístrate aquí'
                                : '¿Ya tienes cuenta? Entra aquí'),
                      style: GoogleFonts.nunito(
                        color: AppTheme.kivaPurple,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ).animate().fadeIn(delay: 1200.ms, duration: 500.ms),
                const SizedBox(height: 8),
                Center(
                  child: TextButton.icon(
                    onPressed: () {
                      setState(() {
                        _isTeacherMode = !_isTeacherMode;
                        _isLogin = true;
                      });
                    },
                    icon: Icon(
                      _isTeacherMode ? Icons.child_care : Icons.school,
                      color: AppTheme.inkLight,
                    ),
                    label: Text(
                      _isTeacherMode ? 'Soy un alumno' : 'Soy maestro',
                      style: GoogleFonts.nunito(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.inkLight,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ).animate().fadeIn(delay: 1300.ms, duration: 400.ms),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Pequeña función para no repetir código de diseño
  InputDecoration _inputDeco(String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: AppTheme.paperLight,
      prefixIcon: Icon(icon, color: Colors.grey),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(999)),
      contentPadding: const EdgeInsets.symmetric(vertical: 16),
    );
  }
}
