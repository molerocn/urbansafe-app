#import "@local/utp-doc:1.0.0" : apa-figure, pc

= Elaboración y desarrollo del proyecto
== Problemática y posibles soluciones // cada problema por lo menos 4 parrafos
=== Problemática y posibles soluciones 

De acuerdo con el Informe Técnico de Estadísticas de Seguridad Ciudadana del #pc[@inei2025], en Lima Metropolitana y el Callao cerca de 3,2 millones de personas fueron víctimas de algún hecho delictivo. En Juliaca, con una población de 300 mil habitantes, 113 mil personas aproximadamente sufrieron victimización en el periodo septiembre 2022–febrero 2023 #pc[@mestaschata2025]. Y en Puno, cuyo total está en torno a 151 mil habitantes, 56 mil personas fueron víctimas, mientras que 131 mil manifestaron sentirse inseguras #pc[@ojedatito2024]. Este contexto evidencia la necesidad de analizar los problemas actuales en diversos aspectos: 

=== Aspecto funcional 

#pc[@anton-chunga2025a], en su artículo Percepciones y realidades de la seguridad ciudadana, reporta que la percepción de inseguridad reduce la actividad económica, muchas microempresas suspendieron operaciones o reubicaron sus locales por temor a robos y extorsiones, afectando directamente su productividad y sostenibilidad. 

=== Aspecto de proceso 

La inseguridad ciudadana se encuentra estrechamente vinculada con la capacidad administrativa de las instituciones locales. #pc[@supoquispe2023], en un estudio aplicado a una municipalidad provincial de Arequipa con una muestra de 113 trabajadores ediles, concluyó que existe una relación significativa entre la gestión municipal y la seguridad ciudadana (r = 0.804; p < 0.05). Esto evidencia que las debilidades en la gestión de procesos municipales impactan directamente en la eficacia de las políticas de prevención y control del delito. 

=== Aspecto organizacional 

La capacidad de liderazgo institucional resulta determinante para enfrentar los problemas de inseguridad. #pc[@huamanhurtado2025], en un estudio aplicado a 35 serenos de la Municipalidad Distrital de Andrés Avelino Cáceres Dorregaray en Ayacucho, concluyeron que existe una correlación positiva significativa entre liderazgo y seguridad ciudadana, destacando que el liderazgo democrático basado en la escucha activa y la participación fortalece la gestión pública. Estos resultados evidencian que un liderazgo inclusivo mejora la confianza comunitaria y permite enfrentar de manera más efectiva problemáticas como violencia familiar, accidentes de tránsito, robos y hurtos. 

=== Aspecto tecnológico 

Aunque existen recursos informáticos básicos, la mayoría de entidades no aplica tecnologías predictivas. #pc[@mestaschata2025], en un estudio sobre seguridad en Juliaca, mostró que las instituciones carecían de sistemas que integren machine learning o aplicaciones móviles para anticipar riesgos, lo que genera una brecha tecnológica significativa en la gestión de la seguridad. 

=== Formulación del Problema General 

¿En qué medida el modelo de machine learning mejora la seguridad ciudadana en la región del Callao? 

Un problema relevante es la carencia de herramientas tecnológicas que permitan a los ciudadanos anticipar los riesgos en su entorno inmediato. En la actualidad, la información sobre la inseguridad llega de manera fragmentada o con retrasos, lo que obliga a las personas a tomar decisiones sin contar con datos confiables. Esto afecta directamente la capacidad de prevención y deja a muchos expuestos a situaciones de riesgo que podrían haberse evitado. 

Para atender esta situación, la aplicación móvil integrará un módulo de análisis predictivo basado en Machine Learning. Este módulo procesará los reportes ciudadanos y los datos históricos de inseguridad para identificar patrones, generar alertas y elaborar mapas dinámicos de riesgo. Con ello, será posible transformar datos aislados en información estratégica para la prevención de delitos. 

Gracias a esta funcionalidad, los ciudadanos podrán conocer con antelación qué áreas presentan mayor índice de incidentes y en qué horarios son más críticos. Esta información les permitirá modificar rutas, evitar zonas peligrosas y tomar decisiones más seguras en su vida cotidiana. La herramienta, además, fomentará un cambio de enfoque: de la reacción tardía hacia la prevención activa.

#pagebreak()
== Elaboración de Prototipos 

#apa-figure(
  image("../images/prototipos/prototipo_login.png", width: 80%),
  caption: [Prototipo de inicio de sesión (Elaboración propia)],
  label: "fig:prototipo_inicio_sesion"
)
#pagebreak()

#apa-figure(
  image("../images/prototipos/prototipo_registro.png", width: 80%),
  caption: [Prototipo de la pantalla registro (Elaboración propia)],
  label: "fig:prototipo_registro"
)
#pagebreak()

#apa-figure(
  image("../images/prototipos/prototipo_home.png", width: 80%),
  caption: [Prototipo de la pantalla principal (Elaboración propia)],
  label: "fig:prototipo_home"
)
#pagebreak()

#apa-figure(
  image("../images/prototipos/prototipo_calculo.png", width: 80%),
  caption: [Prototipo de la pantalla de cálculo de riesgo (Elaboración propia)],
  label: "fig:prototipo_calculo"
)

#pagebreak()
