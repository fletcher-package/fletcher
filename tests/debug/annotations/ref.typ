#set page(width: auto, height: auto, margin: 1em)
#import "/src/exports.typ" as fletcher: diagram, node, edge, cetz

#diagram(
  node-fill: gray,
  node((0,0), [Inset], debug: "node.inset")
)

#diagram(
  node-outset: 5pt,
  node((0,0), [A], debug: "node")
)

#diagram(
  node-outset: 5pt,
  node((0,0), [A], debug: "node.outset"),
  edge(bend: 30deg, "->", debug: "edge.snap"),
  node((1,1), [B], debug: "node.outset"),
)
