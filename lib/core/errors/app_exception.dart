class AppException implements Exception {
  final String message;
  final int? statusCode;

  AppException({required this.message, this.statusCode});

  @override
  String toString() => message;

  
  factory AppException.fromStatusCode(int? statusCode, String? serverMessage) {
    switch (statusCode) {
      case 400:
        return AppException(
          message: serverMessage ?? 'Données invalides',
          statusCode: 400,
        );
      case 401:
        return AppException(
          message: 'mauvais mot de passe. Veuillez vous reconnecter.',
          statusCode: 401,
        );
      case 404:
        return AppException(
          message: serverMessage ?? 'Ressource introuvable',
          statusCode: 404,
        );
      case 409:
        return AppException(
          message: serverMessage ?? 'Conflit — donnée déjà existante',
          statusCode: 409,
        );
      case 500:
        return AppException(
          message: 'Erreur serveur. Réessayez plus tard.',
          statusCode: 500,
        );
      default:
        return AppException(
          message: serverMessage ?? 'Une erreur est survenue',
          statusCode: statusCode,
        );
    }
  }

  // ── Erreur réseau (pas de connexion)
  factory AppException.network() {
    return AppException(
      message: 'Erreur réseau. Vérifiez votre connexion internet.',
    );
  }

  // ── Timeout
  factory AppException.timeout() {
    return AppException(
      message: 'Le serveur met trop de temps à répondre.',
    );
  }
}