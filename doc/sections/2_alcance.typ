#import "@local/utp-doc:1.0.0" : apa-figure

= Alcance de solución
== Descripción del proyecto a elaborar
El proyecto consiste en el desarrollo de una aplicación móvil orientada a los ciudadanos del Callao, cuyo objetivo es fortalecer la seguridad ciudadana a través del uso de herramientas digitales y modelos de Machine Learning. Esta solución busca proporcionar preventiva de la población y facilitar el acceso a datos claros mediante una interfaz intuitiva. 

La aplicación se plantea como una herramienta de fácil acceso, que funcione en dispositivos móviles y que permita a los ciudadanos consultar el nivel de riesgo en su entorno, recibir alertas preventivas y acceder a estadísticas simplificadas. Además, integra funciones como registro de usuarios, almacenamiento de historial, exportación de datos y soporte de accesibilidad tecnológica. 

En ese marco, la aplicación se compone de los siguientes módulos principales: 

- Módulo de autenticación y gestión de usuarios: permite registrar perfiles mediante correo electrónico o Google, iniciar y cerrar sesión de forma segura, recuperar contraseñas y actualizar datos del perfil. 
- Módulo de análisis predictivo: aplica modelos de Machine Learning para procesar los reportes ciudadanos y datos históricos, identificando patrones de inseguridad y generando mapas de riesgo. 
- Módulo de consultas y visualización: permite capturar la ubicación del usuario, calcular el nivel de riesgo en un área determinada, mostrar resultados de manera clara, consultar el historial de riesgos registrados, exportar reportes en formatos (CSV o PDF) y visualizar los resultados en mapas interactivos. 
- Módulo de alertas internas: muestra avisos dentro de la aplicación cuando el nivel de riesgo en una zona supera el umbral predefinido (80%), ayudando al ciudadano a identificar situaciones críticas en el momento de la consulta. 
- Módulo de personalización y accesibilidad: brinda la posibilidad de cambiar el idioma de la interfaz entre español o inglés, alternar entre los modos oscuro y claro y realizar llamadas rápidas a los números principales de emergencia desde la aplicación.

== Descripción de los procesos del negocio
El proyecto se centra en la interacción de los ciudadanos con una aplicación móvil que funciona como canal de consulta y prevención en temas de seguridad. La información procesada combina datos oficiales e históricos con técnicas de Machine Learning, lo que permite calcular el nivel de riesgo en una ubicación específica y generar mapas dinámicos de fácil interpretación. 

De esta manera, los usuarios pueden acceder a reportes simplificados y recibir alertas inmediatas cuando el riesgo en su entorno supera un umbral establecido, fortaleciendo la cultura de prevención y la participación ciudadana en la región del Callao.

#apa-figure(
  image("../images/diagrama_proceso.png"),
  caption: [Diagrama de proceso (Elaboración propia)],
  label: "fig:diagrama_proceso"
)

== Alcance general
El alcance general del proyecto es proporcionar una herramienta tecnológica accesible y de fácil uso para los ciudadanos del Callao, recibir alertas de seguridad y acceder a información confiable sobre zonas de riesgo en su entorno. Con ello, se busca fortalecer la cultura de prevención y participación ciudadana en temas de seguridad, contribuyendo a la reducción de delitos como la violencia psicológica, la violencia física y los hurtos. 

Al mismo tiempo, la aplicación generará información estructurada que servirá como insumo estratégico para las autoridades del Gobierno Regional en la planificación de políticas públicas de seguridad. Esto permitirá una gestión más eficiente de los recursos, una mejor toma de decisiones basada en datos y un vínculo más estrecho entre la población y las instituciones encargadas de velar por su protección.

== Limitaciones
Si bien la implementación de la aplicación móvil representa un avance significativo en la mejora de la seguridad ciudadana, el proyecto contempla ciertas limitaciones que deben ser consideradas desde su etapa inicial. Estas limitaciones están relacionadas tanto con factores tecnológicos como sociales, y pueden influir en el grado de éxito de la solución propuesta.

En primer lugar, se encuentra el alcance geográfico restringido, ya que está enfocado únicamente en el Callao, lo que limita la generalización a otros contextos. 

En segundo lugar, existe dependencia de la calidad de los datos históricos, pues la precisión del modelo predictivo se ve afectada por la consistencia y actualización de la información oficial disponible. 

Además, se observa la falta de evaluación a largo plazo, dado que no se asegura la sostenibilidad del impacto sin un plan de mantenimiento y actualización continua del sistema. 

De igual manera, se identifican riesgos tecnológicos y de privacidad, debido al manejo de datos sensibles como ubicación e historial de consultas, lo que exige medidas sólidas de seguridad digital. 

Finalmente, se reconoce una falta de evaluación institucional, ya que aún no está definido cómo las autoridades podrían integrar los resultados en sus planes de seguridad ciudadana. 

#pagebreak()
