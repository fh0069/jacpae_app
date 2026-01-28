/// Consulta model (mock data)
class Consulta {
  final String id;
  final String titulo;
  final String descripcion;
  final String estado; // 'pendiente', 'en_proceso', 'resuelta'
  final DateTime fecha;
  final String? respuesta;

  const Consulta({
    required this.id,
    required this.titulo,
    required this.descripcion,
    required this.estado,
    required this.fecha,
    this.respuesta,
  });
}
