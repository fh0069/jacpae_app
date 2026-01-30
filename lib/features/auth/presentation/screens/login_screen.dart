import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../data/providers/auth_provider.dart';

/// Login screen - Real authentication with Supabase
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final authService = ref.read(authServiceProvider);

      // Sign in with email and password
      await authService.signInWithPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      if (!mounted) return;

      // Refresh auth state and let router handle redirect
      ref.read(authStateProvider.notifier).refresh();

      // Router will automatically redirect to appropriate screen based on auth state
    } on AuthException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_getErrorMessage(e.message)),
            backgroundColor: AppColors.error,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al iniciar sesión: $e'),
            backgroundColor: AppColors.error,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  String _getErrorMessage(String message) {
    // Map common errors to Spanish
    if (message.contains('Invalid login credentials')) {
      return 'Credenciales inválidas. Verifica tu email y contraseña.';
    }
    if (message.contains('Email not confirmed')) {
      return 'Email no confirmado. Verifica tu correo.';
    }
    if (message.contains('User not found')) {
      return 'Usuario no encontrado.';
    }
    if (message.contains('Too many requests')) {
      return 'Demasiados intentos. Intenta más tarde.';
    }
    return message;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppConstants.spacingL),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Logo/App Name
                  Icon(
                    Icons.business,
                    size: 80,
                    color: AppColors.primary,
                  ),
                  const SizedBox(height: AppConstants.spacingM),
                  Text(
                    AppConstants.appName,
                    style: Theme.of(context).textTheme.displayMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppConstants.spacingS),
                  Text(
                    'Comunicación empresa-cliente',
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppConstants.spacingXL),

                  // Email field
                  CustomTextField(
                    label: 'Email',
                    hint: 'usuario@ejemplo.com',
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    prefixIcon: const Icon(Icons.email),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor ingrese su email';
                      }
                      if (!value.contains('@')) {
                        return 'Por favor ingrese un email válido';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: AppConstants.spacingM),

                  // Password field
                  CustomTextField(
                    label: 'Contraseña',
                    hint: '••••••••',
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    prefixIcon: const Icon(Icons.lock),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword ? Icons.visibility : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() => _obscurePassword = !_obscurePassword);
                      },
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor ingrese su contraseña';
                      }
                      if (value.length < 6) {
                        return 'La contraseña debe tener al menos 6 caracteres';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: AppConstants.spacingXL),

                  // Login button
                  CustomButton(
                    text: 'Iniciar Sesión',
                    onPressed: _handleLogin,
                    isLoading: _isLoading,
                  ),
                  const SizedBox(height: AppConstants.spacingM),

                  // Auth notice
                  Container(
                    padding: const EdgeInsets.all(AppConstants.spacingM),
                    decoration: BoxDecoration(
                      color: AppColors.info.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(AppConstants.radiusM),
                      border: Border.all(color: AppColors.info),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Icon(Icons.info_outline, color: AppColors.info, size: 20),
                            const SizedBox(width: AppConstants.spacingS),
                            Expanded(
                              child: Text(
                                'Autenticación segura con MFA',
                                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                      color: AppColors.info,
                                    ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppConstants.spacingS),
                        Text(
                          'Se requiere verificación en dos pasos (TOTP) para acceder a la aplicación',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppColors.info,
                              ),
                          textAlign: TextAlign.left,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
