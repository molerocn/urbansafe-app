# Guía de Uso - Sistema de Cambio de Idioma en UrbanSafe

## Cómo Usar la Funcionalidad de Cambio de Idioma

### Para Usuarios

#### Cambiar el Idioma
1. Abre cualquier pantalla de la aplicación (Home, Login, Registro, Historial)
2. En la barra superior (AppBar), busca el icono de **globo terráqueo** 🌐
3. Toca el botón - la interfaz cambiará instantáneamente al otro idioma
4. El idioma se recuerda automáticamente para futuras sesiones

#### Idiomas Disponibles
- **Español (ES)** - Interfaz en español
- **Inglés (EN)** - Interface in English

#### Cambios Que Verás
- ✓ Títulos de pantallas
- ✓ Etiquetas de campos
- ✓ Botones de acciones
- ✓ Mensajes de error
- ✓ Números de emergencia
- ✓ Formato de fechas en el historial
- ✓ Descripciones de niveles de riesgo
- ✓ Todo el contenido de la aplicación

### Para Desarrolladores

#### Agregar Nueva Traducción

1. **Abre** `lib/src/app_translations.dart`

2. **Agrega la clave** en ambos idiomas:
```dart
static const Map<String, Map<String, String>> translations = {
  'es': {
    'mi_nueva_clave': 'Mi texto en español',
    ...
  },
  'en': {
    'mi_nueva_clave': 'My text in English',
    ...
  },
};
```

3. **Usa en tu widget**:
```dart
final lang = localization.currentLanguageCode;
Text(AppTranslations.get('mi_nueva_clave', lang))
```

#### Agregar Nuevo Idioma (Ej: Francés)

1. **Abre** `lib/src/app_translations.dart`

2. **Agrega el idioma** en el diccionario:
```dart
static const Map<String, Map<String, String>> translations = {
  'es': { /* ... */ },
  'en': { /* ... */ },
  'fr': {
    'app_title': 'UrbanSûr',
    'welcome': 'Bienvenue',
    // ... agregar todas las claves
  },
};
```

3. **Abre** `lib/main_firestore.dart`

4. **Agrega al supportedLocales**:
```dart
supportedLocales: const [
  Locale('es'),
  Locale('en'),
  Locale('fr'),  // Nuevo idioma
],
```

5. **Abre** `lib/services/localization_service.dart`

6. **Actualiza la constante** si es necesario:
```dart
static const String _defaultLanguage = 'es'; // Mantener español como defecto
```

#### Usar Traducciones en un Widget

**Ejemplo Básico:**
```dart
import 'package:provider/provider.dart';
import 'package:urbansafe/services/localization_service.dart';
import 'package:urbansafe/src/app_translations.dart';

@override
Widget build(BuildContext context) {
  final localization = context.watch<LocalizationService>();
  final lang = localization.currentLanguageCode;
  
  return Scaffold(
    appBar: AppBar(
      title: Text(AppTranslations.get('app_title', lang)),
    ),
    body: Center(
      child: Text(AppTranslations.get('welcome', lang)),
    ),
  );
}
```

**Con Botón para Cambiar Idioma:**
```dart
IconButton(
  icon: const Icon(Icons.language),
  onPressed: () async {
    await localization.toggleLanguage();
  },
  tooltip: AppTranslations.get('change_language', lang),
)
```

#### Formato de Fechas por Idioma

La fecha se formatea automáticamente:

**Español:** `14/11/2025 14:30` (dd/MM/yyyy HH:mm)
**Inglés:** `11/14/2025 14:30` (MM/dd/yyyy HH:mm)

```dart
String _formatDate(Timestamp? ts, String lang) {
  if (ts == null) return AppTranslations.get('date', lang);
  final dt = ts.toDate();
  final pattern = AppTranslations.get('date_format', lang);
  return DateFormat(pattern).format(dt);
}
```

### Estructura del Código

