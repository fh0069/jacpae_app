import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/app_colors.dart';
import 'app_lock_controller.dart';

/// Full-screen biometric unlock gate.
/// Blocks back navigation via [PopScope].
class LockScreen extends ConsumerWidget {
  const LockScreen({super.key});

  Future<void> _authenticate(BuildContext context, WidgetRef ref) async {
    final biometricService = ref.read(biometricServiceProvider);
    final success = await biometricService.authenticate(
      reason: 'Confirma tu identidad para acceder',
    );

    if (success) {
      ref.read(appLockControllerProvider.notifier).unlock();
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No se pudo desbloquear')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Logo corporativo
                Image.asset(
                  'assets/images/logo.png',
                  height: 80,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 32),

                // Icono de candado
                const Icon(
                  Icons.lock_outline,
                  size: 64,
                  color: AppColors.primary,
                ),
                const SizedBox(height: 24),

                // Título
                Text(
                  'Desbloquear aplicación',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: AppColors.textPrimary,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),

                // Botón
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => _authenticate(context, ref),
                    icon: const Icon(Icons.fingerprint),
                    label: const Text('Desbloquear'),
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
