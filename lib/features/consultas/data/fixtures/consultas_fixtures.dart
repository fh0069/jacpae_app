import '../models/consulta.dart';

/// Sample consultas data (fixtures) — used while backend endpoint is pending.
class ConsultasFixtures {
  static final List<Consulta> consultas = [
    Consulta(
      id: '1',
      titulo: 'Consulta sobre facturación',
      descripcion: '¿Cuándo recibiré mi factura del mes de enero?',
      estado: 'pendiente',
      fecha: DateTime.now().subtract(const Duration(days: 2)),
    ),
    Consulta(
      id: '2',
      titulo: 'Problema con el servicio',
      descripcion: 'El servicio ha estado intermitente esta semana.',
      estado: 'en_proceso',
      fecha: DateTime.now().subtract(const Duration(days: 5)),
      respuesta: 'Estamos investigando el problema. Le mantendremos informado.',
    ),
    Consulta(
      id: '3',
      titulo: 'Solicitud de información',
      descripcion: 'Necesito información sobre los nuevos planes.',
      estado: 'resuelta',
      fecha: DateTime.now().subtract(const Duration(days: 10)),
      respuesta: 'Puede encontrar información sobre nuestros planes en...',
    ),
  ];

  static Consulta? getById(String id) {
    try {
      return consultas.firstWhere((c) => c.id == id);
    } catch (e) {
      return null;
    }
  }
}
