#set page(width: auto, height: auto, margin: 1em)
#import "/src/exports.typ" as fletcher: cetz, diagram, edge, node

#diagram(
  node-fill: orange,
  node((0, 0), $A$),
  edge("->", shift: +2pt),
  edge("<-", shift: -2pt),
  node((1, 0), $B$),
)


#diagram(
  node-fill: teal,
  node((0, 0), $A$),
  edge("-|>", bend: 40deg, shift: -2pt),
  edge("<|-", bend: 40deg, shift: +2pt),
  node((1, 0), $B$),
)


// Pairs shift each end independently.
#diagram(
  node-stroke: 0.5pt,
  node((0, 0), $A$, name: <a>),
  node((2, 0), $B$, name: <b>),
  node((2, 1), $C$, name: <c>),
  edge(<a>, <b>, "->", shift: (0pt, +6pt)),
  edge(<a>, <b>, "->", shift: (0pt, -6pt)),
  edge(<a>, "d", <c>, "->", shift: (6pt, 0pt)),
  edge(<a>, "d", <c>, "->", shift: (0pt, 6pt)),
)

// Equal pairs (black) match single shifts (red) on lines, arcs, corners, and polylines.
#let compare(..args) = diagram(
  node-stroke: 0.5pt,
  node((0, 0), $A$, name: <a>),
  node((2, 1), $B$, name: <b>),
  edge(<a>, ..args, <b>, stroke: 4pt + red.transparentize(50%), shift: 6pt),
  edge(<a>, ..args, <b>, "->", shift: (6pt, 6pt)),
)
#compare()
#compare(bend: 40deg)
#compare(corner: "-|")
#compare("r,d")
#compare((rel: (1.5, 0.3)))

// The legs between the ends of a polyline step evenly between the two shifts.
#diagram(
  node-stroke: 0.5pt,
  node((0, 0), $A$, name: <a>),
  node((2, 1), $B$, name: <b>),
  edge(<a>, "r,d", <b>, stroke: gray),
  edge(<a>, "r,d", <b>, "->", shift: (-6pt, 6pt)),
)
