import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../data/providers/auth_provider.dart';

/// MFA Enrollment Screen - Configure TOTP authenticator
class MFAEnrollScreen extends ConsumerStatefulWidget {
  const MFAEnrollScreen({super.key});

  @override
  ConsumerState<MFAEnrollScreen> createState() => _MFAEnrollScreenState();
}

class _MFAEnrollScreenState extends ConsumerState<MFAEnrollScreen> {
  final _formKey = GlobalKey<FormState>();
  final _codeController = TextEditingController();

  bool _isLoading = true;
  bool _isVerifying = false;
  String? _error;

  AuthMFAEnrollResponse? _enrollResponse;
  String? _factorId;
  String? _secret;

  @override
  void initState() {
    super.initState();
    _enrollTOTP();
  }

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _enrollTOTP() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final authService = ref.read(authServiceProvider);
      final response = await authService.enrollTOTP(
        issuer: AppConstants.appName,
      );

      setState(() {
        _enrollResponse = response;
        _factorId = response.id;
        _secret = response.totp?.secret;
        _isLoading = false;
      });
    } on AuthException catch (e) {
      setState(() {
        _error = e.message;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Error al configurar autenticación: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _verifyAndComplete() async {
    if (!_formKey.currentState!.validate()) return;
    if (_factorId == null) return;

    setState(() {
      _isVerifying = true;
      _error = null;
    });

    try {
      final authService = ref.read(authServiceProvider);

      // Create challenge
      final challengeId = await authService.createMFAChallenge(
        factorId: _factorId!,
      );

      // Verify code
      await authService.verifyMFA(
        factorId: _factorId!,
        challengeId: challengeId,
        code: _codeController.text.trim(),
      );

      // Refresh auth state and let router handle redirect
      ref.read(authStateProvider.notifier).refresh();

      // Router will automatically redirect to home once AAL2 is achieved
    } on AuthException catch (e) {
      setState(() {
        _error = 'Código inválido: ${e.message}';
        _isVerifying = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Error al verificar código: $e';
        _isVerifying = false;
      });
    }
  }

  void _copySecret() {
    if (_secret != null) {
      Clipboard.setData(ClipboardData(text: _secret!));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Código secreto copiado al portapapeles'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Configurar Autenticación'),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.all(AppConstants.spacingL),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Header
                      const Icon(
                        Icons.security,
                        size: 64,
                        color: AppColors.primary,
                      ),
                      const SizedBox(height: AppConstants.spacingM),
                      Text(
                        'Verificación en Dos Pasos',
                        style: Theme.of(context).textTheme.headlineSmall,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: AppConstants.spacingS),
                      Text(
                        'Configura tu aplicación de autenticación para mayor seguridad',
                        style: Theme.of(context).textTheme.bodyMedium,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: AppConstants.spacingXL),

                      // Instructions
                      Container(
                        padding: const EdgeInsets.all(AppConstants.spacingM),
                        decoration: BoxDecoration(
                          color: AppColors.info.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(AppConstants.radiusM),
                          border: Border.all(color: AppColors.info),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Pasos a seguir:',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    color: AppColors.info,
                                  ),
                            ),
                            const SizedBox(height: AppConstants.spacingS),
                            Text(
                              '1. Abre tu app autenticadora (Google Authenticator, Microsoft Authenticator, Authy, etc.)\n'
                              '2. Toca "+" o "Agregar cuenta"\n'
                              '3. Selecciona "Ingresar clave de configuración" o "Entrada manual"\n'
                              '4. Copia el código secreto de abajo y pégalo en la app\n'
                              '5. Ingresa el código de 6 dígitos que aparece',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: AppColors.info,
                                  ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppConstants.spacingXL),

                      // Secret Code (prominently displayed)
                      if (_secret != null) ...[
                        Container(
                          padding: const EdgeInsets.all(AppConstants.spacingL),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(AppConstants.radiusL),
                            border: Border.all(color: AppColors.primary, width: 2),
                          ),
                          child: Column(
                            children: [
                              Text(
                                'CÓDIGO SECRETO',
                                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                              const SizedBox(height: AppConstants.spacingM),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: AppConstants.spacingM,
                                  vertical: AppConstants.spacingS,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(AppConstants.radiusM),
                                ),
                                child: SelectableText(
                                  _secret!,
                                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                        fontFamily: 'monospace',
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 2,
                                      ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              const SizedBox(height: AppConstants.spacingM),
                              ElevatedButton.icon(
                                onPressed: _copySecret,
                                icon: const Icon(Icons.copy),
                                label: const Text('Copiar código secreto'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  foregroundColor: Colors.white,
                                ),
                              ),
                              const SizedBox(height: AppConstants.spacingS),
                              Text(
                                'Nombre de la cuenta: ${AppConstants.appName}',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: AppColors.textSecondary,
                                    ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: AppConstants.spacingXL),
                      ],

                      // Verification code input
                      CustomTextField(
                        label: 'Código de verificación',
                        hint: '000000',
                        controller: _codeController,
                        keyboardType: TextInputType.number,
                        prefixIcon: const Icon(Icons.password),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor ingrese el código';
                          }
                          if (value.length != 6) {
                            return 'El código debe tener 6 dígitos';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: AppConstants.spacingM),

                      // Error message
                      if (_error != null) ...[
                        Container(
                          padding: const EdgeInsets.all(AppConstants.spacingM),
                          decoration: BoxDecoration(
                            color: AppColors.error.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(AppConstants.radiusM),
                            border: Border.all(color: AppColors.error),
                          ),
                          child: Text(
                            _error!,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: AppColors.error,
                                ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const SizedBox(height: AppConstants.spacingM),
                      ],

                      // Verify button
                      CustomButton(
                        text: 'Verificar y Continuar',
                        onPressed: _verifyAndComplete,
                        isLoading: _isVerifying,
                      ),
                      const SizedBox(height: AppConstants.spacingM),

                      // Warning
                      Container(
                        padding: const EdgeInsets.all(AppConstants.spacingM),
                        decoration: BoxDecoration(
                          color: AppColors.warning.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(AppConstants.radiusM),
                          border: Border.all(color: AppColors.warning),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.warning, color: AppColors.warning, size: 20),
                            const SizedBox(width: AppConstants.spacingS),
                            Expanded(
                              child: Text(
                                'Guarda el código secreto en un lugar seguro',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: AppColors.warning,
                                    ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}