```
lib/
├── services/
│   └── localization_service.dart    # Servicio de idioma
├── src/
│   └── app_translations.dart        # Diccionario de traducciones
└── screens/
    ├── home_page.dart               # Traducido
    ├── login_page.dart              # Traducido
    ├── register_page.dart           # Traducido
    └── measurements_history_page.dart # Traducido
```

### Flujo de Datos

```
Usuario toca botón idioma
        ↓
LocalizationService.toggleLanguage()
        ↓
SharedPreferences.setString('app_language', newLang)
        ↓
notifyListeners()
        ↓
context.watch<LocalizationService>() detecta cambio
        ↓
Widget se reconstruye
        ↓
AppTranslations.get(key, newLang) retorna nuevo texto
        ↓
UI se actualiza
```

### API del Servicio de Localización

```dart
// Obtener idioma actual
String currentLanguageCode
// Retorna: 'es' o 'en'

// Cambiar idioma
Future<void> setLanguage(String languageCode)
// Ejemplos:
// await localization.setLanguage('en');
// await localization.setLanguage('es');

// Alternar entre idiomas
Future<void> toggleLanguage()
// Alterna entre el idioma actual y el otro

// Obtener nombre del idioma actual
String getCurrentLanguageName()
// Retorna: 'Español' o 'English' (en el idioma actual)

// Obtener nombre del otro idioma
String getOtherLanguageName()
// Retorna: 'English' o 'Español' (en el idioma actual)
```

### API del Diccionario de Traducciones

```dart
// Obtener traducción
static String get(String key, String languageCode)
// Ejemplos:
// AppTranslations.get('welcome', 'es');
// AppTranslations.get('welcome', 'en');
// Retorna: 'Bienvenido' o 'Welcome'

// Obtener idiomas soportados
static List<String> getSupportedLanguages()
// Retorna: ['es', 'en']
```

### Depuración

Para verificar el idioma actual en consola:
```dart
final localization = context.read<LocalizationService>();
print('Idioma: ${localization.currentLanguageCode}');
print('Nombre: ${localization.getCurrentLanguageName()}');
```

### Validaciones con Traducciones

```dart
_buildField(
  controller: _emailController,
  label: AppTranslations.get('email', lang),
  validator: (v) {
    if (v == null || v.isEmpty) {
      return AppTranslations.get('email_required', lang);
    }
    // ... más validaciones
  },
)
```

### Manejo de Errores Traducidos

```dart
ScaffoldMessenger.of(context).showSnackBar(
  SnackBar(
    content: Text(AppTranslations.get('screenshot_failed', lang)),
  ),
);
```

## Troubleshooting

### "Traducción no aparece"
- Verifica que la clave exista en `app_translations.dart`
- Asegúrate de usar `context.watch<LocalizationService>()`
- Limpia caché: `flutter clean`

### "Cambio de idioma no funciona"
- Verifica que `provider` esté en pubspec.yaml
- Asegúrate que MyApp está envuelto en ChangeNotifierProvider
- Comprueba que el widget está dentro de MaterialApp

### "Idioma no se recuerda"
- Verifica que SharedPreferences esté funciona
- Comprueba los permisos en Android/iOS
- Limpia datos de la app y reinicia

## Checklist para Nueva Funcionalidad

- [ ] Crear clave en `app_translations.dart` (español e inglés)
- [ ] Importar `AppTranslations` y `LocalizationService`
- [ ] Usar `context.watch<LocalizationService>()` en build
- [ ] Reemplazar strings hardcodeados por `AppTranslations.get(key, lang)`
- [ ] Agregar botón de idioma si es nueva pantalla
- [ ] Probar cambio de idioma
- [ ] Probar que los cambios se aplican en toda la pantalla
- [ ] Probar persistencia (cerrar y abrir app)

## Recursos

- Documentación de Provider: https://pub.dev/packages/provider
- Documentación de SharedPreferences: https://pub.dev/packages/shared_preferences
- Documentación de intl: https://pub.dev/packages/intl
- Flutter i18n: https://flutter.dev/docs/development/accessibility-and-localization/internationalization
