#import "../../src/exports.typ" as fletcher: diagram, node, edge, cetz
#import fletcher.shapes: house, hexagon

#let blob(pos, label, tint: white, ..args) = node(
	pos, align(center, label),
	width: 28mm,
	fill: tint.lighten(60%),
	stroke: 1pt + tint.darken(20%),
	corner-radius: 5pt,
	..args,
)

#let solid-marks-as-default = cetz.draw.set-style(fletcher-marks: (
  ">": (inherit: "solid", rev: false),
  "<": (inherit: "solid", rev: true),
))

#diagram(
	spacing: 15pt,
	edge-stroke: 1pt,
	edge-corner-radius: 5pt,
	mark-scale: 70%,
	solid-marks-as-default,

	blob((0,1), [Add & Norm], tint: yellow, shape: "hexagon"),
	edge(),
	blob((0,2), [Multi-Head\ Attention], <mha>, tint: orange),
	blob((0,4), [Input], <in>, shape: "house", angle: 30deg,
		width: auto, tint: red),

	edge(<in>, <mha>, "->"),
	edge(<in>, "->", (to: <mha>, rel: (+15pt, 0)), corner: "|-|"),
	edge(<in>, "->", (to: <mha>, rel: (-15pt, 0)), corner: "|-|"),

	edge((0,4), "l,uuu,r", "-->"),
	edge((0,1), (0,0.35), "r", (1,3), "r,u", "->"),
	edge((1,2), "d,rr,uu,l", "-->"),

	blob((2,0), [Softmax], tint: green),
	edge("<-"),
	blob((2,1), [Add & Norm], tint: yellow, shape: "hexagon"),
	edge(),
	blob((2,2), [Feed\ Forward], tint: blue),
)
