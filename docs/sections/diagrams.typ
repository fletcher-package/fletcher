#import "../common.typ": *
#show: style


= Diagrams and Layout <flexigrids>

Fletcher encourages tabular layouts.
Nodes in a @diagram are laid out on a @manual-diagrams[flexible coordinate grid or _flexigrid_], visible when the @debug.grid[`debug` option] is on.
The rows and columns in this coordinate system grow to accommodate the sizes of nodes, like a table.

#example(```typ
#diagram(
  debug: "grid", // show helper annotations
  spacing: 5mm,  // gutter between cells
  node((0,0), stroke: yellow, [Wide node]),
  node((1,0), fill: green, [A\ tall\ node], name: "tall"),
  node((0,1), fill: red, emph[top left], align: top + left),
  node((1,1), fill: blue, text(white, $ a/b $)),
	cetz.draw.polygon("tall.north-east", 6, radius: 4pt)
)
```)

Unlike normal tables, flexigrid coordinates can be fractional.
For example, the center of a node placed at `0.25` is $25%$ between the centers of the nearest cells.
Notice how the column sizes respond to the green node as it moves between columns.

#frame-row(..(0, .25, .5, .75, 1).map(t => {
  let c = (orange, red, green, blue).map(x => x.lighten(50%))
  fletcher.diagram(
    debug: "grid.cells",
    spacing: 2mm,
    node-corner-radius: 3pt,
    node((0, 0), [a], fill: c.at(0), width: 10mm, height: 10mm),
    node((1, 0), [b], fill: c.at(1), width: 5mm, height: 5mm),
    node((t, -1), $(#t, 1)$, fill: c.at(2), width: 20mm, height: 5mm),
    node((0, -2), [d], fill: c.at(3), width: 5mm, height: 5mm),
  )
}))

If you don't want a tabular layout, and don't want the position of nodes to be affected by other nodes' sizes, you can @manual-cetz[place nodes and edges directly inside a CeTZ canvas instead].


== Math-mode diagrams <math-mode-diagrams>

Nodes can also be specified using equations with alignment points `&` separating columns and newlines `\` separating rows.

#example(```typ
#diagram(
  $
    A & X \
    Y & X +_A Y
  $,
  edge((0,0), "-->", (1,1), from: -90deg, to: 90deg, snap-method: "move")
)
```)

*Important:* To use @node and @edge inside equations, the @edge.in-math[`in-math`] option must be enabled.
It can be convenient to define an alias such as
```
#let hom = edge.with(in-math: true)
```
when using equation-based layouts.
For example:
#example(```typ
#let hom = edge.with(in-math: true)
#diagram($
	G hom(f, ->) hom("d", pi, ->>) & im(f) \
	G slash ker(f) hom("ur", tilde(f), "hook-->", #bottom)
$)
```)

== Placing nodes in cells <node-cells>

A node in a flexigrid lives inside a _flexigrid cell_, which is visible when the @debug.node.cell debug option is on.
Below, the circular node's flexigrid cell is shaded:

#example(```typ
#diagram(
  debug: "grid.coords",
  node-stroke: 1pt,
  node((0,0), radius: 5mm, debug: "node.cell"),
  node((0,1))[This is a wide node],
)
```)

Nodes placed at fractional coordinates get their own cell, which is defined by a linear interpolation.
For example, below the circle's cell is shown as it moves along $(0, 0) -> (1, 1)$.

#frame-row(..(0, 1/3, 2/3, 1).map(x => {
  diagram(
    debug: "grid.coords",
    node-fill: teal.lighten(50%),
    node-stroke: 0.5pt,
    spacing: 2mm,
    node((x,x), radius: 2mm, debug: "node.cell"),
    node((0,1))[Wide],
    node((1,0), rotate(90deg, reflow: true)[Tall]),
  )
}))

This behaviour guarantees that a small nudge in a node's position only results in a small change to the diagram's final appearance.

=== Alignment within cells

If a node's cell is larger than its bounding box (visible with @debug.node.bounds), you can align the node within the cell using @node.align.
By default, nodes are placed in the center of their cell.

#example(```typ
#diagram(
  node-stroke: 1pt,
  node((0,0), radius: 5mm, debug: "node.cell node.bounds",
    align: right),
  node((0,1))[This is a wide node],
)
```)

=== Making nodes fill their cell

By default, the width and height of a node is determined by its @node.body[body content], plus an @node.inset[inset].
You can force a node to fill its cell by using the special values `width: "cell"` or `height: "cell"`.
Similarly, you can force a node to fit to its body with `width: "body"` or `height: "body"`.

#example(```typ
#diagram(
  node-stroke: 1pt,
  node((0,0), width: "cell")[_little node_],
  node((0,1))[This is a wide node],
)
```)

This can be useful to ensure the edges of nodes are aligned.

#example(```typ
#diagram(
  spacing: 5pt,
  node-stroke: 1pt,
  node-shape: rect,
  node-width: "cell", // set node with to column width
  $
    "Grandeur 1" & 5 &   7 & 9    & 10 \
    "Grandeur 2" & 6 & 8.4 & 10.8 & 12
  $,
  edge((1,0), "uu,r,dd", "->", $times 1.4$),
)
```)



== Row and column span <sec-node-cellspan>

A node's cell can span multiple flexigrid rows or columns using @node.rowspan and @node.colspan.

#example(```typ
#diagram(
  debug: "grid",
  node-fill: teal.lighten(50%),
  node-stroke: 0.5pt,
  node-shape: rect,
  node((0,0), $X$),
  node((0,1), $Y$),
  node((1,0), rowspan: 2)[Two Rows],
  node((0,2), colspan: 2)[Two Columns],
)
```)

Note that @node.rowspan[`rowspan`] and @node.colspan[`colspan`] affect the size of the node's flexigrid cell, not the size of the node itself.
However, if the row or column span is not `none`, the node's height or width defaults to `"cell"`, causing the node to fill the rows or columns it spans.
But you can still place a node across multiple cells while giving it a custom size, which is useful if you want to align a node within a group of cells.
In particular, the special width or height value `"body"` forces the node to fit to its body, rather than its flexigrid cell.

#example(```typ
#diagram(
  debug: "node.cell",
  spacing: (1cm, 5mm),
  node-fill: green.lighten(50%),
  node-stroke: 0.5pt,
  node((0,0), $A B C$),
  node((1,0), $D E F$),
  node((0,1), colspan: 2, [Column width]),
  node((0,2), [Body width],
    colspan: 2,
    align: right,
    width: "body", // fit node to body, not columns
  ),
)
```)

Row and column spans only work inside a flexigrid.
@enclose-nodes are similar, but instead of spanning flexigrid cells, they span other nodes.


== The flexigrid layout algorithm


To render a diagram, fletcher first collects the row/column positions (or $u v$ coordinates) of all nodes in the diagram and calculates the row and column sizes for the flexigrid layout.
After the final flexigrid is determined, all nodes, edges and other objects are drawn in a context where both $u v$ coordinates and normal $x y$ coordinates can be used.

If nodes have fractional $u v$ coordinates, an iterative algorithm is used to calculate the minimum row and column sizes which accommodate the nodes.
This usually requires only a few steps (see the @flexigrid.max-layout-iterations option for details).
