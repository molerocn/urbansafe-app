/// Constantes de la aplicación usadas en todo el código para evitar
const String kLocationPermissionRequestedKey = 'location_permission_requested';

/// iOS `NSLocationWhenInUseUsageDescription` message.
const String kLocationWhenInUseMessage =
    'Usamos tu ubicación para guardar mediciones de riesgo automáticamente cuando abres la aplicación.';

/// URL base para la API de predicción. Para emulador Android usar
const String kPredictApiBase = 'http://10.0.2.2:8080';

/// Endpoints principales de predicción. El cliente probará
const String kPredictRiskPath = '/predict/risk';
const String kPredictPath = '/predict';

/// Claves usadas para persistir la sesión del usuario.
const String kSessionUserIdKey = 'session_user_id';
const String kSessionTokenKey = 'session_token';

/// Tiempo de vida de la sesión en minutos. Los tokens emitidos al iniciar sesión expiran después de esta duración.
const int kSessionTokenTtlMinutes = 15;
