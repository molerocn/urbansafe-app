# Implementación de Cambio de Idioma - UrbanSafe

## Descripción General
Se ha implementado un sistema completo de internacionalización (i18n) que permite cambiar la interfaz de usuario entre español e inglés. El cambio de idioma se aplica a toda la aplicación incluyendo el historial de mediciones, y la preferencia se persiste en la memoria local.

## Archivos Creados

### 1. `lib/services/localization_service.dart`
Servicio central que gestiona el idioma de la aplicación usando `ChangeNotifier` para la reactividad.

**Funcionalidades:**
- Carga el idioma guardado en SharedPreferences al iniciar
- Permite cambiar el idioma de forma dinámica
- Notifica a todos los widgets observadores cuando cambia el idioma
- Persiste la preferencia de idioma localmente
- Métodos utilitarios para obtener nombres de idiomas

**Métodos principales:**
```dart
Future<void> setLanguage(String languageCode)  // Cambiar idioma
Future<void> toggleLanguage()                   // Alternar ES/EN
String getCurrentLanguageName()                 // Nombre del idioma actual
String getOtherLanguageName()                   // Nombre del otro idioma
```

### 2. `lib/src/app_translations.dart`
Diccionario centralizado de todas las traducciones en español e inglés.

**Contenido:**
- Traducciones completas para todas las pantallas:
  - Home Page (bienvenida, niveles de riesgo, botones)
  - Login Page (correo, contraseña, mensajes de error)
  - Register Page (registro, validaciones)
  - History Page (historial, exportación)
  - Números de emergencia y compartir
  - Mensajes generales y errores

**Idiomas soportados:** Español (es) e Inglés (en)

## Cambios en Archivos Existentes

### 1. `pubspec.yaml`
Se agregó la dependencia de `provider`:
```yaml
dependencies:
  provider: ^6.0.0
```

### 2. `lib/main_firestore.dart`
Cambios principales:
- Importación de `provider` y `localization_service`
- Envolvimiento de la app con `ChangeNotifierProvider` para gestionar el estado del idioma
- Configuración de `MaterialApp` con soporte para múltiples locales
- Escucha de cambios de idioma con `context.watch<LocalizationService>()`

### 3. `lib/screens/home_page.dart`
Internacionalización completa:
- Reemplazo de todos los strings hardcodeados por traducciones
- Botón de cambio de idioma en AppBar (icono de globo terráqueo)
- Métodos adaptados para recibir código de idioma
- Todas las descripciones de riesgo traducidas
- Números de emergencia traducidos

### 4. `lib/screens/measurements_history_page.dart`
Internacionalización del historial:
- Formato de fecha adaptado por idioma
- Traducciones de botones de exportación (CSV, PDF)
- Mensajes de error y éxito traducidos
- Diálogos de detalles con traducciones

### 5. `lib/screens/login_page.dart`
Cambios de internacionalización:
- Botón de cambio de idioma en AppBar
- Traducciones de etiquetas de formulario
- Mensajes de error localizados
- Subtítulo de bienvenida traducido

### 6. `lib/screens/register_page.dart`
Cambios de internacionalización:
- Botón de cambio de idioma en AppBar
- Etiquetas de campos traducidas
- Validaciones con mensajes en el idioma actual
- Confirmaciones de registro traducidas

## Cómo Funciona

### Flujo de Cambio de Idioma:
1. Usuario toca el botón de idioma (globo terráqueo) en la AppBar
2. Se ejecuta `localization.toggleLanguage()`
3. El servicio actualiza SharedPreferences
4. El `ChangeNotifier` notifica a todos los listeners
5. Los widgets que usan `context.watch<LocalizationService>()` se reconstruyen automáticamente
6. Toda la UI se actualiza con las nuevas traducciones

### Persistencia:
- La preferencia de idioma se guarda en SharedPreferences con la clave `app_language`
- Al reiniciar la app, se carga automáticamente el idioma guardado
- Si no hay preferencia guardada, se usa español por defecto

## Uso en Widgets

Para acceder a las traducciones en cualquier widget:

```dart
// En un StatefulWidget o StatelessWidget dentro de MaterialApp
final localization = context.watch<LocalizationService>();
final lang = localization.currentLanguageCode;

// Para obtener una traducción:
Text(AppTranslations.get('welcome', lang))

// Para cambiar idioma:
await localization.toggleLanguage();

// Para obtener nombre del idioma:
Text(localization.getCurrentLanguageName())
```

## Características Implementadas

✅ Cambio dinámico de idioma sin recargar la app
✅ Persistencia de preferencia de idioma
✅ Soporte para español e inglés
✅ Traducciones en todas las pantallas
✅ Formato de fecha adaptado por idioma
✅ Números de emergencia localizados
✅ Mensajes de error traducidos
✅ Validaciones con mensajes en idioma actual
✅ Estado reactivo con Provider
✅ Gestión centralizada de traducciones

## Estructura de Traducciones

Las traducciones están organizadas por categoría:
- **General**: Títulos, botones comunes
- **Home Page**: Interfaz principal
- **Login Page**: Autenticación
- **Register Page**: Registro
- **History Page**: Historial y exportación
- **Permissions**: Permisos de ubicación
- **Error messages**: Mensajes de error

## Próximas Mejoras (Opcionales)

1. Agregar más idiomas (Francés, Portugués, etc.)
2. Usar archivos JSON o YAML para traducciones (para mayor escalabilidad)
3. Integrar con `flutter_localizations` para componentes nativos de Material
4. Agregar animaciones al cambiar idioma
5. Traducciones para el backend (errores del servidor)

## Testing

Para probar la funcionalidad:
1. Iniciar la app en español (por defecto)
2. Navegar por las pantallas (home, historial, login, registro)
3. Tocar el botón de idioma en cualquier pantalla
4. Verificar que toda la UI se actualiza al inglés
5. Cerrar y reabrir la app para verificar persistencia
6. Repetir el ciclo para asegurar funcionamiento correcto
