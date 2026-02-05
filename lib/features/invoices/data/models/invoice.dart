/// Invoice model representing a customer invoice from the API
///
/// JSON structure from API:
/// ```json
/// {
///   "factura": "FV-XXXX-0001",
///   "fecha": "2026-01-01",
///   "base_imponible": 1000.0,
///   "importe_iva": 210.0,
///   "importe_total": 1210.0
/// }
/// ```
class Invoice {
  final String factura;
  final DateTime fecha;
  final double baseImponible;
  final double importeIva;
  final double importeTotal;

  const Invoice({
    required this.factura,
    required this.fecha,
    required this.baseImponible,
    required this.importeIva,
    required this.importeTotal,
  });

  factory Invoice.fromJson(Map<String, dynamic> json) {
    return Invoice(
      factura: json['factura'] as String,
      fecha: DateTime.parse(json['fecha'] as String),
      baseImponible: (json['base_imponible'] as num).toDouble(),
      importeIva: (json['importe_iva'] as num).toDouble(),
      importeTotal: (json['importe_total'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'factura': factura,
      'fecha': '${fecha.year}-${fecha.month.toString().padLeft(2, '0')}-${fecha.day.toString().padLeft(2, '0')}',
      'base_imponible': baseImponible,
      'importe_iva': importeIva,
      'importe_total': importeTotal,
    };
  }

  /// Formats the date as dd/MM/yyyy for display
  String get fechaFormatted {
    return '${fecha.day.toString().padLeft(2, '0')}/${fecha.month.toString().padLeft(2, '0')}/${fecha.year}';
  }

  /// Formats the total amount with 2 decimals and € symbol
  String get importeTotalFormatted {
    return '${importeTotal.toStringAsFixed(2)} €';
  }

  /// Formats the base amount with 2 decimals and € symbol
  String get baseImponibleFormatted {
    return '${baseImponible.toStringAsFixed(2)} €';
  }

  /// Formats the IVA amount with 2 decimals and € symbol
  String get importeIvaFormatted {
    return '${importeIva.toStringAsFixed(2)} €';
  }

  @override
  String toString() {
    return 'Invoice(factura: $factura, fecha: $fechaFormatted, total: $importeTotalFormatted)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Invoice && other.factura == factura;
  }

  @override
  int get hashCode => factura.hashCode;
}
