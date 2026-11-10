#import "../../src/exports.typ" as fletcher: diagram, node, edge
#let hom = edge.with(in-math: true)

#diagram($
  V hom(->, f) hom("-tilde'->", "d", kappa_X, #right) &
  W hom("-tilde'->", "d", kappa_Y, #right) \
  K^n hom(->, tilde(f), #bottom, label-sep: #6pt) & K^m
$)
