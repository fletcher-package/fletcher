#import "utils.typ"
#import "deps.typ": cetz
#import "debug.typ": DEBUG_STYLES, debug-group, debug-level, get-debug
#import "shapes.typ": DEFAULT_NODE_STYLE, NODE_SHAPES
#import "parsing.typ"

// Node box model:
//
// - Content
// - placed/aligned inside a body
// - enclosed by a shape
// - (if in a flexigrid) placed/aligned inside a cell
//
// Content is given a padding controlled by @node-inset.
// The `width` and `height` options control the body size.
// The node shape encloses the body by default


#let draw-node-snapping-outline(ctx, node, origin, outset) = {
  let bounds-center = cetz.vector.neg(cetz.vector.lerp(node.bounds.high, node.bounds.low, 0.5))
  cetz.draw.group({
    cetz.draw.translate(cetz.vector.add(node.pos, bounds-center))
    (node.style.draw)((
      size: node.body-size,
      style: node.style,
      unit-length: ctx.length,
      extrude: outset,
    ))
  })
}

#let draw-node-at(node, origin, debug: false) = {
  let bounds-center = cetz.vector.neg(cetz.vector.lerp(node.bounds.high, node.bounds.low, 0.5))
  let translate-to-origin = cetz.draw.translate(cetz.vector.add(origin, bounds-center))

  (
    ctx => {
      let objs = {
        translate-to-origin

        for (i, extrude) in node.style.extrude.enumerate() {
          cetz.draw.set-style(..node.style, fill: if i == 0 { node.style.fill })
          (node.style.draw)((
            size: node.body-size,
            style: node.style,
            unit-length: ctx.length,
            extrude: extrude,
            cell: node.cell,
          ))
          cetz.draw.content(..utils.rect-lo-hi(size: node.body-size), node.body)
        }
      }

      if node.style.layer != 0 {
        objs = cetz.draw.on-layer(node.style.layer, objs)
      }
      let group = cetz.draw.group(objs, name: node.name)
      return group.first()(ctx)
    },
  )

  debug-group(layer: 10, {
    if node.cell != none and debug-level(debug, "node.cell") {
      cetz.draw.rect(..utils.rect-lo-hi(..node.cell), ..DEBUG_STYLES.node.cell)
    }

    if debug-level(debug, "node.outset") {
      cetz.draw.group({
        cetz.draw.get-ctx(ctx => {
          cetz.draw.set-style(..DEBUG_STYLES.node.outset)
          draw-node-snapping-outline(ctx, node, node.pos, node.style.outset)
        })
      })
    }

    translate-to-origin

    if debug-level(debug, "node.origin") {
      cetz.draw.circle((0, 0), radius: 0.8pt, fill: red, stroke: none)
    }
    if debug-level(debug, "node.body") {
      cetz.draw.rect(..utils.rect-lo-hi(size: node.body-size), ..DEBUG_STYLES.node.body)
    }
    if debug-level(debug, "node.bounds") {
      cetz.draw.rect(node.bounds.low, node.bounds.high, ..DEBUG_STYLES.node.bounds)
    }
  })
}


