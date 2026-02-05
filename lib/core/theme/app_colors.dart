import 'package:flutter/material.dart';

/// App color palette - Colores corporativos JacPae
/// Basado en referencias visuales de Santiago Vargas S.A.
class AppColors {
  AppColors._();

  // ============================================
  // COLORES PRINCIPALES CORPORATIVOS
  // ============================================

  /// Azul corporativo (marca/navegación) - #00AEC7
  static const Color primary = Color(0xFF00AEC7);

  /// Naranja CTA (botones de acción) - #EB5C00
  static const Color accent = Color(0xFFEB5C00);

  // ============================================
  // FONDOS Y SUPERFICIES
  // ============================================

  /// Fondo general de la app - gris muy claro
  static const Color background = Color(0xFFF2F4F6);

  /// Superficies/Cards - blanco
  static const Color surface = Color(0xFFFFFFFF);

  // ============================================
  // TEXTOS
  // ============================================

  /// Texto principal - gris oscuro
  static const Color textPrimary = Color(0xFF2E2E2E);

  /// Texto secundario - gris medio
  static const Color textSecondary = Color(0xFF6B7280);

  /// Texto deshabilitado - gris claro
  static const Color disabled = Color(0xFFC7CCD1);

  // ============================================
  // ESTADOS
  // ============================================

  /// Error - rojo sobrio
  static const Color error = Color(0xFFD32F2F);

  /// Éxito - verde
  static const Color success = Color(0xFF4CAF50);

  /// Advertencia - naranja claro
  static const Color warning = Color(0xFFFFA726);

  /// Info - azul claro
  static const Color info = Color(0xFF2196F3);

  // ============================================
  // ALIASES (compatibilidad con código existente)
  // ============================================

  /// Alias de [accent] para compatibilidad
  static const Color secondary = accent;

  /// @deprecated Usar [primary] en su lugar
  static const Color primaryBlue = primary;

  /// @deprecated Usar [accent] en su lugar
  static const Color primaryOrange = accent;

  /// @deprecated Usar [disabled] en su lugar
  static const Color textDisabled = disabled;
}
