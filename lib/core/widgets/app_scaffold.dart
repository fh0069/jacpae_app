import 'package:flutter/material.dart';
import 'app_bottom_nav_bar.dart';
import 'info_bar.dart';

/// Scaffold wrapper corporativo que incluye:
/// - SafeArea para el contenido
/// - BottomNavigationBar (opcional, por defecto true)
/// - InfoBar en la parte inferior (opcional, por defecto true)
/// - Padding inferior automático para que el contenido no quede tapado
///
/// Uso:
/// ```dart
/// AppScaffold(
///   appBar: CustomAppBar(title: 'Título'),
///   body: MiContenido(),
///   showBottomNav: true,  // false para login
///   showInfoBar: true,    // false para login
/// )
/// ```
class AppScaffold extends StatelessWidget {
  final PreferredSizeWidget? appBar;
  final Widget body;
  final bool showBottomNav;
  final bool showInfoBar;
  /// Índice del tab seleccionado. Si es null, no hay selección (todos grises).
  final int? bottomNavIndex;
  final Widget? floatingActionButton;
  final FloatingActionButtonLocation? floatingActionButtonLocation;
  final Color? backgroundColor;

  const AppScaffold({
    super.key,
    this.appBar,
    required this.body,
    this.showBottomNav = true,
    this.showInfoBar = true,
    this.bottomNavIndex,
    this.floatingActionButton,
    this.floatingActionButtonLocation,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar,
      backgroundColor: backgroundColor,
      floatingActionButton: floatingActionButton,
      floatingActionButtonLocation: floatingActionButtonLocation,
      body: Column(
        children: [
          // Contenido principal (expandido)
          Expanded(
            child: body,
          ),

          // Bottom navigation bar (si está habilitada)
          if (showBottomNav)
            AppBottomNavBar(
              currentIndex: bottomNavIndex,
            ),

          // Info bar (si está habilitada)
          if (showInfoBar) const InfoBar(),
        ],
      ),
    );
  }
}
