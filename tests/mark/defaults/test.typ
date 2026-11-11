#set page(width: auto, height: auto, margin: 1em)
#import "/src/exports.typ" as fletcher: diagram, node, edge, cetz

#import cetz.draw: set-style

Default mark style:

#diagram(edge("<->"))

Set from `cetz` style:

#diagram(
  set-style(fletcher-marks: (
    ">": (inherit: "solid", rev: false),
    "<": (inherit: "solid", rev: true),
  )),
  edge("<->")
)