#let resolve-node-shape(ctx, node-styles, node) = {
  let shape = node.shape

  // a node shape is a dictionary with a `draw` entry
  let all-shapes = NODE_SHAPES
  // other shapes can be specified via
  // set-style(node: ((shape-name): (..)))
  for (k, v) in node-styles {
    if type(v) == dictionary and "draw" in v {
      all-shapes.insert(k, v)
    }
  }

  // be forgiving
  let aliases(it) = {
    if it in (std.circle, cetz.draw.circle) { return "circle" }
    if it == std.ellipse { return "ellipse" }
    if it in (std.rect, cetz.draw.rect) { return "rect" }
    if it == none { return "none" }
    return it
  }
  shape = aliases(shape)

  // use default shape unless node has styles for that shape
  let default-shape = node-styles.at("shape", default: auto)
  if default-shape != auto {
    default-shape = aliases(default-shape)
    let valid-args = {
      all-shapes.at(default-shape).keys()
      DEFAULT_NODE_STYLE.keys()
    }
    if node.style.keys().all(k => k in valid-args) {
      shape = default-shape
    }
  }

  if shape == auto {
    // deduce node shape from style options
    // given as named arguments to node(..)
    // e.g., `radius` implies circle
    for (name, (..options, draw)) in all-shapes {
      if node.style.keys().any(o => o in options) {
        shape = name
        break
      }
    }
  }

  if shape == auto {
    // if no shape is matched to node arguments
    // default shape can be given via set-style(node: (shape: ..))
    if "shape" in node-styles {
      shape = node-styles.shape
    }
  }

  if shape == auto {
    // just guess shape from node body
    if node.enclose != none {
      shape = "rect"
    } else if node.cellspan != (none, none) {
      shape = "rect"
    } else {
      // choose based on body size and aspect ratio
      // this works best when nodes have no stroke, like in
      // commutative diagrams: single letters become circles
      // making edges connect more evenly
      let (w, h) = cetz.util.measure(ctx, [#node.body])
      if calc.max(w, h) > 2em.to-absolute() / ctx.length {
        shape = "rect"
      } else {
        // guess typical padding
        let inset = 0.5em.to-absolute() / ctx.length
        w += inset
        h += inset
        if calc.max(w / h, h / w) < 1.5 {
          shape = "circle"
        } else {
          shape = "rect"
        }
      }
    }
  }

  if shape not in all-shapes {
    utils.error("Unknown node shape #0. Try: #..1", repr(shape), all-shapes.keys())
  }

  // check no unknown style arguments are given for shape
  // (this is especially important for discoverability)
  let valid-args = {
    all-shapes.at(shape).keys()
    DEFAULT_NODE_STYLE.keys()
  }
  let invalid-args = node.style.keys().filter(arg => arg not in valid-args)
  if invalid-args.len() > 0 {
    utils.error(
      "Unknown node option #..invalid. Options for #shape nodes: #..valid",
      invalid: invalid-args,
      shape: shape,
      valid: valid-args,
    )
  }

  return shape
}

#let resolve-node-styles(ctx, node) = {
  // get style defaults (not yet with the node's specific styles)
  let node-styles = cetz.styles.resolve(
    {
      // collect default styles
      DEFAULT_NODE_STYLE
      NODE_SHAPES
      // change default layer for enclose nodes
      if node.enclose != none { (layer: -2) }
      // change default width/height for nodes with cellspan
      if node.cellspan.at(0) not in (none, 0) { (width: "cell") }
      if node.cellspan.at(1) not in (none, 0) { (height: "cell") }
    },
    merge: ctx.style.at("node", default: (:)),
  )

  node.shape = resolve-node-shape(ctx, node-styles, node)

  // resolve styles so that:
  // - node(prop: val) takes highest precedence
  // - set-style(node: (shape: (prop: val))) affects nodes of a given shape
  // - set-style(node: (prop: val)) affects all nodes not specified above
  // - set-style(prop: val) doesn't affect nodes at all
  let style = cetz
    .styles
    .resolve(
      node-styles,
      base: (
        (node.shape): DEFAULT_NODE_STYLE.keys().map(k => (k, auto)).to-dict(),
      ),
      merge: ((node.shape): node.style),
    )
    .at(node.shape)

  if "draw" not in style {
    utils.error("node shape does not have a `draw` field; got `#0: #1`", node.shape, repr(style))
  }

  // resolve lengths to dimensionless numbers

  let thickness = cetz.util.resolve-number(ctx, utils.get-thickness(style.stroke))
  style.extrude = utils
    .one-or-array(style.extrude)
    .map(e => {
      if type(e) == length { cetz.util.resolve-number(ctx, e) } else if type(e) in (int, float) { e * thickness }
    })

  style.outset = cetz.util.resolve-number(ctx, style.outset)

  return style
}


#let measure-content(ctx, it) = {
  measure(it).values().map(x => utils.to-length(x, to-float: ctx.length))
}

