// This file contains things used by both the documentation PDF and website

#import "@preview/tidy:0.4.3"
#import "../src/exports.typ" as fletcher: diagram, node, edge
#import "../src/debug.typ": DEBUG_LEVELS

#let VERSION = toml("/typst.toml").package.version

#let is-html() = if "target" in std { target() == "html" } else { false }

#let frame(it) = context {
  if is-html() {
    html.frame(pad(3mm, scale(100%, reflow: true, it)))
  } else {
    it
  }
}

#let logo = frame(stack(
  spacing: 12pt,
  {
    import fletcher: diagram, edge, node
    set text(1.3em)
    diagram(
      spacing: 25mm,
      node((0, 1), $A$),
      node((1, 1), $B$),
      edge((0, 1), (1, 1), $f$, ">>->", stroke: 1pt),
    )
  },
  move(dy: -.3em, text(3.2em, emph[fletcher])),
  [_(noun) a maker of arrows_],
))

#let package-summary = [
  A #link("https://typst.app/")[Typst] package for diagrams with lots of arrows,
  built on top of #link("https://cetz-package.github.io")[CeTZ].

  #emph[
    Commutative diagrams,
    flow charts,
    state machines,
    block diagrams...
  ]
]


/* Simple components */

// a bunch of frames in a centered, wrapping layout
#let frame-row(..args, gap: 5mm) = context {
  if is-html() {
    html.div(class: "frame-row", args.pos().map(frame).join())
  } else {
    set stack(dir: ltr, spacing: 1fr)
    layout(size => {
      let total = 0pt
      let row = ()
      for fig in args.pos() {
        total += measure(fig).width + gap
        if total > size.width {
          stack(none, ..row, none)
          row = ()
          total = 0pt
        }
        row.push(align(center + horizon, fig))
      }
      stack(none, ..row, none)
    })
  }
}

// a two-column arrangement
#let side-figure(body, figure) = context {
  if is-html() {
    html.div(class: "side-figure", {
      html.div(body)
      figure
    })
  } else {
    grid(
      columns: (1fr, auto),
      gutter: 1em,
      body,
      figure,
    )
  }
}


/* Example blocks */

#let scope = (
  fletcher: fletcher,
  ..dictionary(fletcher),
  frame: frame,
  frame-row: frame-row,
  DEBUG_LEVELS: DEBUG_LEVELS,
)
#let example(code, setup: none) = context {
  let setup = if setup != none { setup.text + "\n" }
  let preview = eval(setup + code.text, mode: "markup", scope: scope)
  let code = raw(code.text, lang: "typ", block: true)


  if is-html() {
    html.div(class: "code-example", {
      html.div(class: "codeblock", code)
      frame(preview)
    })
  } else {
    grid(
      columns: (1fr, auto),
      align: horizon,
      gutter: 1em,
      code, preview,
    )
  }
}
#(scope.example = example)

// a section with a visual divider at the top
#let bordered-section(body) = context {
  if is-html() {
    html.div(class: "bordered-section", body)
  } else {
    v(2em)
    block(
      outset: (x: 10pt),
      width: 100%,
      radius: (top: 10pt),
      stroke: (top: .6pt + gray, rest: 0pt + gray),
      height: 1cm,
      sticky: true,
    )
    v(-16mm)
    body
  }
}



/* Shape demos */

#let shape-colors = (
  rect: green,
  circle: red,
  ellipse: orange,
  pill: teal,
  parallelogram: olive,
  keystone: green,
  diamond: purple,
  triangle: fuchsia,
  house: eastern,
  chevron: yellow,
  hexagon: aqua,
  octagon: maroon,
  cylinder: gray,
)

// helper for node shapes docstrings
#let shape-demo(shape, label: auto, ..args, show-code: false) = {
  let tint = shape-colors.at(shape, default: gray)

  let has-args = args.named().len() > 0
  if label == auto {
    if has-args {
      let (k, v) = args.named().pairs().first()
      label = raw(k + ": " + repr(v))
    } else {
      label = raw(shape)
    }
  }

  if "fit" in args.named() {
    label = box(
      stroke: (dash: "dashed", thickness: 0.5pt),
      inset: 10pt,
      raw("fit: " + repr(args.named().fit)),
    )
    args = arguments(..args, inset: 0)
  }
  frame(fletcher.diagram(
    fletcher.node((0, 0), label, shape: shape, inset: 5pt, ..args),
    node-stroke: tint,
    node-fill: tint.lighten(90%),
  ))

  if show-code {
    let code = {
      "node(.., shape: "
      repr(shape)
      ", "
      fletcher
        .shapes
        .NODE_SHAPES
        .at(shape)
        .pairs()
        .filter(((k, v)) => k != "draw")
        .map(((k, v)) => k + ": " + repr(v))
        .join(", ")
      ")"
    }
    par(raw(code, lang: "typc"))
  }
}

