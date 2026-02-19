import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../data/providers/auth_provider.dart';

/// MFA Verification Screen - Verify TOTP code for existing factor
class MFAVerifyScreen extends ConsumerStatefulWidget {
  const MFAVerifyScreen({super.key});

  @override
  ConsumerState<MFAVerifyScreen> createState() => _MFAVerifyScreenState();
}

class _MFAVerifyScreenState extends ConsumerState<MFAVerifyScreen> {
  final _formKey = GlobalKey<FormState>();
  final _codeController = TextEditingController();

  bool _isLoading = true;
  bool _isVerifying = false;
  String? _error;
  String? _factorId;

  @override
  void initState() {
    super.initState();
    _loadMFAFactor();
  }

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _loadMFAFactor() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final authService = ref.read(authServiceProvider);
      final factorsResponse = await authService.getMFAFactors();

      // Get first TOTP factor
      final totpFactors = factorsResponse.totp;
      if (totpFactors.isEmpty) {
        // No factor found, redirect to enroll
        if (mounted) {
          context.go('/mfa/enroll');
        }
        return;
      }

      setState(() {
        _factorId = totpFactors.first.id;
        _isLoading = false;
      });
    } on AuthException catch (e) {
      setState(() {
        _error = e.message;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Error al cargar factores MFA: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _verify() async {
    if (!_formKey.currentState!.validate()) return;
    if (_factorId == null) return;

    setState(() {
      _isVerifying = true;
      _error = null;
    });

    try {
      final authService = ref.read(authServiceProvider);

      // Challenge and verify
      await authService.challengeAndVerifyMFA(
        factorId: _factorId!,
        code: _codeController.text.trim(),
      );

      // Refresh auth state and let router handle redirect
      ref.read(authStateProvider.notifier).refresh();

      // Router will automatically redirect to home once AAL2 is achieved
    } on AuthException catch (e) {
      setState(() {
        _error = 'Código inválido: ${e.message}';
        _isVerifying = false;
        _codeController.clear();
      });
    } catch (e) {
      setState(() {
        _error = 'Error al verificar código: $e';
        _isVerifying = false;
        _codeController.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Verificación de Seguridad'),
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
                      const SizedBox(height: AppConstants.spacingXL),

                      // Header
                      const Icon(
                        Icons.shield_outlined,
                        size: 80,
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
                        'Ingresa el código de 6 dígitos de tu aplicación autenticadora',
                        style: Theme.of(context).textTheme.bodyMedium,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: AppConstants.spacingXL),

                      // Code input
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
                          if (!RegExp(r'^\d+$').hasMatch(value)) {
                            return 'El código solo debe contener números';
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
                        text: 'Verificar',
                        onPressed: _verify,
                        isLoading: _isVerifying,
                      ),
                      const SizedBox(height: AppConstants.spacingXL),

                      // Info message
                      Container(
                        padding: const EdgeInsets.all(AppConstants.spacingM),
                        decoration: BoxDecoration(
                          color: AppColors.info.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(AppConstants.radiusM),
                          border: Border.all(color: AppColors.info),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.info_outline, color: AppColors.info, size: 20),
                            const SizedBox(width: AppConstants.spacingS),
                            Expanded(
                              child: Text(
                                'Abre tu aplicación autenticadora y busca el código para ${AppConstants.appName}',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: AppColors.info,
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
