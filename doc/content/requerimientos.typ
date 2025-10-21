#import "../content/authors.typ": autores

#let use_cases = ("sesion", "usuario", "riesgo", "historial", "compartir", "preferencias")
#let authors = autores.map(autor => autor.split(" ").at(0))

#let reqs_funcionales = (
  (
    nombre: "Registro de usuario",
    actor: "Usuario",
    prioridad: 1,
    quiero: "Registrar nuevos perfiles con correo electrónico y contraseña",
    para: "Crear una cuenta y acceder a la aplicación",
    criterios: (
      "El correo debe ser válido",
      "La contraseña debe cumplir con los requisitos de seguridad",
      "El sistema confirma el registro exitoso",
    ),
    modulo: "Usuario",
    use_case: use_cases.at(1),
    tasks: (
      (
        description: "Crear tabla de usuario en la base de datos",
        author: authors.at(0),
        estimation: 1,
      ),
      (
        description: "Implementar API de registro con validaciones",
        author: authors.at(0),
        estimation: 3,
      ),
      (
        description: "Pantalla de formulario de registro en frontend",
        author: authors.at(1),
        estimation: 2,
      ),
    ),
  ),
  (
    nombre: "Inicio de sesión",
    actor: "Usuario",
    prioridad: 1,
    quiero: "Iniciar sesión mediante correo electrónico y contraseña",
    para: "Acceder a la cuenta registrada",
    criterios: (
      "El sistema valida el correo y la contraseña",
      "El sistema notifica en caso de error",
      "El inicio de sesión exitoso lleva al usuario a la pantalla principal",
    ),
    modulo: "Autenticación",
    use_case: use_cases.at(0),
    tasks: (
      (
        description: "Implementar API de login con validación de credenciales",
        author: authors.at(2),
        estimation: 3,
      ),
      (
        description: "Diseñar formulario de inicio de sesión",
        author: authors.at(2),
        estimation: 2,
      ),
    ),
  ),
  (
    nombre: "Inicio de sesión con Google",
    actor: "Usuario",
    prioridad: 1,
    quiero: "Iniciar sesión utilizando una cuenta de Google",
    para: "Acceder a la aplicación de forma rápida sin registro adicional",
    criterios: (
      "El sistema permite autenticación vía Google",
      "El sistema crea un perfil nuevo si no existe",
      "El inicio de sesión exitoso lleva al usuario a la pantalla principal",
    ),
    modulo: "Autenticación",
    use_case: use_cases.at(0),
    tasks: (
      (
        description: "Integrar OAuth2 con Google y configurar credenciales",
        author: authors.at(3),
        estimation: 4,
      ),
      (
        description: "Mapear datos de perfil de Google al modelo de usuario",
        author: authors.at(3),
        estimation: 2,
      ),
    ),
  ),
  (
    nombre: "Cerrar sesión",
    actor: "Usuario",
    prioridad: 1,
    quiero: "Cerrar sesión de manera segura",
    para: "Proteger la información personal y la cuenta",
    criterios: (
      "El sistema finaliza la sesión correctamente",
      "No se puede acceder a información privada tras cerrar sesión",
    ),
    modulo: "Autenticación",
    use_case: use_cases.at(0),
    tasks: (
      (
        description: "Implementar endpoint de logout",
        author: authors.at(0),
        estimation: 2,
      ),
      (
        description: "Limpiar datos sensibles en cliente tras cerrar sesión",
        author: authors.at(1),
        estimation: 1,
      ),
    ),
  ),
  (
    nombre: "Cambio de contraseña",
    actor: "Usuario",
    prioridad: 2,
    quiero: "Cambiar la contraseña usando validación con correo electrónico",
    para: "Recuperar acceso a la cuenta en caso de olvido",
    criterios: (
      "El sistema envía un enlace de recuperación al correo registrado",
      "El enlace permite restablecer la contraseña",
      "El sistema notifica al usuario sobre el éxito del proceso",
    ),
    modulo: "Usuario",
    use_case: use_cases.at(0),
    tasks: (
      (
        description: "Implementar flujo de generación y verificación de códigos",
        author: authors.at(0),
        estimation: 3,
      ),
      (
        description: "Configurar servicio de envío de correos (SMTP/Provider)",
        author: authors.at(4),
        estimation: 2,
      ),
      (
        description: "Pantalla de restablecimiento de contraseña y validaciones",
        author: authors.at(4),
        estimation: 2,
      ),
    ),
  ),
  (
    nombre: "Captura de ubicación",
    actor: "Sistema",
    prioridad: 1,
    quiero: "Capturar la ubicación actual con latitud y longitud",
    para: "Calcular el riesgo según la ubicación del usuario",
    criterios: (
      "El sistema obtiene la latitud y longitud precisas",
      "El sistema guarda la ubicación para el cálculo del riesgo",
    ),
    modulo: "Geolocalización",
    use_case: use_cases.at(2),
    tasks: (
      (
        description: "Implementar obtención de geolocalización en cliente",
        author: authors.at(2),
        estimation: 3,
      ),
      (
        description: "Solicitar y gestionar permisos de ubicación",
        author: authors.at(2),
        estimation: 1,
      ),
      (
        description: "Guardar coordenadas en el servicio de backend",
        author: authors.at(3),
        estimation: 2,
      ),
    ),
  ),
  (
    nombre: "Registro de hora",
    actor: "Sistema",
    prioridad: 1,
    quiero: "Registrar la hora exacta de cada consulta de riesgo",
    para: "Tener un registro temporal preciso de cada medición",
    criterios: (
      "El sistema registra la hora del dispositivo",
      "La hora se almacena junto con la medición de riesgo",
    ),
    modulo: "Riesgo",
    use_case: use_cases.at(3),
    tasks: (
      (
        description: "Agregar campo de time a la entidad de medición",
        author: authors.at(0),
        estimation: 1,
      ),
    ),
  ),
  (
    nombre: "Cálculo de riesgo",
    actor: "Sistema",
    prioridad: 1,
    quiero: "Calcular el nivel de riesgo en una ubicación determinada",
    para: "Informar al usuario sobre el nivel de riesgo actual",
    criterios: (
      "El sistema utiliza latitud, longitud y hora para calcular el riesgo",
      "El cálculo se realiza en menos de 3 segundos",
    ),
    modulo: "Riesgo",
    use_case: use_cases.at(2),
    tasks: (
      (
        description: "Desplegar el modelo en el backend",
        author: authors.at(0),
        estimation: 4,
      ),
      (
        description: "Crear un endpoint para la comunicación con el modelo",
        author: authors.at(0),
        estimation: 2,
      ),
    ),
  ),
  (
    nombre: "Mostrar riesgo",
    actor: "Sistema",
    prioridad: 1,
    quiero: "Mostrar la categoría del riesgo calculado",
    para: "Informar visualmente al usuario sobre su nivel de riesgo",
    criterios: (
      "El riesgo se muestra en categoría baja, media, alta, muy alta",
      "Se utiliza una interfaz clara y legible",
    ),
    use_case: use_cases.at(2),
    modulo: "UI-Riesgo",
    tasks: (
      (
        description: "Diseñar componente visual para categoría de riesgo",
        author: authors.at(1),
        estimation: 2,
      ),
      (
        description: "Asegurar accesibilidad y contraste en la visualización",
        author: authors.at(1),
        estimation: 2,
      ),
    ),
  ),
  (
    nombre: "Captura de pantalla",
    actor: "Usuario",
    prioridad: 2,
    quiero: "Tomar captura de pantalla del nivel de riesgo",
    para: "Guardar o compartir el resultado del cálculo",
    criterios: (
      "El sistema genera una imagen con el nivel de riesgo",
      "La captura refleja correctamente los datos mostrados",
    ),
    modulo: "Compartir",
    use_case: use_cases.at(4),
    tasks: (
      (
        description: "Implementar función de captura en la vista de riesgo",
        author: authors.at(4),
        estimation: 2,
      ),
      (
        description: "Guardar imagen en almacenamiento local con metadatos",
        author: authors.at(4),
        estimation: 2,
      ),
    ),
  ),
  (
    nombre: "Compartir captura",
    actor: "Usuario",
    prioridad: 2,
    quiero: "Compartir la captura de pantalla a través de otras aplicaciones",
    para: "Permitir difundir la información de riesgo de manera rápida",
    criterios: (
      "El sistema abre opciones de compartir",
      "La imagen enviada coincide con la captura realizada",
    ),
    modulo: "Compartir",
    use_case: use_cases.at(4),
    tasks: (
      (
        description: "Integrar mecanismo de share intent / share sheet",
        author: authors.at(2),
        estimation: 2,
      ),
    ),
  ),
  (
    nombre: "Almacenamiento de historial",
    actor: "Sistema",
    prioridad: 1,
    quiero: "Almacenar un historial de mediciones de riesgo",
    para: "Mantener un registro de riesgos anteriores",
    criterios: (
      "Cada medición se guarda con fecha y ubicación",
      "El historial puede consultarse posteriormente",
    ),
    modulo: "Historial",
    use_case: use_cases.at(3),
    tasks: (
      (
        description: "Diseñar esquema de base de datos para historial",
        author: authors.at(2),
        estimation: 3,
      ),
      (
        description: "Implementar endpoints CRUD para historial",
        author: authors.at(2),
        estimation: 4,
      ),
    ),
  ),
  (
    nombre: "Consulta de historial",
    actor: "Usuario",
    prioridad: 2,
    quiero: "Consultar el historial de riesgos registrados",
    para: "Revisar mediciones pasadas y analizar tendencias",
    criterios: (
      "El sistema muestra la lista de mediciones previas",
      "El usuario puede seleccionar mediciones individuales",
    ),
    modulo: "Historial",
    use_case: use_cases.at(3),
    tasks: (
      (
        description: "Diseñar pantalla de listado de historial",
        author: authors.at(1),
        estimation: 2,
      ),
    ),
  ),
  (
    nombre: "Abrir en google maps",
    actor: "Usuario",
    prioridad: 2,
    quiero: "Abrir en Google Maps un elemento del historial de riesgos registrados",
    para: "Visualizar la ubicación de cada riesgo en un mapa interactivo",
    criterios: (
      "El sistema abre Google Maps en la ubicación correspondiente",
      "Se muestra la ubicación precisa del riesgo seleccionado",
    ),
    modulo: "Integraciones",
    use_case: use_cases.at(3),
    tasks: (
      (
        description: "Implementart API de Google Maps para abrir con coordenadas",
        author: authors.at(2),
        estimation: 1,
      ),
      (
        description: "Añadir opción en UI de historial para 'Abrir en Maps'",
        author: authors.at(2),
        estimation: 1,
      ),
    ),
  ),
  (
    nombre: "Actualización de perfil",
    actor: "Usuario",
    prioridad: 2,
    quiero: "Actualizar la información del perfil",
    para: "Mantener los datos del usuario actualizados",
    criterios: (
      "El sistema permite modificar nombre, correo y foto",
      "Los cambios se reflejan inmediatamente en el perfil",
    ),
    use_case: use_cases.at(1),
    modulo: "Usuario",
    tasks: (
      (
        description: "Diseñar formulario de edición de perfil",
        author: authors.at(0),
        estimation: 2,
      ),
      (
        description: "Implementar endpoints para actualización y subida de avatar",
        author: authors.at(0),
        estimation: 3,
      ),
      (
        description: "Validar datos y gestionar caché/refresh del perfil",
        author: authors.at(4),
        estimation: 2,
      ),
    ),
  ),
  (
    nombre: "Alertas de riesgo",
    actor: "Sistema",
    prioridad: 1,
    quiero: "Generar alertas cuando la categoría de riesgo sea muy alta",
    para: "Avisar al usuario sobre situaciones de alto riesgo",
    criterios: (
      "Se notifica al usuario mediante alerta sonora",
    ),
    modulo: "Notificaciones",
    use_case: use_cases.at(2),
    tasks: (
      (
        description: "Integrar sistema de notificaciones locales/push",
        author: authors.at(4),
        estimation: 4,
      ),
    ),
  ),
  (
    nombre: "Exportación de historial",
    actor: "Usuario",
    prioridad: 2,
    quiero: "Exportar el historial de riesgos a formatos CSV o PDF",
    para: "Guardar o compartir el historial fuera de la aplicación",
    criterios: (
      "El sistema genera archivos CSV o PDF con los datos del historial",
      "Los archivos exportados son legibles y completos",
    ),
    modulo: "Exportación",
    use_case: use_cases.at(3),
    tasks: (
      (
        description: "Implementar generador de CSV desde consultas de historial",
        author: authors.at(0),
        estimation: 2,
      ),
      (
        description: "Implementar exportación a PDF con layout legible",
        author: authors.at(0),
        estimation: 3,
      ),
      (
        description: "Agregar UI para seleccionar rango y formato de exportación",
        author: authors.at(1),
        estimation: 2,
      ),
    ),
  ),
  (
    nombre: "Cambio de idioma",
    actor: "Usuario",
    prioridad: 2,
    quiero: "Cambiar el idioma de la interfaz entre español e inglés",
    para: "Permitir usar la aplicación en el idioma preferido",
    criterios: (
      "El sistema actualiza todos los textos de la interfaz",
      "El cambio de idioma se aplica de inmediato",
    ),
    modulo: "Apariencia",
    use_case: use_cases.at(5),
    tasks: (
      (
        description: "Implementar sistema de internacionalización (i18n)",
        author: authors.at(3),
        estimation: 3,
      ),
      (
        description: "Traducir textos y configurar archivos de idioma",
        author: authors.at(3),
        estimation: 2,
      ),
    ),
  ),
  (
    nombre: "Modo oscuro y claro",
    actor: "Usuario",
    prioridad: 2,
    quiero: "Alternar entre modo oscuro y modo claro en la interfaz",
    para: "Adaptar la apariencia de la aplicación según preferencias visuales",
    criterios: (
      "El sistema cambia los colores de la interfaz",
      "El modo seleccionado se mantiene entre sesiones",
    ),
    modulo: "Apariencia",
    use_case: use_cases.at(5),
    tasks: (
      (
        description: "Implementar tema claro/oscuro en el sistema de estilos",
        author: authors.at(4),
        estimation: 3,
      ),
      (
        description: "Persistir la preferencia de tema por usuario",
        author: authors.at(4),
        estimation: 1,
      ),
      (
        description: "Probar contraste y accesibilidad en ambos modos",
        author: authors.at(4),
        estimation: 2,
      ),
    ),
  ),
  (
    nombre: "Llamadas de emergencia",
    actor: "Usuario",
    prioridad: 1,
    quiero: "Realizar llamadas a los números principales de emergencia",
    para: "Permitir contacto rápido con servicios de emergencia",
    criterios: (
      "El sistema permite seleccionar un número de emergencia",
      "Se inicia la llamada correctamente al número seleccionado",
    ),
    modulo: "Emergencias",
    use_case: use_cases.at(2),
    tasks: (
      (
        description: "Implementar acción que inicie llamada desde el dispositivo",
        author: authors.at(3),
        estimation: 2,
      ),
    ),
  ),
)