#let shapes-gallery = frame-row(
  gap: 20mm,
  ..fletcher
    .shapes
    .NODE_SHAPES
    .keys()
    .filter(name => name != "none")
    .enumerate()
    .map(((i, name)) => {
      let c = shape-colors.at(name).darken(50%)
      let body = text(c, pad(-1em, link(label(name), pad(1em, raw(name)))))
      shape-demo(name, label: body)
    })
)

#(scope.shape-demo = shape-demo)


/* Docstrings and module introspection */

#let fn-paths-by-name(mod, path: ()) = {
  let fns = (:)

  for (name, value) in dictionary(mod) {
    if type(value) == function {
      fns.insert(name, path)
    }
  }

  for (name, value) in dictionary(mod) {
    if type(value) == module {
      let s = fn-paths-by-name(value, path: (..path, name))
      for (name, path) in s {
        if name in fns {
          if path.len() < fns.at(name).len() {
            fns.at(name) = path
          }
        } else {
          fns.insert(name, path)
        }
      }
    }
  }

  return fns
}

// ordered dictionary of all functions and their shortest exported paths
// e.g., `node` has shortest path `fletcher.node` (not `fletcher.nodes.node`)
#let FUNCTION_PATHS = fn-paths-by-name(fletcher, path: ("fletcher",))

#let DOCSTRINGS = (
  (
    "../src/diagram.typ",
    "../src/flexigrid.typ",
    "../src/nodes.typ",
    "../src/edges.typ",
    "../src/paths.typ",
    "../src/marks.typ",
    "../src/shapes.typ",
    "../src/parsing.typ",
  )
    .map(path => tidy.parse-module(read(path)).functions)
    .join()
    .map(fn => (fn.name, fn))
    .to-dict()
)

#let insert-at-path(dict, path, value) = {
  if path.len() > 0 {
    let p = path.remove(0)
    dict + ((p): insert-at-path(dict.at(p, default: (:)), path, value))
  } else {
    dict.insert(value, value)
    dict
  }
}

// dictionary reflecting the entire package submodule structure
#let EXPORT_TREE = (:)
#for (name, path) in FUNCTION_PATHS {
  if name in DOCSTRINGS {
    EXPORT_TREE = insert-at-path(EXPORT_TREE, path, name)
  }
}


/* Crossrefs and linking */

#let rich-ref(id, ..args) = [
  #metadata(args.named())
  #label(id)
]

#let show-ref(it) = {
  if it.element == none {
    highlight(raw(repr(it.target)))
    metadata((invalid-ref: str(it.target)))
    panic("Unresolved reference:", it.target)

  } else if it.element.func() == metadata and "entity" in it.element.value {
    show: link.with(it.element.location())

    if it.supplement != auto {
      // custom label text
      it.supplement
    } else {
      // format entity
      let (entity, ..info) = it.element.value
      if entity == "function" {
        raw(info.function + "()")
      } else if entity == "argument" {
        if state("current-function").get() == info.function {
          raw(info.argument)
        } else {
          raw(info.function + "." + info.argument)
        }
      } else {
        panic("unknown ref element", it.element)
      }
    }
  } else if it.element.func() == heading {
    let body = (
      if it.supplement == auto { it.element.body } else { it.supplement }
    )
    link(it.target, body)
  } else if it.supplement != auto {
    link(it.target, it.supplement)
  } else {
    panic(it)
  }
}


/* Function docstring styles */

#let show-type(ty) = {
  import tidy.styles.default: colors
  let clr = colors.at(ty, default: colors.default)
  if is-html() {
    let hex = if type(clr) == color { clr.to-hex() } else { "" }
    html.span(class: "type", style: "background: " + hex, ty)
  } else {
    h(2pt)
    box(outset: 2pt, fill: clr, radius: 2pt, raw(ty, lang: none))
    h(2pt)
  }
}

