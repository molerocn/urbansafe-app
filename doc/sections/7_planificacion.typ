#import "@local/utp-doc:1.0.0": apa-figure
#import "../content/requerimientos.typ": (
  reqs_funcionales, table_reqs_funcionales_1, table_reqs_funcionales_2, table_reqs_no_funcionales,
)

= Planificación

== Acta de constitución del proyecto
Revisar documento acta_constitucion.pdf

// == Cronograma
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

#pagebreak()
== Sprints

#apa-figure(
  image("../images/sprint_1.png"),
  caption: [Sprint backlog - 1 (Elaboración propia)],
  label: "fig:sprint_1",
)

#apa-figure(
  image("../images/sprint_2.png"),
  caption: [Sprint backlog - 2 (Elaboración propia)],
  label: "fig:sprint_2",
)

#apa-figure(
  image("../images/sprint_3.png"),
  caption: [Sprint backlog - 3 (Elaboración propia)],
  label: "fig:sprint_3",
)
#pagebreak()

#apa-figure(
  image("../images/sprint_4.png"),
  caption: [Sprint backlog - 4 (Elaboración propia)],
  label: "fig:sprint_4",
)

#pagebreak()
== Historia de usuario

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


#pagebreak()
