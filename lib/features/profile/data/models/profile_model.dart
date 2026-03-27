// Model for customer_profiles (Supabase table).
//
// Supabase columns (all non-null):
//   avisar_factura_emitida  bool
//   avisar_reparto          bool
//   dias_aviso_reparto      int
//   avisar_giro             bool
//   dias_aviso_giro         int
//   recibir_ofertas         bool

/// Notification preferences for the authenticated customer.
class ProfileModel {
  final bool avisarFacturaEmitida;
  final bool avisarReparto;
  final int diasAvisoReparto;
  final bool avisarGiro;
  final int diasAvisoGiro;
  final bool recibirOfertas;

  const ProfileModel({
    required this.avisarFacturaEmitida,
    required this.avisarReparto,
    required this.diasAvisoReparto,
    required this.avisarGiro,
    required this.diasAvisoGiro,
    required this.recibirOfertas,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      avisarFacturaEmitida: json['avisar_factura_emitida'] as bool,
      avisarReparto: json['avisar_reparto'] as bool,
      diasAvisoReparto: json['dias_aviso_reparto'] as int,
      avisarGiro: json['avisar_giro'] as bool,
      diasAvisoGiro: json['dias_aviso_giro'] as int,
      recibirOfertas: json['recibir_ofertas'] as bool,
    );
  }

  /// Returns only the fields that can be updated by the client.
  Map<String, dynamic> toUpdateMap() {
    return {
      'avisar_factura_emitida': avisarFacturaEmitida,
      'avisar_reparto': avisarReparto,
      'dias_aviso_reparto': diasAvisoReparto,
      'avisar_giro': avisarGiro,
      'dias_aviso_giro': diasAvisoGiro,
      'recibir_ofertas': recibirOfertas,
    };
  }

  ProfileModel copyWith({
    bool? avisarFacturaEmitida,
    bool? avisarReparto,
    int? diasAvisoReparto,
    bool? avisarGiro,
    int? diasAvisoGiro,
    bool? recibirOfertas,
  }) {
    return ProfileModel(
      avisarFacturaEmitida: avisarFacturaEmitida ?? this.avisarFacturaEmitida,
      avisarReparto: avisarReparto ?? this.avisarReparto,
      diasAvisoReparto: diasAvisoReparto ?? this.diasAvisoReparto,
      avisarGiro: avisarGiro ?? this.avisarGiro,
      diasAvisoGiro: diasAvisoGiro ?? this.diasAvisoGiro,
      recibirOfertas: recibirOfertas ?? this.recibirOfertas,
    );
  }
}
