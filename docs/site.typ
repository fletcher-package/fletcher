#import "common.typ"
#show: common.style

#let URL_ROOT = sys.inputs.at("url-root", default: "")

#asset("/styles.css", read("assets/styles.css"))
#asset("/manual.pdf", read("manual.pdf", encoding: none)) <manual-pdf>

#let manual-pages = (
  ("intro.html", "sections/intro.typ", <manual-intro>),
  ("nodes.html", "sections/nodes.typ", <manual-nodes>),
  ("edges.html", "sections/edges.typ", <manual-edges>),
  ("marks.html", "sections/marks.typ", <manual-marks>),
  ("diagrams.html", "sections/diagrams.typ", <manual-diagrams>),
  ("cetz.html", "sections/cetz.typ", <manual-cetz>),
  ("debug.html", "sections/debug.typ", <manual-debug>),
)

#let menu-tree = state("menu-tree", (:))

#let sidebar = context html.nav(html.div[

  #html.div(id: "sidebar-title", link(<home>, html.frame({
    text(1.75em)[_fletcher manual_]
  })))

  - #link(<gallery>)[*Example Gallery*]

  - #[*Manual*]
    #for (dest, src, id) in manual-pages {
      let title = query(selector(heading).within(id)).first().body
      if id == state("current-document").get() [
        - #strong(link(id, title))
          #let headings = (query(selector(heading).within(id))
            .filter(it => it.level > 1))
          #for heading in headings {
            [- #html.elem("span", link(heading.location(), heading.body), attrs: (data-depth: str(heading.level)))]
          }
      ] else [
        - #link(id, title)
      ]
    }

  - *Function Reference*

    #let tree = menu-tree.final()
    #let (this-mod, this-fn) = state("current-fn-page", (none, none)).get()

    #let fn-link(name) = {
      let it = link(label("ref-" + name), raw(name + "()"))
      if this-fn == name { it = strong(it) }
      list.item(it)
    }

    // main functions
    #tree.remove("main").map(fn-link).join()
    // mod functions in dropdowns
    #for (mod, tree) in tree {
       html.details(open: mod == this-mod, {
        html.summary[#raw(mod) module]
        tree.map(fn-link).join()
       })
    }
])

#let menu-hamburger-button = html.label(..("for": "menu-control"), id: "menu-button")[
  #html.frame(stack(..(line(length: 1.5em, stroke: 1pt),)*4, spacing: 0.4em, dir: ttb))
]

#let page-nav = context {
  let doc-label = state("current-document", none).get()
  if doc-label == none { return }

  let i = manual-pages.position(((_, _, label)) => label == doc-label)
  if i == none { return }

  let prev = if i > 0 { manual-pages.at(i - 1).last() }
  let next = if i < manual-pages.len() - 1 { manual-pages.at(i + 1).last() }

  let icon(a) = html.frame(common.diagram(common.edge((0pt,0), (a, 1pt), " >", stroke: 1pt)))
  let nav-link(label, dir) = {
    let title = query(selector(heading).within(label)).first().body
    let body = if dir == left {icon(180deg) + html.div(title) } else { html.div(title) + icon(0deg) }
    link(label, body)
  }
  html.div(id: "page-nav", {
    html.div(if prev != none { nav-link(prev, left) })
    html.div(if next != none { nav-link(next, right) })
  })
}

#let footer = html.footer({

  show: html.div.with(class: "cols")

  let cols = ([
    - *Documentation*
    - #link(<gallery>)[Example Gallery]
    - #link(<manual-pdf>)[PDF Manual]
  ], [
    - *Package*
    - #link("https://typst.app/universe/package/fletcher")[Typst Universe]
    - #link("https://github.com/fletcher-package/fletcher")[GitHub Repo]
  ], [
    - *Community*
    - #link("https://forum.typst.app/")[Typst Forum]
    - #link("https://discord.com/channels/1054443721975922748/1260973351900414102")[Discord Channel]
  ], [
    - *Contributing*
    - #[Issues & Ideas]
    - #[Sponsorship]
  ])

  for col in cols {
    html.div(class: "col", col)
  }
})

