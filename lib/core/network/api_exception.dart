/// Custom API exceptions for handling specific HTTP error codes
///
/// Used to differentiate between:
/// - 401: Invalid/expired token
/// - 403: No customer profile or inactive user
/// - 503: Upstream service unavailable
sealed class ApiException implements Exception {
  final String message;
  final int statusCode;

  const ApiException({required this.message, required this.statusCode});

  @override
  String toString() => 'ApiException($statusCode): $message';
}

/// 401 - Unauthorized: Token invalid or expired
class UnauthorizedException extends ApiException {
  const UnauthorizedException({String? message})
      : super(
          message: message ?? 'Sesión caducada. Vuelve a iniciar sesión.',
          statusCode: 401,
        );
}

/// 403 - Forbidden: No customer profile or inactive user
class ForbiddenException extends ApiException {
  const ForbiddenException({String? message})
      : super(
          message: message ?? 'Tu usuario no tiene perfil asignado. Contacta con soporte.',
          statusCode: 403,
        );
}

/// 503 - Service Unavailable: Upstream dependency unavailable
class ServiceUnavailableException extends ApiException {
  const ServiceUnavailableException({String? message})
      : super(
          message: message ?? 'Servicio no disponible temporalmente. Intenta más tarde.',
          statusCode: 503,
        );
}

/// 409 - Conflict: PDF not yet generated
class PdfNotReadyException extends ApiException {
  const PdfNotReadyException({String? message})
      : super(
          message: message ?? 'El PDF aún no está generado. Inténtalo más tarde.',
          statusCode: 409,
        );
}

/// Generic API error for other status codes
class GenericApiException extends ApiException {
  const GenericApiException({required super.statusCode, String? message})
      : super(message: message ?? 'Error inesperado');
}
