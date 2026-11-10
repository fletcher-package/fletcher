#set page(width: auto, height: auto, margin: 1em)
#import "/src/exports.typ" as fletcher: diagram, node, edge, cetz

#diagram(
  debug: "node.inset",
  node-fill: gray,
  node((0,0), [Inset])
)

#diagram(
  debug: "node",
  node-outset: 5pt,
  node((0,0), [A])
)

#diagram(
  debug: "node.outset edge.snap",
  node-outset: 5pt,
  node((0,0), [A]),
  edge(bend: 30deg, "->"),
  node((1,1), [B]),
)
