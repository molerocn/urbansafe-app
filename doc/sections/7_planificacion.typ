#import "@local/utp-doc:1.0.0": apa-figure
#import "../content/requerimientos.typ": reqs_funcionales, table_reqs_funcionales, table_reqs_no_funcionales
= Planificación

== Acta de constitución del proyecto

== Cronograma
== Diagrama de Gantt // what?
== Work Breakdown Structure
== Requerimientos del proyecto

=== Requerimientos funcionales
#apa-figure(
  table(
    align: left,
    columns: (10%, 30%, 60%),
    table.header([*Código*], [*Nombre*], [*Descripción*]),
    ..table_reqs_funcionales,
    table.hline(),
  ),
  caption: [Tabla de requerimientos funcionales],
  label: "tab:requerimientos_funcionales",
)

=== Requerimientos no funcionales
#apa-figure(
  table(
    align: left,
    columns: (10%, 30%, 60%),
    table.header([*Código*], [*Nombre*], [*Descripción*]),
    ..table_reqs_no_funcionales,
    table.hline(),
  ),
  caption: [Tabla de requerimientos funcionales],
  label: "tab:requerimientos_funcionales",
)

== Project charter
== Sprints
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
    caption: [Tarjeta de historia de usuario H#hindex],
  )
}


#pagebreak()
