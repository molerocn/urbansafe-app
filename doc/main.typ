#import "@local/utp-doc:1.0.0": *

#show: config.with(
  campus: [San Juan de Lurigancho],
  carrera: [Carrera de Ingeniería de Software],
  tipo_trabajo: [Proyecto de trabajo de investigación],
  title: [UrbanSafe-ML: Desarrollo de un modelo de machine learning y aplicación movil para mejorar la seguridad ciudadana mediante predicción de riesgo en el distrito del Callao],
  autores: (
    [Juan Carlos Molero Rojas],
  ),
  docentes: (
    [Effio Gonzales, Carlos Alberto],
  ),
  fecha: [Agosto, 2025],
  ciudad: [Lima, Perú],
  font-family: "Libertinus Serif",
  font-size: 12pt,
)

#outline(depth: 2)
#pagebreak()

// #outline(target: figure.where(kind: image), title: [Índice de figuras])
// #pagebreak()

// #outline(target: figure.where(kind: table), title: [Índice de tablas])
// #pagebreak()

// = Resumen
// #pagebreak()
// = Abstract
// #pagebreak()

#include "sections/1_empresa.typ"
#include "sections/2_alcance.typ"
#include "sections/3_elaboracion_desarrollo.typ"
#include "sections/4_objetivos_proyecto.typ"
#include "sections/5_definicion_requerimientos.typ"
#include "sections/6_analisis_situacion.typ"
#include "sections/7_planificacion.typ"

#bibliography("ref.bib", style: "apa")
#pagebreak()

= Anexos
