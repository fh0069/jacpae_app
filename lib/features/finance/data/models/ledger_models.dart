// Models for the /finance/ledger endpoint
//
// JSON contract from backend:
// {
//   "start_date": "2025-01-01",
//   "end_date": "2025-12-31",
//   "exercise_start_date": "2025-01-01",
//   "total_items": 103,
//   "items": [
//     {
//       "fecha": "2025-01-01",
//       "concepto": "Apertura Ejercicio",
//       "importe_debe": 6177.13,
//       "importe_haber": 0.0,
//       "saldo": 6177.13
//     }
//   ]
// }

/// A single line entry in the ledger
class LedgerItem {
  final DateTime fecha;
  final String concepto;
  final double importeDebe;
  final double importeHaber;
  final double saldo;

  const LedgerItem({
    required this.fecha,
    required this.concepto,
    required this.importeDebe,
    required this.importeHaber,
    required this.saldo,
  });

  factory LedgerItem.fromJson(Map<String, dynamic> json) {
    return LedgerItem(
      fecha: DateTime.parse(json['fecha'] as String),
      concepto: json['concepto'] as String,
      importeDebe: (json['importe_debe'] as num).toDouble(),
      importeHaber: (json['importe_haber'] as num).toDouble(),
      saldo: (json['saldo'] as num).toDouble(),
    );
  }

  /// Formats the date as dd/MM/yyyy for display
  String get fechaFormatted {
    return '${fecha.day.toString().padLeft(2, '0')}/${fecha.month.toString().padLeft(2, '0')}/${fecha.year}';
  }

  /// Formats importe_debe with 2 decimals and € symbol
  String get importeDebeFormatted => '${importeDebe.toStringAsFixed(2)} €';

  /// Formats importe_haber with 2 decimals and € symbol
  String get importeHaberFormatted => '${importeHaber.toStringAsFixed(2)} €';

  /// Formats saldo with 2 decimals and € symbol
  String get saldoFormatted => '${saldo.toStringAsFixed(2)} €';

  @override
  String toString() =>
      'LedgerItem(fecha: $fechaFormatted, concepto: $concepto, saldo: $saldoFormatted)';
}

/// Full response from GET /finance/ledger
class LedgerResponse {
  final DateTime startDate;
  final DateTime endDate;
  final DateTime exerciseStartDate;
  final int totalItems;
  final List<LedgerItem> items;

  const LedgerResponse({
    required this.startDate,
    required this.endDate,
    required this.exerciseStartDate,
    required this.totalItems,
    required this.items,
  });

  factory LedgerResponse.fromJson(Map<String, dynamic> json) {
    final rawItems = json['items'] as List<dynamic>;
    return LedgerResponse(
      startDate: DateTime.parse(json['start_date'] as String),
      endDate: DateTime.parse(json['end_date'] as String),
      exerciseStartDate:
          DateTime.parse(json['exercise_start_date'] as String),
      totalItems: json['total_items'] as int,
      items: rawItems
          .map((e) => LedgerItem.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  @override
  String toString() =>
      'LedgerResponse(startDate: $startDate, endDate: $endDate, totalItems: $totalItems)';
}
