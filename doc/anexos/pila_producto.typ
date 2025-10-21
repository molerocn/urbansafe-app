#import "@local/utp-doc:1.0.0": apa-figure
#import "../content/requerimientos.typ": reqs_funcionales

#let pilaTable = ()

#for i in range(0, reqs_funcionales.len()) {
  let req_index = "H" + str(i + 1)
  let modulo = reqs_funcionales.at(i).modulo
  let tasks = reqs_funcionales.at(i).tasks
  pilaTable.push(table.cell(rowspan: tasks.len())[#req_index])
  pilaTable.push(table.cell(rowspan: tasks.len())[#modulo])

  for j in range(0, tasks.len()) {
    let item = req_index + "-" + str(j + 1)
    pilaTable.push([#item])
    pilaTable.push([#tasks.at(j).description])
    pilaTable.push([#tasks.at(j).author])
    pilaTable.push([#tasks.at(j).estimation])
  }
}

#pagebreak()
// #{
// set page(
//   flipped: true,
// margin: 2.5em,
// )
// set text(size: 10pt)

// [
#apa-figure(
  table(
    align: (x, y) => {
      if (y == 0) {
        center
      } else { left }
    },
    columns: (auto, auto, auto, 30%, auto, auto),
    table.header(
      table.cell(colspan: 3)[*Historia de usuario*],
      table.cell(colspan: 3)[*Tarea*],
      [*Código*],
      [*Módulo*],
      [*Item*],
      [*Descripción*],
      [*Responable*],
      [*Estimado
        (horas)*],
    ),
    table.hline(stroke: 0.5pt),
    ..pilaTable,
    table.hline(),
  ),
  caption: [Pila de producto (Elaboración propia)],
  label: "tab:pila-producto",
)
// ]
// }
