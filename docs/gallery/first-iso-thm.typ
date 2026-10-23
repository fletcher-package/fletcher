#import "../../src/exports.typ" as fletcher: diagram, node, edge

#let hom = edge.with(in-math: true)
#diagram(spacing: 15mm, $
	G hom(f, ->) hom("d", pi, ->>) & im(f) \
	G slash ker(f) hom("ur", tilde(f), "hook-->", #bottom)
$)
