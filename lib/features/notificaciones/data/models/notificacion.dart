/// Notificacion model (mock data)
class Notificacion {
  final String id;
  final String titulo;
  final String mensaje;
  final DateTime fecha;
  final bool leida;
  final String tipo; // 'info', 'warning', 'error', 'success'

  const Notificacion({
    required this.id,
    required this.titulo,
    required this.mensaje,
    required this.fecha,
    required this.leida,
    required this.tipo,
  });
}