// el docente quiere 10
#let reqs_no_funcionales = (
  (
    nombre: "Compatibilidad con plataformas",
    descripcion: "La aplicación debe estar disponible para dispositivos Android e iOS.",
  ),
  (
    nombre: "Rendimiento",
    descripcion: "El tiempo de respuesta para mostrar el nivel de riesgo no debe superar los 3 segundos.",
  ),
  (
    nombre: "Seguridad de datos",
    descripcion: "Los datos de usuario deben ser almacenados de manera segura usando cifrado.",
  ),
  (
    nombre: "Compatibilidad de versiones",
    descripcion: "La aplicación debe ser compatible con versiones recientes y populares de Android e iOS.",
  ),
  (
    nombre: "Disponibilidad del sistema",
    descripcion: "La disponibilidad del sistema debe ser superior al 99% en horarios críticos.",
  ),
  (
    nombre: "Usabilidad",
    descripcion: "La interfaz debe ser intuitiva y fácil de usar para cualquier persona.",
  ),
  (
    nombre: "Eficiencia de recursos",
    descripcion: "La aplicación debe minimizar el consumo de batería al usar geolocalización.",
  ),
  (
    nombre: "Escalabilidad",
    descripcion: "El backend debe poder escalar para manejar múltiples usuarios simultáneamente.",
  ),
  (
    nombre: "Seguridad de la comunicación",
    descripcion: "La información enviada entre la app y el servidor debe ser transmitida mediante protocolo seguro HTTPS.",
  ),
  (
    nombre: "Accesibilidad",
    descripcion: "La aplicación debe ser accesible y cumplir normas básicas de accesibilidad (contraste de colores, tamaño de fuente ajustable).",
  ),
)

#let table_reqs_funcionales_1 = ()
#for i in range(10) {
  let req = reqs_funcionales.at(i)
  let rindex = i + 1
  table_reqs_funcionales_1 = table_reqs_funcionales_1 + (
    [RF#rindex],
    [#req.nombre],
    [*El sistema debe permitir* #lower(req.quiero)],
  )
},

#let table_reqs_funcionales_2 = ()
#for i in range(10, 20) {
  let req = reqs_funcionales.at(i)
  let rindex = i + 1
  table_reqs_funcionales_2 = table_reqs_funcionales_2 + (
    [RF#rindex],
    [#req.nombre],
    [*El sistema debe permitir* #lower(req.quiero)],
  )
},



#let table_reqs_no_funcionales = ()
#for i in range(reqs_no_funcionales.len()) {
  let req = reqs_no_funcionales.at(i)
  let rindex = i + 1
  table_reqs_no_funcionales = table_reqs_no_funcionales + ([RNF#rindex], [#req.nombre], [#req.descripcion])
},

