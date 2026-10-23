#import "../../src/exports.typ" as fletcher: diagram, node, edge

#let hom = edge.with(in-math: true)

#diagram(
	spacing: (1em, 3em),
	$
		& tau^* (bold(A B)^n R slash.double R^times) hom(->) &
		bold(B)^n R slash.double R^times \
		X hom("ur", "-->") hom("=") &
		X hom(->, tau) hom("u", <-) &
		bold(B) R^times hom("u", <-)
	$,
	edge((0,1), "d,rr,u", "->>", text(blue, $Gamma^*_R$),
		stroke: blue, label-side: center)
)