#let template(body) = {
  html.link(href: URL_ROOT + "/styles.css", rel: "stylesheet")
  html.main({ // wrap in main so inputs aren't wrapped in <p>
    html.input(type: "checkbox", id: "menu-control") // must immediately precede label
    html.label(..("for": "menu-control"), class: "menu-overlay")
    sidebar
    html.article[
      #body
      #menu-hamburger-button
      #page-nav
    ]
    html.div(id: "wip-banner")
  })
  footer
  common.nav-expander-script()
}


// Home page

#document("index.html", template[
  #show: html.div.with(style: "text-align: center")

  #html.div(style: "margin: 7vw 0;")[
    #box(common.logo)

    #common.package-summary

    *Version #common.VERSION #highlight[(unreleased)]*
  ]

  #html.div(class: "large-links", {
    html.div(link(<gallery>)[Example Gallery])
      html.div(link(<manual-intro>)[Quick Overview])
  })

]) <home>



// Gallery

#let gals = (
  "gallery/commutative.typ",
  "gallery/block-diagram.typ",
  "gallery/ml-architecture.typ",
  // "gallery/io-flowchart.typ",
  "gallery/digraph.typ",
  "gallery/uml-diagram.typ",
  "gallery/feynman-diagram.typ",
  "gallery/category-theory.typ",
  "gallery/node-groups.typ",
  "gallery/tree.typ",
  "gallery/algebra-cube.typ",
)

#for gal in gals [
  #document(gal.replace(".typ", ".html"))[
    #let src = read(gal).replace("\t", "  ").replace("../../src/exports.typ", "@preview/fletcher:" + common.VERSION)
    #raw(src, lang: "typ"),
  ] #label(gal)
]

#document("gallery.html", template[
  = Example Gallery

  Here you can find example diagrams made with `fletcher`.

  Click on an example to see its source code.

  #show: html.div.with(class: "frame-row")

  #for gal in gals [
    #html.div(class: "gallery-example", {
      link(label(gal), html.frame(pad(1em, include gal)))
    })
  ]

]) <gallery>



// Manual

#for (i, (dest, src, doc-label)) in manual-pages.enumerate() {

  let doc = document("/manual/" + dest, {
    state("current-document").update(doc-label)
    template(include src)
  })

  [#doc #doc-label]

}


// Function reference

#let fn-doc(module, name, ..args) =  {
  let url = "reference/" + module + "/" + name + ".html"
  let doc-label = label("ref-" + name)
  let doc = document(url, {
    state("current-document").update(doc-label)
    state("current-fn-page").update(_ => (module, name))
    template(common.show-fn(name, level: 1))
  })
  [#doc #doc-label]

  menu-tree.update(l => {
    if module not in l { l.insert(module, ()) }
    l.at(module).push(name)
    l
  })
}

#let exports = common.EXPORT_TREE.fletcher

#fn-doc("main", exports.remove("diagram"), weight: 1)
#fn-doc("main", exports.remove("node"), weight: 2)
#fn-doc("main", exports.remove("edge"), weight: 3)
#fn-doc("main", exports.remove("flexigrid"), weight: 4)

#fn-doc("marks", exports.marks.remove("test"))

#fn-doc("path", exports.edges.remove("apply-edge-effects"))
#fn-doc("path", exports.paths.remove("path-effect"))
#fn-doc("path", exports.paths.remove("trim-path"))
#fn-doc("path", exports.paths.remove("trim-to-intersection"))
#for name in exports.paths.keys() {
  fn-doc("path", exports.paths.remove(name))
}

#for name in exports.shapes.keys() {
  fn-doc("shapes", exports.shapes.remove(name))
}

#for name in exports.parsing.keys() {
  fn-doc("parsing", exports.parsing.remove(name))
}
