#import "../common.typ": *
#show: style

= Introduction


#[
  #show "{VERSION}": VERSION
  Import fletcher with:
  ```typ
  #import "@preview/fletcher:{VERSION}": diagram, node, edge
  ```
  Fletcher {VERSION} depends on CeTZ #fletcher.cetz.version, so if you also use CeTZ, you can import it from fletcher to ensure compatible versions are used.
  ```typ
  #import "@preview/fletcher:{VERSION}"
  #import fletcher: cetz, diagram, node, edge
  ```
]

== Diagrams

Diagrams contain #[@node]s and #[@edge]s.
Nodes contain content and can have various @node-shapes[shapes] and @node-styles[styles], while edges snap to nodes and can be given @edge.marks[marks] and @edge.label[labels].
Nodes and edges can be placed in a @diagram or @draw-in-cetz[directly into a CeTZ canvas].
Objects in a @diagram are arranged on a @flexigrids[flexible coordinate grid].

#example(```typ
#diagram({
  node((0,0), $G$)
  edge("->", $f$)
  node((1,0), $im(f)$)
  edge((0,0), "->>", $pi$)
  edge("<--hook'", $tilde(f)$, bottom)
  node((0,1), $G slash ker(f)$)
})
```)

== Math-mode diagrams

Nodes can alternatively be defined using a @math-mode-diagrams[block equation inside a diagram].

#example(```typ
#let hom = edge.with(in-math: true) // required for edges in math
#diagram($
  G hom(f, ->) hom("d", pi, ->>) & im(f) \
  G slash ker(f) hom("ur", tilde(f), "hook-->", #bottom)
$)
```)

== Styles
Styles can be controlled with the named arguments of @node and @edge.

#example(```typ
#diagram(
	spacing: (1cm, 4mm), // column and row gutter
	node-inset: 8pt,     // padding around node body
	node-fill: teal.mix(fuchsia),
	edge-stroke: 2pt + gray,
	node((0,0))[A], edge(), node((1,0))[B],
	node((2,1))[C], node((2,-1), fill: orange)[D],
	edge((1,0), (2,1), bend: 45deg),
	edge((1,0), "=>", (2,-1), stroke: 1pt + black),
)
```)


== Row span, column span, and enclose nodes

Nodes can @enclose-nodes[enclose] other nodes and, when inside a flexigrid, @sec-node-cellspan[span multiple columns or rows].

#example(```typ
#diagram(
	spacing: 4pt,
	node-stroke: 1pt,
	node-fill: white,
	node-corner-radius: 2pt,
	node((0,0), [Sight], name: <sight>),
	node((1,0), [Sound]),
	node((2,0), [Smell], name: <smell>),
	node((0,1), [Senses], colspan: 3),
	node((0,0), rowspan: 2, colspan: 3,
	  fill: yellow, extrude: 4pt, layer: -1),
)
```)

Overlapping nodes can be ordered with @node.layer, and @node.extrude can be used to offset shapes so that rounded corners stay concentric.


== CeTZ integration

You can also place nodes and edges directly into `cetz.canvas()` and set node and edge styles with `cetz.draw.set-style()`.
Under the hood, a @diagram is just a @flexigrid inside a CeTZ canvas (see @cetz-interop for details).

For example, here we use fletcher's marks to draw an edge in a CeTZ-based figure.

#example(```typ
#import fletcher.cetz

#cetz.canvas(length: 5mm, {
	import cetz.draw: *
	set-style(fill: teal, edge: (stroke: 1pt + teal))
	circle((5,0), radius: (1.2,0.8), name: "egg")
	line((0,1), (1,0), (0,-1), (-1,0), close: true, name: "jewel")
	edge(<jewel>, "stealth~stealth", <egg>, bend: 80deg)
})
```)

== Coordinate expressions

Dimensionless coordinates like `(2, 3)` in a @node or @edge refer to columns/rows in the grid.
You can also use physical lengths like `(20mm, 5mm)` or any CeTZ coordinate expression, including anchors.

#example(```typ
#diagram(
	node((1, 0), name: "O"),
	for i in range(12) {
    let θ = i/12*360deg
		edge(<O>, "->", auto)
		node((rel: (θ, 10mm), to: "O"), $ #i $, inset: 4pt)
	}
)
```)
