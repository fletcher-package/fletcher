#set page(width: auto, height: auto, margin: 1em)
#import "/src/exports.typ" as fletcher: diagram, node, edge, cetz

#for (i, shape) in fletcher.shapes.NODE_SHAPES.keys().enumerate() {
  let c = color.hsv(i*40deg, 50%, 100%)
  let cells = (0, 0.5, 1).map(fit => {
    diagram(node((0,0),
      box(width: 10mm, height: 5mm),
      inset: 0,
      shape: shape,
      fill: c,
      stroke: c.darken(20%),
      debug: "node.body",
      fit: fit,
    ))
  })
  page(grid(columns: 3, align: horizon, inset: 5mm, stroke: red + 0.5pt, ..cells))

}
