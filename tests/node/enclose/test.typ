#set page(width: auto, height: auto, margin: 1em)
#import "/src/exports.typ" as fletcher: diagram, node, edge, cetz

#diagram(
  spacing: 10pt,
  node-fill: yellow,
  node-corner-radius: 2pt,
  node((0,0), $a$, <a>),
  edge("->"),
  node((1,1), $b$, <b>),
  node((1,0), $c$, <c>),
  node((0,1), $d$, <d>),
  node(enclose: (<a>, <b>, <c>, <d>), fill: teal.lighten(50%)),
  edge((1,0),  "rr,d,ll", "->")
)