#let measure-node-bounds(ctx, node) = {
  let shape = (node.style.draw)((
    size: node.body-size,
    extrude: 0,
    unit-length: ctx.length,
    style: node.style + (fit: node.style.fit * node.style.fit-cell),
  ))
  return cetz.process.many(ctx, shape).bounds
}

#let resolve-body-size(ctx, node) = {
  let (w, h) = node.content-size

  if "width" in node.style {
    if node.style.width == "body" {
      // keep w as node width
    } else if node.style.width == "cell" {
      if node.cell != none {
        w = node.cell.size.at(0)
      }
    } else if node.style.width != auto {
      w = node.style.width
    }
  }
  if "height" in node.style {
    if node.style.height == "body" {
      // keep h as node height
    } else if node.style.height == "cell" {
      if node.cell != none {
        h = node.cell.size.at(1)
      }
    } else if node.style.height != auto {
      h = node.style.height
    }
  }

  w = utils.to-length(w, to-float: ctx.length)
  h = utils.to-length(h, to-float: ctx.length)
  return (w, h)
}


#let apply-body-inset(ctx, node) = {
  let (body, style, debug) = node
  if body == none { return }

  let inset = cetz
    .util
    .as-padding-dict(style.inset)
    .pairs()
    .map(((k, v)) => (k, utils.to-length(v, units-of: ctx.length)))
    .to-dict()

  let wrapper(it) = {
    show: box.with(inset: inset)
    set text(top-edge: "cap-height", bottom-edge: "baseline")
    if debug-level(debug, "node.inset") {
      it = rect(it, ..DEBUG_STYLES.node.inset, inset: 0pt)
    }
    it
  }

  show: align.with(center + horizon)
  if type(body) == content and body.func() == std.align {
    // preserve outer align element
    std.align(body.alignment, wrapper(body.body))
  } else {
    wrapper(body)
  }
}


/// Resolve an enclose node given the final layout information
/// about all preceding nodes.
#let resolve-enclose-node(ctx, data, preceding-nodes) = {
  let node-corners(node) = {
    return (
      cetz.vector.add(node.bounds.low, node.pos),
      cetz.vector.add(node.bounds.high, node.pos),
    )
  }

  let key-to-points(key) = {
    if type(key) == label {
      let node = preceding-nodes.find(n => n.name == str(key))
      if node == none {
        utils.error("Cannot find node with name #0. Hint: Enclose nodes must be after the nodes they enclose.", key)
      }
      return node-corners(node)
    } else {
      // find node with exact same position as key
      let node = preceding-nodes.find(n => n.uv-pos == key)
      if node != none {
        return node-corners(node)
      }

      let coord = utils.interpret-as-uv(key)
      let (_, (x, y, ..)) = cetz.coordinate.resolve(ctx, coord)

      return ((x, y),)
    }
  }

  let pts = data.enclose.map(key-to-points).join()
  let bounds = cetz.util.bezier.aabb.aabb(pts)
  let padding = cetz
    .util
    .as-padding-dict(data.style.inset)
    .pairs()
    .map(((k, v)) => (k, cetz.util.resolve-number(ctx, v)))
    .to-dict()

  bounds.low.at(0) -= padding.left
  bounds.low.at(1) -= padding.bottom
  bounds.high.at(0) += padding.right
  bounds.high.at(1) += padding.top

  data.pos = cetz.vector.lerp(bounds.low, bounds.high, 0.5)
  data.bounds = (
    high: cetz.vector.sub(bounds.high, data.pos),
    low: cetz.vector.sub(bounds.low, data.pos),
  )
  data.body-size = cetz.vector.sub(bounds.high, bounds.low).slice(0, 2)
  data
}

