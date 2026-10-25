#set page(width: auto, height: auto, margin: 1em)
#import "/src/exports.typ" as fletcher: diagram, node, edge, cetz

#diagram(
  node-stroke: 1pt,
  spacing: 5pt,
  node((0,0), colspan: 2, [Center aligned]),
  node((0,1), colspan: 2, align(right)[Right aligned]),
  node((0,2), align(top)[Top\ aligned], height: 2cm),
  node((1,2), align(bottom)[Bottom\ aligned], height: 2cm),
  node((0,3), colspan: 2, align(left)[Left aligned]),
)

#pagebreak()

#cetz.canvas({
  cetz.draw.set-style(node: (stroke: 1pt))
  node((0,0), align(right)[Right aligned], width: 4cm)
})
