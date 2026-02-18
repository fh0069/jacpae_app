import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_scaffold.dart';

/// Pantalla de Política de privacidad.
///
/// Carga el contenido desde [assets/legal/privacy.md].
/// Usa [AppScaffold] con [bottomNavIndex] 3 (Ajustes) para mantener el footer.
class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  static const _statusBarColor = Color(0xFFEB5C00);
  static const _appBarColor = Color(0xFFCDD1D5);

  static const _lightStatusBarStyle = SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    statusBarBrightness: Brightness.dark,
  );

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: _lightStatusBarStyle,
      child: AppScaffold(
        bottomNavIndex: 3,
        showInfoBar: false,
        body: Column(
          children: [
            _buildHeader(context, 'Política de privacidad'),
            Expanded(child: _buildBody()),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, String title) {
    final statusBarHeight = MediaQuery.of(context).padding.top;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: double.infinity,
          height: statusBarHeight,
          color: _statusBarColor,
        ),
        Container(
          width: double.infinity,
          height: kToolbarHeight,
          color: _appBarColor,
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
                tooltip: 'Volver',
                onPressed: () => context.pop(),
              ),
              Text(
                title,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                  fontSize: 20,
                ),
              ),
              Expanded(
                child: Center(
                  child: Image.asset(
                    'assets/images/logo.png',
                    height: 32,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              const SizedBox(width: 48),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBody() {
    return FutureBuilder<String>(
      future: rootBundle.loadString('assets/legal/privacy.md'),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError || !snapshot.hasData) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Text(
                'No se pudo cargar el contenido. Inténtalo de nuevo.',
                textAlign: TextAlign.center,
              ),
            ),
          );
        }
        return Markdown(
          data: snapshot.data!,
          selectable: true,
          softLineBreak: true,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        );
      },
    );
  }
}
