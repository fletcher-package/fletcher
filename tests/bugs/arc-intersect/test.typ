#set page(width: auto, height: auto, margin: 1em)
#import "/src/exports.typ" as fletcher: cetz, diagram, edge, node

#grid(
  columns: (2cm,)*5,
  rows: 2cm,
  stroke: 0.5pt + red,
  align: center + horizon,
  ..range(20).map(i => {
    let a = 20deg + 3.3deg*i
    context diagram(
      spacing: 17mm,
      node((0,0)),
      node((1,0)),
      cetz.draw.floating({
        edge((0, 0), "->", (1, 0), bend: +a, name: <f>)
        edge((0, 0), "->", (1, 0), bend: -a, name: <g>)
        edge(<f>, "=", <g>, snap-method: "trim")
      })
    )
  })
)
