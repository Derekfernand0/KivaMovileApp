import 'package:flutter/material.dart';
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

    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: _isTeacherMode
                ? [
                    AppTheme.peach.withOpacity(0.3),
                    AppTheme.yellow.withOpacity(0.3),
                  ] // Color distinto para maestro
                : [
                    AppTheme.lilac.withOpacity(0.3),
                    AppTheme.blue.withOpacity(0.3),
                  ],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Card(
                  elevation: 8,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                    side: const BorderSide(color: AppTheme.lineLight, width: 1),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _isTeacherMode
                              ? (_isLogin
                                    ? 'Portal Maestro'
                                    : 'Registro Maestro')
                              : (_isLogin
                                    ? '¡Hola de nuevo!'
                                    : 'Crear mi cuenta'),
                          style: GoogleFonts.fredoka(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.ink2Light,
                          ),
                        ),
                        const SizedBox(height: 24),

                        // === FORMULARIO MAESTRO ===
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
                        ]
                        // === FORMULARIO ALUMNO ===
                        else ...[
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

                        const SizedBox(height: 24),

                        // BOTÓN PRINCIPAL
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _isTeacherMode
                                  ? AppTheme.yellow
                                  : AppTheme.pink,
                            ),
                            onPressed: authState.isLoading ? null : _submit,
                            child: authState.isLoading
                                ? const CircularProgressIndicator()
                                : Text(
                                    _isLogin ? 'Entrar' : 'Registrarme',
                                    style: GoogleFonts.fredoka(fontSize: 18),
                                  ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // ALTERNAR ENTRE LOGIN / REGISTRO
                        TextButton(
                          onPressed: () {
                            setState(() {
                              _isLogin = !_isLogin;
                            });
                          },
                          child: Text(
                            _isLogin
                                ? '¿No tienes cuenta? Regístrate aquí'
                                : '¿Ya tienes cuenta? Entra aquí',
                            style: GoogleFonts.nunito(
                              fontWeight: FontWeight.bold,
                              color: AppTheme.ringLight,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // BOTÓN PARA CAMBIAR ENTRE ALUMNO Y MAESTRO
                TextButton.icon(
                  onPressed: () {
                    setState(() {
                      _isTeacherMode = !_isTeacherMode;
                      _isLogin = true; // Reseteamos a Login al cambiar de modo
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
                    ),
                  ),
                ),
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
