#import "../../src/exports.typ" as fletcher: diagram, node, edge

#diagram(
  spacing: 2pt,
  node-stroke: 1pt,
  node-shape: rect,
  node-width: "cell", // make all nodes fill table columns
  $
    "Grandeur 1" & 5 &   7 & 9    & 10 \
    "Grandeur 2" & 6 & 8.4 & 10.8 & 12
  $,
  edge((1, -0.8), "r", "-|>", bend: 90deg, label: $times 1.4$),
  edge((4.9, 0), "d", "-|>", bend: 90deg, label: $times 1.2$),
)
