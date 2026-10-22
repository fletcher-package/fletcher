#import "../../src/exports.typ" as fletcher: diagram, node, edge

#let hom = edge.with(in-math: true)
#diagram(
  $
    A hom(->, f) hom("d", ->, g) & X hom("d", ->, iota_Y, #right) \
    Y hom(->, iota_X, #bottom) & X +_A Y
  $,
  // for a pushout, use a `corner` mark
  // and a blank ` ` line style
  edge((0,0), (1,1), " corner", outset: 5pt)
)
