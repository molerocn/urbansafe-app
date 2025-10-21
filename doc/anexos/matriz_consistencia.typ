#import "@local/utp-doc:1.0.0": apa-figure

#let objetivos = ()
#let hipotesis_list = ()
#let master = ()
#let variables_dependientes = (
  (text: [seguridad ciudadana], signo: 1, gender: 0), // signo 0 "reduce" 1 "mejora" | gender 0 la, 1 el
  (text: [violencia psicológica], signo: 0, gender: 0),
  (text: [violencia física], signo: 0, gender: 0),
  (text: [conducción en estado de ebriedad o drogadicción], signo: 0, gender: 0),
  (text: [hurto], signo: 0, gender: 1),
)

#let variable_independiente = [el modelo de machine learning]
#let post = [en la región del Callao]

#for variable in variables_dependientes {
  let verbo = if variable.signo == 0 [reduce] else [mejora]
  let prefijo = if variable.gender == 0 [la] else [el]

  let objetivo = [Determinar en qué medida #variable_independiente #verbo #prefijo #variable.text #post.]
  objetivos.push(objetivo)

  // -------------------------------
  let hipotesis = [El modelo de machine learning #verbo significativamente #prefijo #variable.text #post.]
  hipotesis_list.push(hipotesis)
  // -------------------------------

  let variable_independiente_highlighted = highlight(fill: aqua, variable_independiente)
  let variable_highlighted = highlight(variable.text)

  master.push((
    problema: [¿En qué medida #variable_independiente #verbo #prefijo #variable.text #post?],
    objetivo: [Determinar en qué medida #variable_independiente_highlighted #verbo #prefijo #variable_highlighted #post.],
    hipotesis: [#variable_independiente_highlighted #verbo significativamente #prefijo #variable_highlighted #post.],
  ))
}

#let rows = variables_dependientes.len() * 2 - 1

#(
  master
    .at(0)
    .insert("variables", table.cell(rowspan: rows)[
      *Variable independiente*:\
      #variable_independiente
      #parbreak()
      *Variable dependientes*:\
      #list(indent: 5pt, ..variables_dependientes.map(variable => {
        variable.text
      }))
    ])
)

#(
  master
    .at(0)
    .insert("dimensiones", table.cell(rowspan: rows)[
      #list(indent: 5pt, ..variables_dependientes.map(variable => {
        variable.text
      }))
    ])
)
#(
  master
    .at(0)
    .insert("metodologia", table.cell(rowspan: rows)[
      *Tipo*: Aplicada \
      *Enfoque*: Cuantitativo \
      *Nivel*: Explicativo \
      *Diseño*: Experimental (pre y pos) \
      // *Técnica*: Observación \
      // *Instrumento*: Ficha de observación \
      // *Población*: Ciudadanos de la región del Callao \
      // *Muestra*: 51 ciudadanos \
      // *Muestreo*: Probabilístico simple
    ])
)

#let myTable = ()

#for item in master {
  myTable = myTable + item.values() + ([], [], [])
}
#myTable.insert(6, table.hline())

#{
  set page(
    flipped: true,
    margin: 2.5em,
  )
  set text(size: 10pt)
  pagebreak()

  apa-figure(
    table(
      align: left,
      columns: (auto, auto, auto, auto, auto, auto),
      table.header([Problemas], [Objetivos], [Hipótesis], [Variables], [Dimensiones], [Metodología]),
      table.hline(stroke: 0.5pt),
      ..myTable,
      table.hline(),
    ),
    caption: [Matriz de consistencia (Elaboración propia)],
    label: "tab:matriz-consistencia",
  )
}

// logica para poder alinear de acuerdo al indice de una tabla
// align: (x, y) => if (y == 0 or y == 1) and x >= 0 {
//   center
// } else if x == 0 and y > 0 {
//   left
// } else {
//   center
// },

