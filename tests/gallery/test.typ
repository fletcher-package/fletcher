#set page(width: auto, height: auto, margin: 5mm)

#let render-example(name) = {
	let src = read("/docs/gallery/" + name + ".typ")
		.replace(regex("@preview/fletcher:\d+\.\d+.\d+"), "/src/exports.typ")
	page(eval(src, mode: "markup"))
}

#(
	"commutative",
	"algebra-cube",
	"ml-architecture",
	// "io-flowchart",
	"digraph",
	"node-groups",
	"uml-diagram",
	"tree",
	"feynman-diagram",
	"category-theory",
	"block-diagram",
).map(render-example).join()
