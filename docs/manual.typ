#import "common.typ"
#import common: fletcher

// cover page

#v(1fr)

#align(center)[

  #common.logo

  #v(30pt)

  #common.package-summary

  #link("https://fletcher-package.github.io")[`fletcher-package.github.io`]

  *Version #common.VERSION*
]

#v(1fr)


#columns(2)[
  #show heading: it => align(center, box(width: 100%, it)) + v(.8em)
  #outline(
    title: [Manual],
    target: selector(heading).after(<manual>, inclusive: false).before(<func-ref>, inclusive: false),
    depth: 3,
  )
  #colbreak()
  #outline(
    title: [Function Reference],
    target: selector(heading).after(<func-ref>, inclusive: false).before(<end>),
    depth: 2,
  )

]

#v(1fr)



#show heading: it => {
  let size = (40pt, 25pt, 20pt, 15pt).at(it.level, default: 12pt)
  text(size, v(1em) + it)
}
#show heading.where(level: 1): it => {
  pagebreak(weak: true)
  align(center, text(weight: 200, smallcaps(it)))
  line(length: 100%)
}

#show link: it => underline(strong(it))
#show ref: common.show-ref

= Manual <manual>

#[
  #set heading(offset: 1)
  #include "sections/intro.typ"; <manual-intro>
  #include "sections/diagrams.typ"; <manual-diagrams>
  #include "sections/nodes.typ"; <manual-nodes>
  #include "sections/edges.typ"; <manual-edges>
  #include "sections/marks.typ"; <manual-marks>
  #include "sections/cetz.typ"; <manual-cetz>
  #include "sections/debug.typ"; <manual-debug>
]


= Function Reference <func-ref>

#let exports = common.EXPORT_TREE.fletcher
#show raw.where(lang: "example"): common.example
#show raw.where(lang: "svg"): it => eval(it.text, mode: "code", scope: common.scope)
#set raw(lang: "typc")

#import common: show-fn

#show-fn(exports.remove("diagram"), level: 2)
#show-fn(exports.remove("node"), level: 2)
#show-fn(exports.remove("edge"), level: 2)
#show-fn(exports.remove("flexigrid"), level: 2)


== The `marks` module

#show-fn(exports.marks.remove("test"))
#for name in exports.marks.keys() {
  show-fn(exports.marks.remove(name))
}


== The `shapes` module

These are the built in @node-shapes[node shapes], usable with the @node.shape option.

#common.shapes-gallery

#for name in exports.shapes.keys() {
  show-fn(exports.shapes.remove(name))
}


== The `paths` module

#show-fn(exports.edges.remove("apply-edge-effects"))
#show-fn(exports.paths.remove("path-effect"))
#show-fn(exports.paths.remove("trim-path"))
#show-fn(exports.paths.remove("trim-to-intersection"))
#for name in exports.paths.keys() {
  show-fn(exports.paths.remove(name))
}


== The `parsing` module

#for name in exports.parsing.keys() {
  show-fn(exports.parsing.remove(name))
}
