// el docente quiere 20
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
      "El sistema confirma el registro exitoso"
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
      "El inicio de sesión exitoso lleva al usuario a la pantalla principal"
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
      "El inicio de sesión exitoso lleva al usuario a la pantalla principal"
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
      "No se puede acceder a información privada tras cerrar sesión"
    ),
  ),
  (
    nombre: "Recuperación de contraseña",
    actor: "Usuario",
    prioridad: 2,
    quiero: "Recuperar la contraseña mediante correo electrónico",
    para: "Recuperar acceso a la cuenta en caso de olvido",
    criterios: (
      "El sistema envía un enlace de recuperación al correo registrado",
      "El enlace permite restablecer la contraseña",
      "El sistema notifica al usuario sobre el éxito del proceso"
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
      "El sistema guarda la ubicación para el cálculo del riesgo"
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
      "La hora se almacena junto con la medición de riesgo"
    ),
  ),
  (
    nombre: "Cálculo de riesgo",
    actor: "Sistema",
    prioridad: 1,
    quiero: "Calcular el porcentaje de riesgo en una ubicación determinada",
    para: "Informar al usuario sobre el nivel de riesgo actual",
    criterios: (
      "El sistema utiliza latitud, longitud y hora para calcular el riesgo",
      "El cálculo se realiza en menos de 3 segundos"
    ),
  ),
  (
    nombre: "Mostrar riesgo",
    actor: "Sistema",
    prioridad: 1,
    quiero: "Mostrar el porcentaje de riesgo calculado",
    para: "Informar visualmente al usuario sobre su nivel de riesgo",
    criterios: (
      "El riesgo se muestra en porcentaje",
      "Se utiliza una interfaz clara y legible"
    ),
  ),
  (
    nombre: "Captura de pantalla",
    actor: "Usuario",
    prioridad: 2,
    quiero: "Tomar captura de pantalla del porcentaje de riesgo",
    para: "Guardar o compartir el resultado del cálculo",
    criterios: (
      "El sistema genera una imagen con el porcentaje de riesgo",
      "La captura refleja correctamente los datos mostrados"
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
      "La imagen enviada coincide con la captura realizada"
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
      "El historial puede consultarse posteriormente"
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
      "El usuario puede seleccionar mediciones individuales"
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
      "Se muestra la ubicación precisa del riesgo seleccionado"
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
      "Los cambios se reflejan inmediatamente en el perfil"
    ),
  ),
  (
    nombre: "Alertas de riesgo",
    actor: "Sistema",
    prioridad: 1,
    quiero: "Generar alertas cuando el porcentaje de riesgo supere un porcentaje de 80%",
    para: "Avisar al usuario sobre situaciones de alto riesgo",
    criterios: (
      "El sistema detecta automáticamente riesgos superiores al umbral",
      "Se notifica al usuario mediante alerta visual o sonora"
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
      "Los archivos exportados son legibles y completos"
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
      "El cambio de idioma se aplica de inmediato"
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
      "El modo seleccionado se mantiene entre sesiones"
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
      "Se inicia la llamada correctamente al número seleccionado"
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
    descripcion: "El tiempo de respuesta para mostrar el porcentaje de riesgo no debe superar los 3 segundos.",
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
  table_reqs_no_funcionales = table_reqs_no_funcionales + (
    [RNF#rindex],
    [#req.nombre],
    [#req.descripcion],
  )
},

