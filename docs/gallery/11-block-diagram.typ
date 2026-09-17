#import "@preview/fletcher:0.6.0" as fletcher: diagram, node, edge

#diagram(
	spacing: 5mm,
	node-stroke: 1pt,
  node-fill: white,
	node-corner-radius: 2pt,
	edge-stroke: 1pt,     // make lines thicker
	mark-scale: 60%,      // make arrowheads smaller

	node((-3,0), radius: 2pt, fill: black),
	edge("r,u,rr", "-|>", $f$),
	edge("r,d,rr", "..|>", $g$),

	node((0,-1), $F(s)$, colspan: 2, <f>),
	edge("-|>", (3,0), corner: "-|"),

	node((0,+1), $G(s)$, <g>),
	edge("-|>"),
	node((1,+1), $H(s)$, <g>),
	edge("..|>", (3,0), corner: "-|"),

	node((3,0),
    text(white, $ plus.o $),
		inset: 2pt,
    fill: black,
  ),
	edge("-|>", "r"),

	node(enclose: (<f>, <g>),
		inset: 10pt,
		stroke: teal,
		fill: teal.transparentize(90%)
  ),
)