#import "../../src/exports.typ" as fletcher: diagram, edge, node

#import fletcher.cetz.draw: group, set-style

#diagram(
  node-stroke: 0.8pt,
  node-radius: 2.5pt,
  node-fill: yellow,
  spacing: (20pt, 10pt),
  {
    for y in range(6) {
      node((0, y))
      node((-0.5, y), $q^#y$, stroke: none, fill: none)
    }

    edge((0, 0), auto, corner: "-|")
    edge((0, 1), auto, "--", corner: "-|")
    node((1, 0.5), <a>)

    edge((0, 2), auto, corner: "-|")
    edge((0, 3), auto, corner: "-|", $ * $, center)
    edge((0, 4), auto, corner: "-|")
    node((1, 3), <b>)

    edge(<a>, auto, "--", corner: "-|")
    edge(<b>, auto, corner: "-|")
    node((2, 1.75), <c>)

    edge((0, 5), "rrr,uu")
    edge(<c>, (3, 3), "--", corner: "-|")
    node((3, 3))
    edge("--|>")

    node((4, 3), $Q^*$, shape: rect, fill: none)
  },
)
