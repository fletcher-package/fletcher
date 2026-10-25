#set page(width: auto, height: auto, margin: 1em)
#import "/src/exports.typ" as fletcher: diagram, node, edge, cetz


#diagram(
  spacing: 10pt,
  node-stroke: 1pt,
  node-fill: white,
  node-corner-radius: 2pt,
  node((0,0), [Sight], name: <sight>),
  node((1,0), [Sound]),
  node((2,0), [Smell], name: <smell>),
  node((0,1), [Senses], colspan: 3),
  node((0,0), rowspan: 2, colspan: 3,
    fill: yellow, extrude: 4pt, layer: -1)[],
)

#pagebreak()

Positive/negative row/colspans

#diagram(
  node-stroke: 0.5pt,
  node-shape: rect,
  node-fill: luma(0%, 10%),
  node-corner-radius: 0pt,
  spacing: 6pt,

  node((0,0), [A]),
  node((1,1), [B]),
  node((2,2), [C]),

  node((0,0), $->$, colspan: 2, rowspan: 1, extrude: 3pt,),
  node((2,0), $arrow.t$, rowspan: 2),
  node((0,2), $arrow.b$, rowspan: -2),
  node((2,2), $<-$, colspan: -2, rowspan: 1, extrude: 3pt),
)

#pagebreak()

Cellspan with non-cell width

#diagram(
  node-fill: teal,
  spacing: 5pt,
  node((0,0), [Left]),
  node((1,0), [Right]),
  node((0,1), [Aligned], colspan: 2, width: "body", align: right),
  node((0,2), [Fullwidth], colspan: 2, align: right),
)