#let _node(
  ..options,
  debug: auto,
) = {
  let data = (
    class: "node",
    pos: options.position,
    body: options.body,
    shape: options.shape,
    style: options.style,
    name: options.name,
    align: options.align,
    // weight: options.weight,
    enclose: options.enclose,
    snap: options.snap,
    cellspan: options.cellspan,
    cell: none, // size of enclosing flexigrid cell, if any
  )

  let resolve-node-data(ctx, data) = {
    data.style = resolve-node-styles(ctx, data)
    data.body = apply-body-inset(ctx, data)
    data.content-size = measure-content(ctx, data.body)
    data.body-size = resolve-body-size(ctx, data)
    data.bounds = measure-node-bounds(ctx, data)
    return data
  }

  // open question: should this be explicitly memoised between passes?
  let draw-and-process(ctx, data) = {
    cetz.process.many(ctx, {
      draw-node-at(data, data.pos, debug: data.debug)
    })
  }

  (
    ctx => {
      if "fletcher" not in ctx.shared-state {
        // node is not inside a flexigrid
        // but fletcher state is still needed for e.g., automatic edge-node snapping
        ctx.shared-state.fletcher = (
          pass: none,
          nodes: (),
        )
      }
      let fletcher-ctx = ctx.shared-state.fletcher

      if "current-node" in fletcher-ctx {
        ctx.shared-state.fletcher.current-node += 1
      }

      let data = data
      data.debug = get-debug(ctx, debug)

      if fletcher-ctx.pass == "layout" {
        // In the layout pass, we only care about resolving the positions
        // and sizes of nodes and recording this in shared ctx for later.

        data = resolve-node-data(ctx, data)

        if data.enclose != none {
          // enclose nodes are positioned in the placement pass
          data.pos = utils.nans
        }

        // resolve uv coordinates now
        let pos = utils.interpret-as-uv(data.pos)
        let (ctx, uv) = cetz.coordinate.resolve(ctx, pos)
        data.uv-pos = if not uv.any(float.is-nan) { uv.slice(0, 2) }

        // do not draw anything in layout pass
        // but do register dummy anchors so coordinates depending on this node don't panic
        ctx.shared-state.fletcher.nodes.push(data)
        return (ctx: ctx, name: data.name, anchors: _ => (0., 0., 0.))
      } else if fletcher-ctx.pass == "placement" {
        // In the node placement pass, node positions and sizes are resolved.
        // This happens after the flexigrid is determined but before edges are processed.

        // restore data from layout pass
        data = fletcher-ctx.nodes.at(fletcher-ctx.current-node)

        if data.uv-pos != none {
          // this is a uv node
          data = (fletcher-ctx.place-node-in-flexigrid)(data)
          data.body-size = resolve-body-size(ctx, data)
        } else if data.enclose != none {
          // this is an enclose node
          let preceding-nodes = fletcher-ctx.nodes.slice(0, fletcher-ctx.current-node)
          data = resolve-enclose-node(ctx, data, preceding-nodes)
        } else {
          // this is an xy node
          let (_, xy) = cetz.coordinate.resolve(ctx, data.pos)
          if xy.any(float.is-nan) {
            utils.error("node coordinate #0 did not resolve (hint: nodes cannot depend on edges)", data.pos)
          }
          data.pos = xy
        }

        // pass data to state to be read in final pass
        ctx.shared-state.fletcher.nodes.at(fletcher-ctx.current-node) = data

        // since we need to resolve coordinates which might depend on anchors
        // continue and draw elements in the placement pass
        return draw-and-process(ctx, data)
      } else if fletcher-ctx.pass == "final" {
        // The node's position and size must be resolved by now (see placement pass).
        // Edges and nodes both read from `fletcher-ctx.nodes` as the source of truth
        // about nodes' final attributes.
        data = fletcher-ctx.nodes.at(fletcher-ctx.current-node)
        return draw-and-process(ctx, data)
      } else {
        // Node does not appear in a flexigrid.

        data = resolve-node-data(ctx, data)

        if data.enclose != none {
          // enclose nodes are resolved immediately
          // and can only see past nodes
          data = resolve-enclose-node(ctx, data, fletcher-ctx.nodes)
        }

        let (ctx, xy) = cetz.coordinate.resolve(ctx, data.pos)
        data.pos = xy
        ctx.shared-state.fletcher.nodes.push(data)

        return draw-and-process(ctx, data)
      }

      panic()
    },
  )
}


