import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Bottom navigation bar corporativo (mock)
///
/// Items: Inicio | Efectos | Ajustes | Perfil
/// Solo "Inicio" está activo, el resto muestra "Próximamente"
class AppBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int>? onTap;

  const AppBottomNavBar({
    super.key,
    this.currentIndex = 0,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      // Sin sombra - flat design
      color: AppColors.surface,
      child: SafeArea(
        top: false,
        child: BottomNavigationBar(
          currentIndex: currentIndex,
          elevation: 0, // Sin sombra
          onTap: (index) {
            if (index == 0) {
              // Solo Inicio está activo
              onTap?.call(index);
            } else {
              // Los demás muestran snackbar
              _showComingSoon(context, _getItemLabel(index));
            }
          },
          type: BottomNavigationBarType.fixed,
          backgroundColor: AppColors.surface,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: AppColors.textSecondary,
          selectedFontSize: 12,
          unselectedFontSize: 12,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: 'Inicio',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.account_balance_wallet_outlined),
              activeIcon: Icon(Icons.account_balance_wallet),
              label: 'Efectos',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings_outlined),
              activeIcon: Icon(Icons.settings),
              label: 'Ajustes',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person),
              label: 'Perfil',
            ),
          ],
        ),
      ),
    );
  }

  String _getItemLabel(int index) {
    switch (index) {
      case 1:
        return 'Efectos';
      case 2:
        return 'Ajustes';
      case 3:
        return 'Perfil';
      default:
        return '';
    }
  }

  void _showComingSoon(BuildContext context, String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature estará disponible próximamente'),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