#let show-function-signature(fn) = {
  show: par
  show: it => {
    if is-html() {
      html.pre(it, class: "fn-signature")
    } else {
      it
    }
  }

  set text(font: "DejaVu Sans Mono", size: 0.8em)

  if fn.name in FUNCTION_PATHS {
    text(FUNCTION_PATHS.at(fn.name).join(".") + ".")
  } else {
    panic("unexported function", fn.name)
    text(red)[unexported: ]
  }

  text(fn.name, fill: tidy.styles.default.colors.signature-func-name)
  "("

  let inline = fn.args.len() <= 2
  if not inline { "\n  " }

  let items = fn
    .args
    .pairs()
    .map(((arg-name, info)) => {
      if info.at("description", default: "") == "" {
        arg-name
      } else {
        // arg-name
        link(label(fn.name + "." + arg-name), arg-name)
      }

      if "types" in info and info.types != ("",) {
        ": " + info.types.map(show-type).join(" ")
      }
    })

  items.join(if inline { ", " } else { ",\n  " })
  if not inline { ",\n" } + ")"

  if fn.return-types != none {
    " -> "
    fn.return-types.map(show-type).join(" ")
  }


}

#let show-function-argument(fn, arg, info, level: 3) = {
  rich-ref(
    fn.name + "." + arg,
    entity: "argument",
    function: fn.name,
    argument: arg,
  )

  if is-html() {
    bordered-section({
      heading(raw(arg), level: level)

      html.div(class: "fn-arg-details", {
        if "types" in info {
          info.types.map(show-type).join[ or ]
        }
        if "default" in info {
          [ default ]
          raw(info.default)
        }
      })

      eval(info.description, mode: "markup", scope: scope)
    })
  } else {
    let first-line = {
      box(heading(raw(arg), level: level))
      if "types" in info {
        h(0.5em)
        info.types.map(show-type).join(text(0.8em)[ or ])
      }
      if "default" in info {
        text(0.8em)[ default ]
        raw(info.default)
      }
      h(1fr)
      link(label(fn.name), text(gray, $arrow.tl$))
    }

    let is-long = info.description.len() > 500

    bordered-section[
      #first-line

      #eval(info.description, mode: "markup", scope: scope)
    ]

    v(1em)
  }
}

#let show-fn(name, level: 3) = context {
  let fn = DOCSTRINGS.at(name)
  state("current-function").update(fn.name)

  rich-ref(fn.name, entity: "function", function: fn.name)

  heading(raw(FUNCTION_PATHS.at(fn.name).join(".") + "." + name + "()"), level: level)

  eval(fn.description, mode: "markup", scope: scope)

  show-function-signature(fn)

  for (arg, info) in fn.args {
    if info.description == "" { continue }
    show-function-argument(fn, arg, info, level: level + 1)
  }
}


/* Show rules */

#let style(body) = {
  show ref: show-ref

  set raw(lang: "typc")
  show raw.where(lang: "example"): example
  show raw.where(lang: "svg"): it => frame(eval(it.text, mode: "code", scope: scope))

  body
}


/* Web-specific components */

#let nav-expander-script() = html.script(```js
  // A script to automatically enlarge the navbar when hovering over wide links
  const nav = document.querySelector('nav');
  const navWidth = nav.offsetWidth;
  let stretchedWidth = navWidth;

  const closeNav = () => {
    nav.classList.remove('stretched');
    nav.style.removeProperty('min-width');
    stretchedWidth = navWidth;
  }

  const expandNav = (width) => {
    if (width <= stretchedWidth) return;
    stretchedWidth = width;
    nav.classList.add('stretched')
    nav.style.minWidth = `${stretchedWidth}px`;
  }

  nav.addEventListener('mouseleave', closeNav)
  let counter = 0;
  nav.querySelectorAll('li a').forEach(item => {
    item.addEventListener('mouseenter', () => {
      const c = ++counter;
      setTimeout(() => {
        const w = item.getBoundingClientRect().right - nav.getBoundingClientRect().left;
        if (c == counter) expandNav(w + 25);
      }, 500)
    });
    item.addEventListener('mouseleave', () => {
      const c = ++counter;
      setTimeout(() => {
        if (c == counter) closeNav();
      }, 2e3);
    });
  });
```.text)
