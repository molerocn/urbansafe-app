# Cloud Functions para UrbanSafe

Este directorio contiene las Cloud Functions de Firebase para UrbanSafe.

## Funciones Disponibles

### 1. `sendPasswordRecoveryEmail`
Función HTTP que envía códigos de recuperación de contraseña por email usando Gmail.

**Parámetros (JSON POST)**:
```json
{
  "email": "usuario@gmail.com",
  "code": "123456"
}
```

**Respuesta exitosa (200)**:
```json
{
  "message": "Email sent successfully"
}
```

### 2. `resetPassword`
Función callable que resetea la contraseña del usuario con validación del código.

**Parámetros**:
```javascript
{
  email: "usuario@gmail.com",
  code: "123456",
  newPassword: "nuevacontraseña123"
}
```

## Configuración (Usando Gmail)

### Requisitos Previos
1. Node.js 18+ instalado
2. Firebase CLI instalado (`npm install -g firebase-tools`)
3. Cuenta de Gmail (gratuita)

### Pasos de Configuración

1. **Instalar dependencias**:
```bash
cd functions
npm install
```

2. **Configurar Gmail (sin API key requerida)**:

#### Opción A: Usar Gmail App Password (RECOMENDADO)

1. Ve a https://myaccount.google.com/security
2. Habilita "Verificación en dos pasos" si no está habilitada
3. Luego ve a https://myaccount.google.com/apppasswords
4. Selecciona "Correo" y "Windows" (o tu dispositivo)
5. Google generará una contraseña de 16 caracteres
6. Copia esa contraseña
7. Ejecuta estos comandos en la terminal:
```bash
firebase functions:config:set gmail.email="tu-email@gmail.com"
firebase functions:config:set gmail.password="contraseña-de-16-caracteres"
```

#### Opción B: Usar cuenta de Gmail básica (menos seguro)
Si no quieres usar App Password, puedes usar tu contraseña de Gmail directamente:
```bash
firebase functions:config:set gmail.email="tu-email@gmail.com"
firebase functions:config:set gmail.password="tu-contraseña-de-gmail"
```

### Desarrollo Local

Para probar localmente con el emulador de Firebase:
```bash
npm run serve
```

Esto iniciará el emulador en `http://localhost:5001`

### Deploy a Producción

Para desplegar las funciones a Firebase:
```bash
npm run deploy
```

O directamente:
```bash
firebase deploy --only functions
```

### Ver Logs

Para ver los logs de las funciones en tiempo real:
```bash
npm run logs
```

## Verificar Configuración

Para verificar que las credenciales están configuradas correctamente:
```bash
firebase functions:config:get
```

Deberías ver algo como:
```json
{
  "gmail": {
    "email": "tu-email@gmail.com",
    "password": "tu-contraseña"
  }
}
```

## Notas de Seguridad

1. **CORS**: Las funciones tienen CORS habilitado para permitir llamadas desde la app Flutter. En producción, considera restringir a dominios específicos.
2. **Credenciales de Gmail**: Se almacenan de forma segura en Firebase Config, no en el código.
3. **App Passwords**: Es más seguro usar App Passwords que tu contraseña regular de Gmail.
4. **Validación**: Las funciones validan que `email` y `code` sean proporcionados.
5. **Hash de Contraseña**: En producción, usa bcrypt en lugar del hash SHA256 actual (ver línea `crypto.createHash`).

## Estructura de Firestore

La función espera que exista una colección `users` con estructura:
```
users/{userId}
  - correo: string (email del usuario)
  - passwordHash: string
  - ... otros campos

password_recovery/{userId}
  - code: string (código de recuperación)
  - email: string
  - createdAt: timestamp
  - expiresAt: timestamp (now + 15 minutos)
  - used: boolean
```

## Troubleshooting

### Error: "Gmail credentials not configured"
- Asegúrate de haber ejecutado ambos comandos:
  ```bash
  firebase functions:config:set gmail.email="..."
  firebase functions:config:set gmail.password="..."
  ```
- Verifica con `firebase functions:config:get`

### Error: "CORS policy"
- CORS está habilitado. Si sigues teniendo problemas, verifica que la URL sea correcta.

### Error: "Invalid login credentials"
- Verifica que estés usando una App Password, no tu contraseña regular
- Si usas autenticación de dos factores, debes usar App Password

### Email no llega
- Verifica que la dirección de correo sea correcta
- Comprueba la carpeta de spam/correo no deseado
- En los primeros envíos, Gmail podría marcar como spam; marcar como "no es spam" ayuda

## Próximas Mejoras

- [ ] Usar bcrypt para hash de contraseñas
- [ ] Añadir rate limiting para evitar abuso
- [ ] Soportar múltiples idiomas en los emails
- [ ] Añadir webhook para rastrear entregas de email
