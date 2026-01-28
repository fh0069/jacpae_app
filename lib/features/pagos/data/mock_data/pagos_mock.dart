import '../models/pago.dart';

/// Mock pagos data for Phase 1
class PagosMock {
  static final List<Pago> pagos = [
    Pago(
      id: '1',
      concepto: 'Factura Enero 2026',
      monto: 150.00,
      estado: 'pendiente',
      fecha: DateTime.now().subtract(const Duration(days: 3)),
    ),
    Pago(
      id: '2',
      concepto: 'Factura Diciembre 2025',
      monto: 150.00,
      estado: 'pagado',
      fecha: DateTime.now().subtract(const Duration(days: 35)),
      metodoPago: 'Tarjeta de crédito',
    ),
    Pago(
      id: '3',
      concepto: 'Factura Noviembre 2025',
      monto: 150.00,
      estado: 'pagado',
      fecha: DateTime.now().subtract(const Duration(days: 65)),
      metodoPago: 'Transferencia bancaria',
    ),
  ];

  static Pago? getById(String id) {
    try {
      return pagos.firstWhere((p) => p.id == id);
    } catch (e) {
      return null;
    }
  }
}
