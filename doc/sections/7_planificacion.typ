#import "@local/utp-doc:1.0.0": apa-figure
#import "../content/requerimientos.typ": (
  reqs_funcionales, table_reqs_funcionales_1, table_reqs_funcionales_2, table_reqs_no_funcionales, use_cases,
)

= Planificación

== Acta de constitución del proyecto
Revisar documento acta_constitucion.pdf

== Diagrama de Gantt
Revisar documento diagrama_gantt.xlsx

== Work Breakdown Structure
#apa-figure(
  image("../images/wbs.png"),
  caption: [Work Breakdown Structure (Elaboración propia)],
  label: "fig:wbs",
)

== Requerimientos del proyecto

#pagebreak()
=== Requerimientos funcionales
#apa-figure(
  table(
    align: left,
    columns: (10%, 30%, 60%),
    table.header([*Código*], [*Nombre*], [*Descripción*]),
    ..table_reqs_funcionales_1,
    table.hline(),
  ),
  caption: [Tabla de requerimientos funcionales - parte 1],
  label: "tab:requerimientos_funcionales_1",
)

#pagebreak()
#apa-figure(
  table(
    align: left,
    columns: (10%, 30%, 60%),
    table.header([*Código*], [*Nombre*], [*Descripción*]),
    ..table_reqs_funcionales_2,
    table.hline(),
  ),
  caption: [Tabla de requerimientos funcionales - parte 2],
  label: "tab:requerimientos_funcionales_2",
)

#pagebreak()
=== Requerimientos no funcionales
#apa-figure(
  table(
    align: left,
    columns: (10%, 30%, 60%),
    table.header([*Código*], [*Nombre*], [*Descripción*]),
    ..table_reqs_no_funcionales,
    table.hline(),
  ),
  caption: [Tabla de requerimientos no funcionales],
  label: "tab:requerimientos_funcionales",
)

== Project charter
Revisar documento project_charter.pdf

#pagebreak()
== Sprints

#for i in range(1, 5) {
  let index = str(i)
  apa-figure(
    image("../images/sprint_" + index + ".png"),
    caption: [Sprint backlog - #i (Elaboración propia)],
    label: "fig:sprint_" + index,
  )
}

#pagebreak()
== Historias de usuario

#for i in range(reqs_funcionales.len()) {
  let req = reqs_funcionales.at(i)
  let hindex = i + 1
  apa-figure(
    table(
      align: (x, y) => if (y == 0) {
        center
      } else {
        left
      },
      columns: (auto, auto),
      table.cell(colspan: 2)[*Tarjeta de historia de usuario*],
      [*Código*], [H#hindex],
      [*Nombre de la historia*], [#req.nombre],
      [*Prioridad en el negocio*],
      [
        #if req.prioridad == 1 [Alta] else if req.prioridad == 2 [Media] else [Baja]
      ],
      [*Como*], [#req.actor],
      [*Quiero*], [#req.quiero],
      [*Para poder*], [#req.para],
      [*Criterios de aceptación*], { for criterio in req.criterios [\* #criterio \ ] },
      table.hline(),
    ),
    caption: [Tarjeta de historia de usuario H#hindex (Elaboración propia)],
  )
  if (calc.even(hindex) and hindex != reqs_funcionales.len()) {
    pagebreak()
  }
}

#include "../anexos/pila_producto.typ"

#pagebreak()
== Casos de uso

#for use_case in use_cases {
  apa-figure(
    image("../images/diagrams/cu_gestion_" + use_case + ".png", width: 90%),
    caption: [Caso de uso gestión "#use_case" (Elaboración propia)],
    label: "fig:" + use_case,
  )
  if use_cases.last() != use_case {
    pagebreak()
  }
}

== Matriz de trazabilidad

#let myTable = ()

#for i in range(reqs_funcionales.len()) {
  let req = reqs_funcionales.at(i)
  myTable.push([H#(i + 1)])
  for use_case in use_cases {
    if req.use_case == use_case {
      myTable.push([X])
    } else { myTable.push([]) }
  }
}

#apa-figure(
  table(
    align: center,
    columns: (auto, auto, auto, auto, auto, auto, auto),
    table.header([HU], [CUS01], [CUS02], [CUS03], [CUS04], [CUS05], [CUS06]),
    table.hline(stroke: 0.5pt),
    ..myTable,
    table.hline(),
  ),
  caption: [Matriz de trazabilidad de casos de uso (Elaboración propia)],
  label: "tab:matriz-trazabilidad",
)

#pagebreak()

== Sprint planning

Revisar documento sprint_planning_1.pdf y sprint_planning_2.pdf

== Diagrama de actividades

#apa-figure(
  image("../images/diagrams/bpmn.png"),
  caption: [Diagrama de actividades BPMN (Elaboración propia)],
  label: "fig:diagrama_bpmn",
)

#pagebreak()
== Modelado de la base de datos

#apa-figure(
  image("../images/modelo_logico.png", width: 80%),
  caption: [Modelo lógico (Elaboración propia)],
  label: "fig:modelo_logico",
)
#pagebreak()

#apa-figure(
  image("../images/modelo_conceptual.png", width: 80%),
  caption: [Modelo conceptual (Elaboración propia)],
  label: "fig:modelo_conceptual",
)
#pagebreak()

#apa-figure(
  image("../images/modelo_fisico.png", width: 80%),
  caption: [Modelo físico (Elaboración propia)],
  label: "fig:modelo_fisico",
)
#pagebreak()


== Diagrama de clases

#apa-figure(
  image("../images/diagrama_clases.png", width: 70%),
  caption: [Diagrama de clases (Elaboración propia)],
  label: "fig:diagrama_clases",
)

#pagebreak()

== Diagramas de secuencia

#for i in range(1, 21) {
  apa-figure(
    image(
      "../images/diagramas_secuencia/diagrama_" + str(i) + ".png",
      // width: 80%,
      height: 8cm,
    ),
    caption: "Diagrama de secuencia " + str(i) + " (Elaboración propia)",
    label: "fig:diagrama_secuencia_" + str(i),
  )
  if calc.even(i) {
    pagebreak()
  }
}
