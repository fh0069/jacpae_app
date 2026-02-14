import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../constants/app_constants.dart';
import '../theme/app_colors.dart';

/// Bottom navigation bar corporativo definitivo
///
/// Tabs: Inicio | Consultas | Avisos | Ajustes
///
/// Si [currentIndex] es null, no hay tab seleccionado (todos grises).
class AppBottomNavBar extends StatelessWidget {
  /// Índice del tab seleccionado. Si es null, no hay selección.
  final int? currentIndex;

  const AppBottomNavBar({
    super.key,
    this.currentIndex,
  });

  // Estilo compartido para labels
  static const _labelStyle = TextStyle(fontSize: 11);

  @override
  Widget build(BuildContext context) {
    // Si no hay selección, usamos widget custom con todos grises
    if (currentIndex == null) {
      return _buildNoSelectionBar(context);
    }

    return Container(
      // Sin sombra - flat design
      color: AppColors.surface,
      child: SafeArea(
        top: false,
        child: BottomNavigationBar(
          currentIndex: currentIndex!,
          elevation: 0,
          onTap: (index) => _onItemTapped(context, index),
          type: BottomNavigationBarType.fixed,
          backgroundColor: AppColors.surface,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: AppColors.textSecondary,
          selectedFontSize: 11,
          unselectedFontSize: 11,
          iconSize: 24,
          showSelectedLabels: true,
          showUnselectedLabels: true,
          selectedLabelStyle: _labelStyle,
          unselectedLabelStyle: _labelStyle,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: 'Inicio',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.folder_outlined),
              activeIcon: Icon(Icons.folder),
              label: 'Consultas',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.notifications_outlined),
              activeIcon: Icon(Icons.notifications),
              label: 'Avisos',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings_outlined),
              activeIcon: Icon(Icons.settings),
              label: 'Ajustes',
            ),
          ],
        ),
      ),
    );
  }

  /// Footer sin ningún tab seleccionado (todos grises)
  Widget _buildNoSelectionBar(BuildContext context) {
    const items = [
      {'icon': Icons.home_outlined, 'label': 'Inicio'},
      {'icon': Icons.folder_outlined, 'label': 'Consultas'},
      {'icon': Icons.notifications_outlined, 'label': 'Avisos'},
      {'icon': Icons.settings_outlined, 'label': 'Ajustes'},
    ];

    return Container(
      color: AppColors.surface,
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: kBottomNavigationBarHeight,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(items.length, (index) {
              final item = items[index];
              return Expanded(
                child: InkWell(
                  onTap: () => _onItemTapped(context, index),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        item['icon'] as IconData,
                        color: AppColors.textSecondary,
                        size: 24,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item['label'] as String,
                        maxLines: 1,
                        softWrap: false,
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }

  void _onItemTapped(BuildContext context, int index) {
    // Obtener la ruta destino según el índice
    final String targetRoute;
    switch (index) {
      case 0:
        targetRoute = AppConstants.homeRoute;
        break;
      case 1:
        targetRoute = AppConstants.consultasRoute;
        break;
      case 2:
        targetRoute = AppConstants.notificacionesRoute;
        break;
      case 3:
        targetRoute = AppConstants.ajustesRoute;
        break;
      default:
        return;
    }

    // Obtener la ruta actual
    final currentLocation = GoRouterState.of(context).uri.path;

    // Solo evitar navegar si ya estamos EXACTAMENTE en esa ruta
    // (permite navegar desde subrutas como /consultas/facturas a /consultas)
    if (currentLocation == targetRoute) return;

    // Navegar a la ruta destino
    context.go(targetRoute);
  }
}
