#set page(width: auto, height: auto, margin: 1em)
#import "/src/exports.typ" as fletcher: diagram, node, edge, cetz

#diagram(
  edge((0,0), (1,1)),
  edge((0,1), (1,0), crossing: true),
)

#diagram(
  edge-crossing-thickness: 5,
  edge((0,0), (1,1)),
  edge((0,1), (1,0), crossing: true),
)

#diagram(
  edge((0,0), (1,1)),
  edge((0,1), (1,0), crossing: true, crossing-fill: yellow),
)
