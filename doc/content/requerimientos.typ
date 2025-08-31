// el docente quiere 20
#let reqs_funcionales = (
  (
    nombre: "Registro de algo hola mundo",
    actor: "Mozo",
    prioridad: 1, // 1 = Alta, 2 = Media, 3 = Baja
    quiero: "Registrar un nuevo usuario cada vez que le de al boton de login",
    para: "Tener algo de acuerdo a lo que estuve comentandote",
    criterios: (
      "primer criterio",
      "segundo criterio",
      "tercer criterio",
    ),
  ),
)

// el docente quiere 10
#let reqs_no_funcionales = (
  (
    nombre: "Prueba req no funcional",
    quiero: "Registrar un nuevo usuario cada vez que le de al boton de login",
  ),
)

#let table_reqs_funcionales = ()
#for i in range(reqs_funcionales.len()) {
  let req = reqs_funcionales.at(i)
  let rindex = i + 1
  table_reqs_funcionales = table_reqs_funcionales + (
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
    [*El sistema debe permitir* #lower(req.quiero)],
  )
},

