import '../models/notificacion.dart';

/// Mock notificaciones data for Phase 1
class NotificacionesMock {
  static final List<Notificacion> notificaciones = [
    Notificacion(
      id: '1',
      titulo: 'Nueva factura disponible',
      mensaje: 'Su factura de enero ya está disponible para descargar',
      fecha: DateTime.now().subtract(const Duration(hours: 2)),
      leida: false,
      tipo: 'info',
    ),
    Notificacion(
      id: '2',
      titulo: 'Pago pendiente',
      mensaje: 'Tiene un pago pendiente por €150.00',
      fecha: DateTime.now().subtract(const Duration(days: 1)),
      leida: false,
      tipo: 'warning',
    ),
    Notificacion(
      id: '3',
      titulo: 'Consulta respondida',
      mensaje: 'Su consulta sobre facturación ha sido respondida',
      fecha: DateTime.now().subtract(const Duration(days: 2)),
      leida: true,
      tipo: 'success',
    ),
    Notificacion(
      id: '4',
      titulo: 'Mantenimiento programado',
      mensaje: 'Habrá mantenimiento el próximo sábado de 2am a 6am',
      fecha: DateTime.now().subtract(const Duration(days: 3)),
      leida: true,
      tipo: 'info',
    ),
    Notificacion(
      id: '5',
      titulo: 'Actualización de términos',
      mensaje: 'Hemos actualizado nuestros términos y condiciones',
      fecha: DateTime.now().subtract(const Duration(days: 7)),
      leida: true,
      tipo: 'info',
    ),
  ];
}
