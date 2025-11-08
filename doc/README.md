# Tabla de requerimientos funcionales

1. Registro de usuario
2. Inicio de sesión
3. Inicio de sesión con Google
4. Cerrar sesión
5. Recuperación de contraseña
6. Captura de ubicación
7. Registro de hora
8. Cálculo de riesgo
9. Mostrar riesgo
10. Captura de pantalla
11. Compartir captura
12. Almacenamiento de historial
13. Consulta de historial
14. Abrir en google maps
15. Actualización de perfil
16. Alertas de riesgo
17. Exportación de historial
18. Cambio de idioma
19. Modo oscuro y claro
20. Llamadas de emergencia

# Relacion de casos de uso

```mermaid
mindmap((Casos<br/>de uso))
    Gestion de sesión de usuario
        Inicio de sesión
        Inicio de sesión con Google
        Cerrar sesión
        Recuperación de contraseña
    Gestión de riesgo
        Captura de ubicación
        Cálculo de riesgo
        Mostrar riesgo
        Alertas de riesgo
        Llamadas de emergencia
    Gestión del historial
        Registro de hora
        Almacenamiento de historial
        Consulta de historial
        Abrir en google maps
        Exportación de hisotrial
    Gestión de captura
        Captura de pantalla
        Compartir captura
    Gestión de usuario
        Registro de usuario
        Actualización de perfil de usuario
    Gestión de preferencias
        Cambio de idioma
        Modo oscuro y claro
```

# Diagrama de clase

```mermaid
classDiagram

    class Usuario {
        +int id
        +String nombre
        +STring correo
        +String password
        +rol enum ("admi", "user")
        +registrar()
        +iniciarSesion()
        +iniciarSesionGoogle()
        +cerrarSesion()
        +recuperarContraseña()
        +actualizarPerfil()
    }
    
    class Historial {
        +int id
        +Datetime fecha
        +exportarHistorial()
        +consultarHistorial()
        +abrirEnGoogleMaps()
    }

    class MedicionRiesgo {
        +int id
        +datetime hora
        +nivelRiesgo enum ("baja", "media", "alta")
        +capturarUbicacion()
        +registrarHora()
        +calcularRiesgo()
        +mostrarRiesgo()
    }

    class Ubicacion {
        +int id
        +double latitud
        +double longitud
    }

Usuario --> Historial
Historial --> MedicionRiesgo
MedicionRiesgo --> Ubicacion
```

# Modelado de base de datos

**Modelo lógico**

```mermaid
erDiagram
    Usuario {
        int id_usuario PK
        string nombre
        string correo
        string contraseña
        enum rol
        string foto
        string idioma
        string tema
    }

    Sesion {
        int id_sesion PK
        datetime fecha_inicio
        datetime fecha_fin
        int id_usuario FK
    }

    Historial {
        int id_historial PK
        datetime fecha
        int id_usuario FK
    }

    MedicionRiesgo {
        int id_medicion PK
        enum nivel_riesgo
        datetime fecha
        int id_historial FK
        int id_ubicacion FK
    }

    Ubicacion {
        int id_ubicacion PK
        decimal latitud
        decimal longitud
    }

    %% Relaciones
    Usuario ||--o{ Sesion : "1:N"
    Usuario ||--o{ Historial : "1:N"
    Historial ||--o{ MedicionRiesgo : "1:N"
    MedicionRiesgo ||--|| Ubicacion : "1:1"
```


**Modelo conceptual**
```mermaid
erDiagram
    Usuario ||--o{ Sesion : "crea"
    Usuario ||--o{ Historial : "registra"
    Historial ||--o{ MedicionRiesgo : "almacena"
    MedicionRiesgo ||--|| Ubicacion : "se ubica en"
```
