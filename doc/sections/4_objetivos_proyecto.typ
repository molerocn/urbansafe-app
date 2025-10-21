#import "../anexos/matriz_consistencia.typ" : objetivos

= Objetivos del proyecto
== Objetivo general

*OG*: #objetivos.at(0)

== Objetivos específicos

#list(
    ..objetivos.slice(1, objetivos.len()).enumerate().map((item) => [
        *OE0#(item.at(0)+1)*: #item.at(1)
    ]),
)


#pagebreak()
