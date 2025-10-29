# UrbanSafe — Quick start

Prerequisitos
- Flutter SDK instalado y en PATH
- Android SDK / emulador o dispositivo físico
- (Opcional) Python 3.8+ para el servicio de predicción

Pasos rápidos
1) Obtener dependencias:

```powershell
flutter pub get
```

2) Ejecutar la app (emulador o dispositivo conectado):

```powershell
flutter run
```

3) Configurar Firebase (requisito):
- `firebase_options.dart` ya está presente (generado por FlutterFire). Revisa ese archivo si necesitas cambiar la configuración.

4) (Opcional) Ejecutar servicio de predicción localmente — sólo si se tiene un modelo implementado:

```powershell
cd ml_service
python -m pip install -r requirements.txt
uvicorn main:app --reload --port 8080
```

Nota: actualmente `ml_service/` contiene un scaffold FastAPI; el modelo de inferencia puede no estar implementado. Ejecutar este servicio si se ha añadido o integrado el modelo.

Notas operativas importantes
- Endpoints de predicción (cliente): configurables en `lib/src/app_constants.dart`:
  - `kPredictApiBase` (por defecto `http://10.0.2.2:8080` para emulador Android)
  - Rutas disponibles en el servidor: `/predict` y `/predict/risk` (ambas aceptan POST con JSON). El cliente intentará `/predict/risk` primero; el servidor ahora expone `/predict/risk` además de `/predict`, por lo que el "fallback" ya no es necesario cuando ambos están activos.
- Colecciones y campos en Firestore:
	- users: documentos de usuario. Campos usados por la app: `correo`, `passwordHash`, `sessionToken`, `sessionTokenExpiry` (Timestamp).
	- mediciones: colección donde se guardan las mediciones. Campos principales: `nivel_riesgo`, `nivel_riesgo_text`, `latitud`, `longitud`, `ubicacion_geo` (GeoPoint), `userId`, `user`, `fecha`.
- Claves locales (SharedPreferences): `kSessionUserIdKey` = `session_user_id`, `kSessionTokenKey` = `session_token`, `kLocationPermissionRequestedKey`.

Comportamiento de sesión
- Al iniciar sesión la app genera un token y lo guarda en Firestore junto con `sessionTokenExpiry` (ahora +15 minutos). La app también guarda el token y userId en SharedPreferences.
- Al arrancar la app, `_SessionRestorer` valida que el token local coincida con `sessionToken` en Firestore y que `sessionTokenExpiry` no haya expirado. Si es válido, la app abre Home automáticamente.
- Al cerrar sesión la app borra las claves locales y elimina `sessionToken` y `sessionTokenExpiry` del documento del usuario.

Dónde mirar el código
- `lib/screens/login_page.dart` — login y creación del token de sesión.
- `lib/screens/home_page.dart` — Home, petición de predicción, guardado automático de medición y logout.
- `lib/repositories/measurement_repository.dart` — lógica para persistir y leer la colección `mediciones`.
- `lib/models/risk_measurement.dart` — modelo y serialización de mediciones.
- `lib/src/app_constants.dart` — constantes relevantes (endpoints y keys).
- `ml_service/` — servicio FastAPI de predicción (opcional para pruebas locales).

Notas y recomendaciones
- Tokens actuales: expiración corta (15 min) pero generados en el cliente. Para producción se recomienda usar tokens server-issued o usar Firebase Auth.
- Para desarrollo en emulador Android `http://10.0.2.2:8080` si se ejecuta `ml_service` localmente.
