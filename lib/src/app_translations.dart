/// Diccionario de traducciones para la aplicación UrbanSafe
class AppTranslations {
  static const Map<String, Map<String, String>> translations = {
    'es': {
      // General
      'app_title': 'UrbanSafe',
      'welcome': 'Bienvenido',
      'language': 'Idioma',
      'close': 'Cerrar',
      'confirm': 'Confirmar',
      'cancel': 'Cancelar',
      'error': 'Error',
      'success': 'Éxito',
      'loading': 'Cargando...',

      // Home Page
      'welcome_message': 'Bienvenido, ',
      'emergency_numbers': 'Números de emergencia',
      'share_screenshot': 'Compartir captura',
      'share_button': 'Compartir',
      'logout': 'Cerrar sesión',
      'history': 'Historial',
      'risk_high': 'Alto',
      'risk_low': 'Bajo',
      'risk_unknown': 'Desconocido',
      'risk_description_high': 'Riesgo alto en la zona',
      'risk_description_low': 'Riesgo bajo en la zona',
      'risk_message_high': 'PRECAUCIÓN: Se detecta alta probabilidad de incidencia delictiva en esta zona y hora',
      'risk_message_low': 'Zona con bajo riesgo histórico detectado',
      'score': 'Score',
      'screenshot_failed': 'No se pudo generar la captura.',
      'serenazgo': 'Serenazgo',
      'ambulance': 'Ambulancia',
      'police': 'Policía',
      'change_language': 'Cambiar idioma',
      'refresh': 'Consultar de nuevo',

      // Login Page
      'login_title': 'Iniciar sesión',
      'email': 'Correo electrónico',
      'password': 'Contraseña',
      'login_button': 'Iniciar sesión',
      'create_account': 'Crear una nueva cuenta',
      'forgot_password': '¿Olvidaste tu contraseña?',
      'email_password_required': 'Ingresa correo y contraseña',
      'email_required': 'Ingresa tu correo electrónico',
      'password_required': 'Ingresa tu contraseña',
      'no_account_found': 'No existe una cuenta con ese correo.',
      'account_without_password':
          'Cuenta encontrada pero sin contraseña almacenada. Contacta al administrador.',
      'incorrect_password': 'Contraseña incorrecta.',
      'google_signin': 'Iniciar sesión con Google',
      'login_error': 'Error al iniciar sesión',

      // Register Page
      'register_title': 'Crear cuenta',
      'full_name': 'Nombre completo',
      'phone': 'Teléfono',
      'register_button': 'Registrar',
      'already_have_account': '¿Ya tienes una cuenta?',
      'name_required': 'Ingresa tu nombre completo',
      'email_invalid': 'El correo electrónico no es válido',
      'password_short': 'La contraseña debe tener al menos 6 caracteres',
      'phone_required': 'Ingresa tu número de teléfono',
      'account_exists': 'Ya existe una cuenta con ese correo',
      'registration_error': 'Error al registrarse',
      'registration_success': 'Cuenta creada exitosamente',

      // History Page
      'history_title': 'Historial de mediciones',
      'no_measurements': 'No hay mediciones registradas',
      'date': 'Fecha',
      'risk_level': 'Nivel de riesgo',
      'location': 'Ubicación',
      'export_csv': 'Exportar a CSV',
      'export_success': 'Historial exportado exitosamente',
      'export_error': 'Error al exportar historial',
      'load_more': 'Cargar más',
      'latitude': 'Latitud',
      'longitude': 'Longitud',
      'date_format': 'dd/MM/yyyy HH:mm',

      // Profile Drawer
      'edit_profile': 'Editar Perfil',
      'name': 'Nombre',
      'email_non_editable': 'Correo (no editable)',
      'edit': 'Editar',
      'save': 'Guardar',
      'dark_mode': 'Modo oscuro',
      'profile_update_error': 'Error al actualizar el perfil',
      
      // Permissions
      'location_permission': 'Permiso de ubicación',
      'location_permission_message':
          'La aplicación necesita tu ubicación para determinar el nivel de riesgo',
      'allow': 'Permitir',
      'deny': 'Denegar',

      // Error messages
      'network_error': 'Error de conexión de red',
      'firebase_error': 'Error de base de datos',
      'unknown_error': 'Error desconocido',
      'please_try_again': 'Por favor, intenta de nuevo',

      // Toast messages
      'profile_updated': 'Perfil actualizado',
      'session_expired': 'Tu sesión ha expirado',
      'logout_success': 'Sesión cerrada exitosamente',
    },
    'en': {
      // General
      'app_title': 'UrbanSafe',
      'welcome': 'Welcome',
      'language': 'Language',
      'close': 'Close',
      'confirm': 'Confirm',
      'cancel': 'Cancel',
      'error': 'Error',
      'success': 'Success',
      'loading': 'Loading...',

      // Home Page
      'welcome_message': 'Welcome, ',
      'emergency_numbers': 'Emergency Numbers',
      'share_screenshot': 'Share Screenshot',
      'share_button': 'Share',
      'logout': 'Logout',
      'history': 'History',
      'risk_high': 'High',
      'risk_low': 'Low',
      'risk_unknown': 'Unknown',
      'risk_description_high': 'High risk in the area',
      'risk_description_low': 'Low risk in the area',
      'risk_message_high': 'CAUTION: High probability of criminal incidents detected in this area and time',
      'risk_message_low': 'Area with low historical risk detected',
      'score': 'Score',
      'screenshot_failed': 'Could not generate screenshot.',
      'serenazgo': 'Serenazgo',
      'ambulance': 'Ambulance',
      'police': 'Police',
      'change_language': 'Change Language',
      'refresh': 'Consult again',

      // Login Page
      'login_title': 'Sign In',
      'email': 'Email',
      'password': 'Password',
      'login_button': 'Sign In',
      'create_account': 'Create a new account',
      'forgot_password': 'Forgot your password?',
      'email_password_required': 'Enter email and password',
      'email_required': 'Enter your email address',
      'password_required': 'Enter your password',
      'no_account_found': 'No account found with that email.',
      'account_without_password':
          'Account found but without a stored password. Contact the administrator.',
      'incorrect_password': 'Incorrect password.',
      'google_signin': 'Sign in with Google',
      'login_error': 'Error signing in',

      // Register Page
      'register_title': 'Create Account',
      'full_name': 'Full Name',
      'phone': 'Phone',
      'register_button': 'Register',
      'already_have_account': 'Already have an account?',
      'name_required': 'Enter your full name',
      'email_invalid': 'The email address is not valid',
      'password_short': 'Password must be at least 6 characters',
      'phone_required': 'Enter your phone number',
      'account_exists': 'An account with that email already exists',
      'registration_error': 'Error registering',
      'registration_success': 'Account created successfully',

      // History Page
      'history_title': 'Measurement History',
      'no_measurements': 'No measurements recorded',
      'date': 'Date',
      'risk_level': 'Risk Level',
      'location': 'Location',
      'export_csv': 'Export to CSV',
      'export_success': 'History exported successfully',
      'export_error': 'Error exporting history',
      'load_more': 'Load More',
      'latitude': 'Latitude',
      'longitude': 'Longitude',
      'date_format': 'MM/dd/yyyy HH:mm',

      // Profile Drawer
      'edit_profile': 'Edit Profile',
      'name': 'Name',
      'email_non_editable': 'Email (not editable)',
      'edit': 'Edit',
      'save': 'Save',
      'dark_mode': 'Dark Mode',
      'profile_update_error': 'Error updating profile',
      
      // Permissions
      'location_permission': 'Location Permission',
      'location_permission_message':
          'The app needs your location to determine the risk level',
      'allow': 'Allow',
      'deny': 'Deny',

      // Error messages
      'network_error': 'Network connection error',
      'firebase_error': 'Database error',
      'unknown_error': 'Unknown error',
      'please_try_again': 'Please try again',

      // Toast messages
      'profile_updated': 'Profile updated',
      'session_expired': 'Your session has expired',
      'logout_success': 'Logged out successfully',
    },
  };

  /// Obtiene una traducción por clave en el idioma especificado
  static String get(String key, String languageCode) {
    return translations[languageCode]?[key] ?? translations['es']?[key] ?? key;
  }

  /// Obtiene los idiomas soportados
  static List<String> getSupportedLanguages() => translations.keys.toList();
}
