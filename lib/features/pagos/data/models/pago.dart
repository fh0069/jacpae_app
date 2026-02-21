/// Pago model
class Pago {
  final String id;
  final String concepto;
  final double monto;
  final String estado; // 'pendiente', 'pagado', 'rechazado'
  final DateTime fecha;
  final String? metodoPago;

  const Pago({
    required this.id,
    required this.concepto,
    required this.monto,
    required this.estado,
    required this.fecha,
    this.metodoPago,
  });
}
