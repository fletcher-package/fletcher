#import "../common.typ": *
#show: style


= Diagrams and Layout

Fletcher encourages the use of an flexible, tabular layout called a _flexigrid_.
Flexigrids have rows and columns which grow to accommodate nodes, like a table.
Unlike tables, flexigrids allow nodes to be placed at fractional coordinates.
You can see the flexigrid using @debug.grid.

#example(```typ
#diagram(
  debug: "grid",
  node-stroke: 0.5pt,
  node((0,0), $A A A$),
  node((1,0), $B$),
  node((0,1), $C$),
  node((1,1), $ D\ D\ D $),
  node((0.5, 0.5), $E$),
)
```)

If you don't want the positions of nodes to be affected by node sizes, you can @manual-cetz[place notes directly inside a CeTZ canvas instead].


== Math-mode diagrams

Nodes can be specified using equations with alignment points `&` separating columns and newlines `\` separating rows.

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

By default, the width and height of a node is determined by its @node.body[body].
You can force a node to enlarge to the size of its cell by using the special values `width: "cell"` or `height: "cell"`.
Similarly, you can force a node to fit to its body with `width: "body"` or `height: "body"`.

#example(```typ
#diagram(
  node-stroke: 1pt,
  node((0,0), width: "cell")[_little node_],
  node((0,1))[This is a wide node],
)
```)

This can be useful for achieving table-like outlines:

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



=== Row and column span <sec-node-cellspan>

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
