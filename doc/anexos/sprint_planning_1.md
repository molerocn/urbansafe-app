# Objetivo del sprint

Implementar el flujo completo de autenticación de usuarios y sentar las bases para el cálculo de riesgo, garantizando que el sistema pueda registrar, calcular y mostrar información de riesgo de manera inicial.

# Items seleccionados

- HU1 - Registro de usuario
- HU2 - Inicio de sesión
- HU3 - Inicio de sesión con Google
- HU4 - Cerrar sesión
- HU5 - Recuperación de contraseña
- HU6 - Captura de ubicación
- HU7 - Registro de hora
- HU8 - Cálculo de riesgo
- HU9 - Mostrar riesgo
- HU10 - Captura de pantalla

# Plan de ejecución

## Herramientas

- Backend: Python con FastAPI
- Modelo predictivo: Google Colab
- Base de datos: Firebase
- Frontend: React con TailwindCSS
- Autenticación: OAuth 2.0 (Google) y JWT
- Control de versiones: Git + GitHub
- Gestión del proyecto: Trello

## Recursos

- Equipo de desarrollo (5 devs)

## Dependencias

- Biblioteca de autenticación de Google (Google Identity Platform)
- Librerías de geolocalización para la captura de ubicación
- Dependencia entre historias:
    - HU1 y HU2 deben estar completas antes de HU3 y HU4.
    - HU6 y HU7 son prerequisito para HU8 (Cálculo de riesgo).
    - HU8 es prerequisito para HU9 (Mostrar riesgo).
    - HU9 debe estar listo antes de HU10 (Captura de pantalla)