/// Place a _node_ in a diagram or CeTZ canvas.
///
/// Nodes are content which #[@edge]s can snap to.
/// Nodes can have various shapes (rect, circle), styles (fill, stroke).
#let node(
  ..args,
  /// Content to draw in the node.
  ///
  /// This content is measured to automatically determine the size of the node.
  /// The @debug.node.body debug option shows the body's bounding box after @node-inset is applied.
  ///
  /// For nodes without a body, note that @node-inset[inset] is applied if the body is empty content (`[]`),
  /// but not if the body is `none`.
  /// -> content
  body: none,
  /// The shape of the node's body enclosing its label.
  ///
  /// Built-in shapes are #fletcher.shapes.NODE_SHAPES.keys().map(it => raw(repr(it))).join(last: [ and ])[, ].
  ///
  /// Some node shapes accept other styling options which can be passed as arguments to @node.
  ///
  /// See also the @node-shapes section of the manual.
  /// -> auto | none | string
  shape: auto,

  /// Fill style of the node.
  ///
  /// The fill is drawn within the outline defined by the first @node-extrude value. For example:
  ///
  /// #example(```typ
  /// #diagram(
  ///   node-fill: yellow,
  ///   node-stroke: 1pt,
  ///   node((0,0), [A], extrude: (0, 3)),
  ///   node((1,0), [B], extrude: (3, 0)),
  /// )
  /// ```)
  ///
  /// _This option is a @node-styles[node style]._
  fill: auto,
  /// Stroke style for the node outline.
  ///
  /// _This option is a @node-styles[node style]._
  stroke: auto,
  /// Padding applied to the content in a node's body.
  ///
  /// The @debug.node.inset debug option draws a box around the
  /// body content before inset is applied.
  ///
  /// The inset can be a length like `5pt`, or a CeTZ-style array
  /// or dictionary: for example, `(0, 5pt)` for only horizontal
  /// padding; `(left: 5pt, rest: 10pt)` for per-edge padding.
  ///
  /// _This option is a @node-styles[node style]._
  ///
  /// -> length | array | dictionary
  inset: auto,
  /// Separation between the node's visible outline and the
  /// snapping target for edges.
  ///
  /// This does not affect the node's appearance or layout, only how closely edges connect to it.
  ///
  /// When @debug.node.outset debug option is on, the node outset
  /// drawn as a green dotted line.
  ///
  /// #example(```typ
  /// #diagram(
  /// 	debug: "node.outset",
  /// 	node-stroke: 1pt,
  /// 	node((0,0), [Hello]),
  /// 	edge("<->"),
  ///   node((1,0), [World], outset: 5pt, shape: "ellipse"),
  /// )
  /// ```)
  ///
  /// _This option is a @node-styles[node style]._
  ///
  /// See also @edge-outset, which controls how closely individual edges connect to nodes.
  /// -> length
  outset: auto,
  /// Draw strokes around the node at the given offsets to
  /// obtain a multi-stroke effect.
  /// Offsets can be numbers specifying multiples of the @node-stroke's thickness or lengths.
  ///
  /// The node's fill is drawn within the boundary defined by the first offset in
  /// the array.
  ///
  /// _This option is a @node-styles[node style]._
  /// -> array
  extrude: auto,
  /// Canvas layer to draw node on.
  ///
  /// The default layer for nodes is `0`, which is above edges (on layer `-1` by default; see @edge-layer).
  /// Enclose nodes are drawn on layer `-2` by default, under nodes and edges.
  /// Nodes with equal layer are drawn in the order they are inserted.
  ///
  /// _This option is a @node-styles[node style]._
  ///
  /// -> number
  layer: auto,
  /// Name of the node for use with coordinate anchors.
  ///
  /// This can also be passed as a positional argument (but then
  /// the name must be a label, not a string).
  /// -> label | str
  name: none,
  /// Align a node within its associated flexigrid cell.
  ///
  /// This only has effect when used inside a @diagram or @flexigrid.
  ///
  /// #frame-row(..(top + left, right).map(it => diagram(
  ///   debug: "node.cell",
  ///   spacing: 2pt,
  ///   node-fill: teal.lighten(50%),
  ///   node((0,0), align: it, raw(repr(it))),
  ///   node((0,1), width: 3cm, height: 5mm),
  ///   node((1,0), width: 5mm, height: 1cm),
  /// )))
  ///
  /// The node's associated cell is visible when the
  /// @debug.node.cell debug option is enabled.
  ///
  /// -> alignment
  align: center + horizon,
  /// How much the node influences the size of flexigrid rows/columns.
  ///
  /// If `0`, the node does not affect the flexigrid or other node positions.
  /// If `1`, rows and columns grow to fully accommodate the node.
  /// -> number
  weight: 1,
  /// Positions or names of nodes to be enclosed by this node.
  ///
  /// When set, the node's position must be unset (or `auto`).
  /// The node is automatically positioned and enlarged so that it
  /// encloses the specified nodes.
  ///
  /// #example(```typ
  /// #diagram(
  ///   node-stroke: 1pt,
  ///   node((0,0), [ABC], name: <A>),
  ///   node((1,1), [XYZ], name: <Z>),
  ///   node(
  ///     enclose: (<A>, <Z>),
  ///     text(teal)[Enclose node], stroke: teal,
  ///     name: <group>),
  ///   edge(<group>, (3,0.5), stroke: teal),
  /// )
  /// ```)
  ///
  /// -> array
  enclose: none,
  /// Whether this node can have edges automatically snap to it.
  /// -> bool
  snap: true,

  /// The number of columns spanned by the node's @node-cells[flexigrid cell].
  ///
  /// The column span can be positive (meaning the cell grows rightwards)
  /// or negative (leftwards), or even fractional.
  /// The cell must span at least one column, so the range of this
  /// parameter is $(-oo, -1] union [1, oo)$.
  ///
  /// If the column span is not `none`, then node's width defaults
  /// to the full size of its enclosing cell.
  ///
  /// #example(```typ
  /// #diagram(
  ///   spacing: 5pt,
  ///   debug: "node.cell",
  ///   node((0,0), colspan: 3, $x y z$),
  ///   node((0,1), rowspan: 2, $x$),
  ///   node((1,1), $y$),
  ///   node((2,1), $z$),
  ///   node((2,2), colspan: -2, $y z$)
  /// )
  /// ```)
  ///
  /// See also @node-rowspan and @node-enclose.
  /// -> number | none
  colspan: none,
  /// Row span of the node's @node-cells[flexigrid cell].
  ///
  /// Analogous to @node-colspan.
  /// -> number
  rowspan: none,

  /// Whether to return a `metadata` object which can be placed inside equations,
  /// instead of returning an array of functions which can be inserted into a CeTZ canvas.
  ///
  /// If you often use fletcher in math mode, consider defining a shortcut:
  /// ```typ
  /// #let hom = edge.with(in-math: true)
  /// #let obj = node.with(in-math: true)
  /// ```
  /// Now, `hom` edges and `obj` nodes can be inserted into equations, like so:
  /// ```typ
  /// #diagram($x hom(|->) & obj(pi(x), stroke: #yellow)$)
  /// ```
  ///
  /// See also @edge-in-math.
  /// -> bool
  in-math: false,

  /// Enable debug annotations for only this node.
  /// See @debug.node.
  ///
  /// If `auto`, the debug setting is inherited from the enclosing @diagram or @flexigrid.
  debug: auto,
) = {
  let style = (
    fill: fill,
    stroke: stroke,
    inset: inset,
    outset: outset,
    extrude: extrude,
    layer: layer,
  )
    .pairs()
    .filter(((k, v)) => v != auto)
    .to-dict()
  style += args.named()

  let options = (
    body: body,
    shape: shape,
    name: name,
    align: align,
    weight: weight,
    enclose: enclose,
    snap: snap,
    style: style,
    cellspan: (colspan, rowspan),
    debug: debug,
  )

  let pos = args.pos()
  options += parsing.interpret-node-positional-args(pos, options)

  if options.name != none { options.name = str(options.name) }

  if options.enclose != none { options.enclose = utils.one-or-array(options.enclose) }

  if in-math {
    options.body = math.equation(options.body)
    metadata((fletcher: "node", args: options))
  } else {
    _node(..options)
  }
}
