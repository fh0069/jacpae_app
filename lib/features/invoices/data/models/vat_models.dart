// Models for the /invoices/vat-list endpoint
//
// JSON contract from backend:
// {
//   "items": [
//     {
//       "fecha_fra": "2025-01-15",
//       "num_fra": "SV-00333",
//       "base_imp": 932.88,
//       "tipo_iva": 21.0,
//       "cuota_iva": 195.9,
//       "tipo_recargo": 5.2,
//       "cuota_recargo": 0.0,
//       "imp_total": 1128.78
//     }
//   ],
//   "totals": {
//     "total_base": 64551.11,
//     "total_iva": 13555.72,
//     "total_recargo": 0.0,
//     "total_factura": 78106.83
//   }
// }
//
// Numeric fields (base_imp, tipo_iva, cuota_iva, tipo_recargo, cuota_recargo,
// imp_total, totals.*): contract A — never null, never omitted, 0.0 if not applicable.

/// A single VAT line item from the VAT invoice list
class VatItem {
  final DateTime fechaFra;
  final String numFra;
  final double baseImp;
  final double tipoIva;
  final double cuotaIva;
  final double tipoRecargo;
  final double cuotaRecargo;
  final double impTotal;

  const VatItem({
    required this.fechaFra,
    required this.numFra,
    required this.baseImp,
    required this.tipoIva,
    required this.cuotaIva,
    required this.tipoRecargo,
    required this.cuotaRecargo,
    required this.impTotal,
  });

  factory VatItem.fromJson(Map<String, dynamic> json) {
    return VatItem(
      fechaFra: DateTime.parse(json['fecha_fra'] as String),
      numFra: json['num_fra'] as String,
      baseImp: (json['base_imp'] as num).toDouble(),
      tipoIva: (json['tipo_iva'] as num).toDouble(),
      cuotaIva: (json['cuota_iva'] as num).toDouble(),
      tipoRecargo: (json['tipo_recargo'] as num).toDouble(),
      cuotaRecargo: (json['cuota_recargo'] as num).toDouble(),
      impTotal: (json['imp_total'] as num).toDouble(),
    );
  }

  /// Formats the invoice date as dd/MM/yyyy for display
  String get fechaFormatted {
    return '${fechaFra.day.toString().padLeft(2, '0')}/'
        '${fechaFra.month.toString().padLeft(2, '0')}/'
        '${fechaFra.year}';
  }

  /// Formats base_imp with 2 decimals and € symbol
  String get baseImpFormatted => '${baseImp.toStringAsFixed(2)} €';

  /// Formats tipo_iva as a percentage with 2 decimals
  String get tipoIvaFormatted => '${tipoIva.toStringAsFixed(2)} %';

  /// Formats tipo_recargo as a percentage with 2 decimals
  String get tipoRecargoFormatted => '${tipoRecargo.toStringAsFixed(2)} %';

  /// Formats cuota_iva with 2 decimals and € symbol
  String get cuotaIvaFormatted => '${cuotaIva.toStringAsFixed(2)} €';

  /// Formats cuota_recargo with 2 decimals and € symbol
  String get cuotaRecargoFormatted => '${cuotaRecargo.toStringAsFixed(2)} €';

  /// Formats imp_total with 2 decimals and € symbol
  String get impTotalFormatted => '${impTotal.toStringAsFixed(2)} €';

  @override
  String toString() =>
      'VatItem(numFra: $numFra, fecha: $fechaFormatted, total: $impTotalFormatted)';
}

/// Aggregated VAT totals from GET /invoices/vat-list
class VatTotals {
  final double totalBase;
  final double totalIva;
  final double totalRecargo;
  final double totalFactura;

  const VatTotals({
    required this.totalBase,
    required this.totalIva,
    required this.totalRecargo,
    required this.totalFactura,
  });

  factory VatTotals.fromJson(Map<String, dynamic> json) {
    return VatTotals(
      totalBase: (json['total_base'] as num).toDouble(),
      totalIva: (json['total_iva'] as num).toDouble(),
      totalRecargo: (json['total_recargo'] as num).toDouble(),
      totalFactura: (json['total_factura'] as num).toDouble(),
    );
  }

  /// Formats total_base with 2 decimals and € symbol
  String get totalBaseFormatted => '${totalBase.toStringAsFixed(2)} €';

  /// Formats total_iva with 2 decimals and € symbol
  String get totalIvaFormatted => '${totalIva.toStringAsFixed(2)} €';

  /// Formats total_recargo with 2 decimals and € symbol
  String get totalRecargoFormatted => '${totalRecargo.toStringAsFixed(2)} €';

  /// Formats total_factura with 2 decimals and € symbol
  String get totalFacturaFormatted => '${totalFactura.toStringAsFixed(2)} €';

  @override
  String toString() =>
      'VatTotals(totalBase: $totalBaseFormatted, totalIva: $totalIvaFormatted, totalFactura: $totalFacturaFormatted)';
}

/// Full VAT invoice list response from GET /invoices/vat-list
class VatResponse {
  final List<VatItem> items;
  final VatTotals totals;

  const VatResponse({
    required this.items,
    required this.totals,
  });

  factory VatResponse.fromJson(Map<String, dynamic> json) {
    final rawItems = json['items'] as List<dynamic>;
    return VatResponse(
      items: rawItems
          .map((e) => VatItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      totals: VatTotals.fromJson(json['totals'] as Map<String, dynamic>),
    );
  }

  @override
  String toString() =>
      'VatResponse(items: ${items.length}, totalFactura: ${totals.totalFacturaFormatted})';
}
