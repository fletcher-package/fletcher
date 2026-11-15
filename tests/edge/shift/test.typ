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
