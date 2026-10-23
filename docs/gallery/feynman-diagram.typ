#import "../../src/exports.typ" as fletcher: cetz, node, edge

#cetz.canvas({
	let (p1, p2, p3) = ((0,0), (0,1), (1,1.5))
	edge(p1, "-<|-", "lld", $q$, bottom)
	edge(p1, "-|>-", p2)
	edge(p2, "-|>-", "llu", $overline(q)$)
	edge(p2, "~", p3, $Z'$, label-pos: 0.65)
	edge(p3, "-|>-", (rel: (1, +.7)), $b$)
	edge(p3, "-|>-", (rel: (1, -.7)), $overline(b)$, bottom)
	edge(p1, "~", "rrd", $gamma$, bottom)
})
