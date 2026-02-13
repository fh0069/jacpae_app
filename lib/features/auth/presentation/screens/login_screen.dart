import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../data/providers/auth_provider.dart';

// Social media URLs
const String _instaUrl = 'https://www.instagram.com/jacpae';
const String _facebookUrl = 'https://www.facebook.com/josesantiagovargassa';
const String _linkedinUrl = 'https://www.linkedin.com/company/28881203';

// Support email
const String _supportEmail = 'francisco.henares@santiagovargas.com';

// Company info
const String _companyEmail = 'info@santiagovargas.com';
const String _companyWeb = 'www.santiagovargas.com';

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

  // ============================================
  // SYSTEM UI OVERLAY STYLES
  // ============================================
  static const _orangeStatusBar = SystemUiOverlayStyle(
    statusBarColor: Colors.transparent, // Transparente - pintamos nosotros
    statusBarIconBrightness: Brightness.light, // Iconos blancos
    statusBarBrightness: Brightness.dark, // Para iOS
  );

  static const _defaultStatusBar = SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
    statusBarBrightness: Brightness.light,
  );

  @override
  void initState() {
    super.initState();
    // Aplicar iconos blancos en status bar
    SystemChrome.setSystemUIOverlayStyle(_orangeStatusBar);
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    // Restaurar estilo neutro al salir
    SystemChrome.setSystemUIOverlayStyle(_defaultStatusBar);
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

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No se pudo abrir el enlace'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _launchSupportEmail() async {
    final Uri emailUri = Uri.parse('mailto:$_supportEmail');
    try {
      await launchUrl(emailUri, mode: LaunchMode.externalApplication);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('No se pudo abrir el cliente de correo: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusBarHeight = MediaQuery.of(context).padding.top;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: _orangeStatusBar,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: Column(
          children: [
            // ========== FRANJA NARANJA (status bar) ==========
            Container(
              width: double.infinity,
              height: statusBarHeight,
              color: AppColors.accent, // Naranja #EB5C00
            ),

            // ========== CONTENIDO PRINCIPAL ==========
            Expanded(
              child: SafeArea(
                top: false, // Ya pintamos la status bar manualmente
                child: Column(
                  children: [
                    // Main scrollable content
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppConstants.spacingL,
                          vertical: AppConstants.spacingM,
                        ),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              const SizedBox(height: AppConstants.spacingL),

                              // Logo
                              _buildLogo(),
                              const SizedBox(height: AppConstants.spacingM),

                              // Company name
                              Text(
                                'JOSÉ SANTIAGO VARGAS, S.A.',
                                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.textPrimary,
                                    ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: AppConstants.spacingM),

                              // Orange divider line
                              Center(
                                child: Container(
                                  width: 60,
                                  height: 3,
                                  decoration: BoxDecoration(
                                    color: AppColors.primaryOrange,
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                ),
                              ),
                              const SizedBox(height: AppConstants.spacingXL),

                              // Email/User field
                              CustomTextField(
                                label: 'USUARIO O EMAIL',
                                hint: 'usuario@ejemplo.com',
                                controller: _emailController,
                                keyboardType: TextInputType.emailAddress,
                                prefixIcon: const Icon(Icons.person),
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
                                label: 'CONTRASEÑA',
                                hint: '••••••••',
                                controller: _passwordController,
                                obscureText: _obscurePassword,
                                prefixIcon: const Icon(Icons.lock),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscurePassword
                                        ? Icons.visibility
                                        : Icons.visibility_off,
                                  ),
                                  onPressed: () {
                                    setState(() => _obscurePassword = !_obscurePassword);
                                  },
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Por favor ingrese su contraseña';
                                  }
                                  if (value.length < 10) {
                                    return 'La contraseña debe tener al menos 10 caracteres';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: AppConstants.spacingXL),

                              // Login button - Orange styled
                              CustomButton(
                                text: 'Iniciar Sesión',
                                onPressed: _handleLogin,
                                isLoading: _isLoading,
                                backgroundColor: AppColors.primaryOrange,
                              ),
                              const SizedBox(height: AppConstants.spacingM),

                              // Auth notice (MFA block - kept as is)
                              Container(
                                padding: const EdgeInsets.all(AppConstants.spacingM),
                                decoration: BoxDecoration(
                                  color: AppColors.info.withValues(alpha: 0.1),
                                  borderRadius:
                                      BorderRadius.circular(AppConstants.radiusM),
                                  border: Border.all(color: AppColors.info),
                                ),
                                child: Column(
                                  children: [
                                    Row(
                                      children: [
                                        const Icon(Icons.info_outline,
                                            color: AppColors.info, size: 20),
                                        const SizedBox(width: AppConstants.spacingS),
                                        Expanded(
                                          child: Text(
                                            'Autenticación segura con MFA',
                                            style: Theme.of(context)
                                                .textTheme
                                                .titleSmall
                                                ?.copyWith(
                                                  color: AppColors.info,
                                                ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: AppConstants.spacingS),
                                    Text(
                                      'Se requiere verificación en dos pasos (TOTP) para acceder a la aplicación',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(
                                            color: AppColors.info,
                                          ),
                                      textAlign: TextAlign.left,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: AppConstants.spacingL),

                              // Support text with clickable link
                              _buildSupportText(),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // Footer - always visible at bottom
                    _buildFooter(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogo() {
    // Try to load the logo asset, fallback to icon if not available
    return Image.asset(
      'assets/images/logo.png',
      height: 80,
      errorBuilder: (context, error, stackTrace) {
        // Fallback icon if logo.png is not found
        return const Icon(
          Icons.business,
          size: 80,
          color: AppColors.primaryOrange,
        );
      },
    );
  }

  Widget _buildSupportText() {
    // Simple centered text in white space between MFA block and footer
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppConstants.spacingM),
      child: Wrap(
        alignment: WrapAlignment.center,
        children: [
          Text(
            '¿No tienes cuenta o has olvidado la contraseña? ',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                ),
            textAlign: TextAlign.center,
          ),
          GestureDetector(
            onTap: _launchSupportEmail,
            child: Text(
              'Contacta con soporte.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.primary,
                    decoration: TextDecoration.underline,
                    decorationColor: AppColors.primary,
                  ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    // Altura uniforme para ambas franjas
    const double stripHeight = 35.0;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // ========== FRANJA SUPERIOR: RRSS ==========
        Container(
          width: double.infinity,
          height: stripHeight,
          color: const Color(0xFFEBFFFF), // Fondo claro cyan
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildSocialIcon(
                icon: Icons.camera_alt,
                url: _instaUrl,
                tooltip: 'Instagram',
              ),
              const SizedBox(width: 8),
              _buildSocialIcon(
                icon: Icons.facebook,
                url: _facebookUrl,
                tooltip: 'Facebook',
              ),
              const SizedBox(width: 8),
              _buildSocialIcon(
                customIcon: Container(
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  alignment: Alignment.center,
                  child: const Text(
                    'in',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      height: 1.0,
                    ),
                  ),
                ),
                url: _linkedinUrl,
                tooltip: 'LinkedIn',
              ),
            ],
          ),
        ),

        // ========== FRANJA INFERIOR: EMAIL + WEB ==========
        Container(
          width: double.infinity,
          height: stripHeight,
          color: AppColors.primary, // Azul corporativo #00AEC7
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: AppConstants.spacingM),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              GestureDetector(
                onTap: () => _launchUrl('mailto:$_companyEmail'),
                child: const Text(
                  _companyEmail,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const Text(
                '  •  ',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              GestureDetector(
                onTap: () => _launchUrl('https://$_companyWeb'),
                child: const Text(
                  _companyWeb,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSocialIcon({
    IconData? icon,
    Widget? customIcon,
    required String url,
    required String tooltip,
  }) {
    return IconButton(
      icon: customIcon ??
          Icon(
            icon!,
            size: 22,
            color: AppColors.primary, // Azul corporativo #00AEC7 (forzado)
          ),
      tooltip: tooltip,
      constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
      padding: const EdgeInsets.all(8),
      onPressed: url.isNotEmpty
          ? () async {
              final uri = Uri.parse(url);
              try {
                await launchUrl(uri, mode: LaunchMode.externalApplication);
              } catch (e) {
                // URL not configured yet
              }
            }
          : () {}, // Mantener activo visualmente aunque no haga nada
    );
  }
}
