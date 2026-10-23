#import "../../src/exports.typ" as fletcher: diagram, node, edge

#diagram(
  node-fill: teal.lighten(40%),
  node-stroke: 0.7pt + black,
  node((0,1), [0], name: "0", extrude: (0,3), outset: 3*.7pt),
  node((0,0), [1], name: "1"),
  node((1,1), [2], name: "2"),
  node((2,1), [3], name: "3"),
  node((1,0), [4], name: "4"),
  node((2,0), [5], name: "5"),

  edge(<0>, <1>, $b$, "->"),
  edge(<0>, <2>, $a$, "->"),
  edge(<1>, $a$, "->", loop: top),
  edge(<1>, <4>, $a$, "->"),
  edge(<2>, <3>, label: ($a$, (body: $b$, side: bottom)), "harpoon=harpoon'"),
  edge(<2>, <4>, $b$, "->"),
  edge(<3>, $a$, "->", loop: right),
  edge(<4>, <0>, $a$, "->"),
  edge(<4>, <5>, label: ($a$, (body: $b$, side: bottom)), "harpoon=harpoon'"),
  edge(<5>, $b$, "->", loop: right),
)