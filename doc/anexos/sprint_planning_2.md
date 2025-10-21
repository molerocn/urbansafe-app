# Objetivo del sprint

Implementar las funcionalidades de gestión de historial, compartir información de riesgo y mejorar la personalización del sistema, garantizando que el usuario pueda acceder a información pasada, exportarla y contar con opciones avanzadas de interfaz y seguridad.

# Items seleccionados

- **HU11** – Compartir captura
- **HU12** – Almacenamiento de historial
- **HU13** – Consulta de historial
- **HU14** – Abrir en Google Maps
- **HU15** – Actualización de perfil
- **HU16** – Alertas de riesgo
- **HU17** – Exportación de historial
- **HU18** – Cambio de idioma
- **HU19** – Modo oscuro y claro
- **HU20** – Llamadas de emergencia

# Plan de ejecución

## Herramientas

- Backend: **Python con FastAPI**
- Modelo predictivo: **Google Colab** (entrenamiento y validación de alertas de riesgo)
- Base de datos: **Firebase** (persistencia de historial y configuración de usuario)
- Frontend: **React con TailwindCSS**
- Autenticación: **OAuth 2.0 (Google)** y **JWT**
- Control de versiones: **Git + GitHub**
- Gestión del proyecto: **Trello**

## Recursos

- **Equipo de desarrollo (5 devs)**

## Dependencias

- HU11 depende de HU10 (captura de pantalla implementada en Sprint 1).
- HU12 es prerequisito de HU13 (se consulta el historial solo si se guarda).
- HU13 es prerequisito de HU14 (abrir en Google Maps un registro del historial).
- HU16 requiere HU8 (cálculo de riesgo, completado en Sprint 1).
- HU17 depende de HU12 (necesita datos del historial para exportar).
- HU18 y HU19 son independientes, afectan únicamente la capa de interfaz.
- HU20 puede implementarse en paralelo, pero requiere acceso al sistema de llamadas del dispositivo.
