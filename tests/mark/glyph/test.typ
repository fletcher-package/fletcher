#set page(width: auto, height: auto, margin: 1em)
#import "/src/exports.typ" as fletcher: diagram, node, edge, cetz

#diagram(
  for i in range(8) {
    edge((0,0), (rel: (45deg*i, 1cm)), "-tilde-")
    edge((3,0), (rel: (45deg*i, 1cm)), "-tilde'-")
  }
)

#diagram(edge("-tilde->"))
#diagram(edge("-tilde'->"))
#diagram(edge("=tilde=>"))
#diagram(edge("=tilde'=>"))
