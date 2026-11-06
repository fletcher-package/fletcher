#import "deps.typ": cetz
#import cetz.util
#import cetz.util.bezier: _cubic-roots, cubic-point

// much of this code is copied from cetz's path-util and bezier source files.
// intersection functions by the same name are augmented here
// to return the intersection points along with their corresponding index/t parameters
// along the line, curve or path given as the *second* argument


/// Identical to `cetz.intersection.line-line` but returns
/// a pair `(pt, t)` with the point and the parameter value `t`
/// of the point `pt` along the line segment from `p3` to `p4`.
#let line-line(p1, p2, p3, p4, ray: false, eps: 1e-6) = {
  let (x1, y1, z1, ..) = if p1.len() >= 3 { p1 } else { (..p1, 0) }
  let (x2, y2, z2, ..) = if p2.len() >= 3 { p2 } else { (..p2, 0) }
  let (x3, y3, z3, ..) = if p3.len() >= 3 { p3 } else { (..p3, 0) }
  let (x4, y4, z4, ..) = if p4.len() >= 3 { p4 } else { (..p4, 0) }

  let p13 = (x1 - x3, y1 - y3, z1 - z3)
  let p21 = (x2 - x1, y2 - y1, z2 - z1)
  let p43 = (x4 - x3, y4 - y3, z4 - z3)

  let d-21-21 = cetz.vector.dot(p21, p21)
  let d-43-43 = cetz.vector.dot(p43, p43)
  if d-21-21 <= calc.pow(eps, 2) or d-43-43 <= calc.pow(eps, 2) {
    return none
  }

  let d-43-21 = cetz.vector.dot(p43, p21)
  let d-13-43 = cetz.vector.dot(p13, p43)
  let d-13-21 = cetz.vector.dot(p13, p21)
  let d = d-21-21 * d-43-43 - d-43-21 * d-43-21
  let parallel-eps = calc.pow(eps, 2) * d-21-21 * d-43-43
  if calc.abs(d) <= parallel-eps {
    return none
  }

  let m-a = (d-13-43 * d-43-21 - d-13-21 * d-43-43) / d
  let m-b = (d-13-43 + m-a * d-43-21) / d-43-43

  if not ray and (m-a < -eps or m-a > 1 + eps or m-b < -eps or m-b > 1 + eps) {
    return none
  }

  let m-a = if ray { m-a } else { calc.clamp(m-a, 0, 1) }
  let m-b = if ray { m-b } else { calc.clamp(m-b, 0, 1) }

  let a = (x1 + m-a * (x2 - x1), y1 + m-a * (y2 - y1), z1 + m-a * (z2 - z1))
  let b = (x3 + m-b * (x4 - x3), y3 + m-b * (y4 - y3), z3 + m-b * (z4 - z3))
  let d-ab = cetz.vector.dist(a, b)
  let distance-eps = eps * calc.max(1, calc.sqrt(d-21-21), calc.sqrt(d-43-43))

  return if d-ab <= distance-eps {
    (a, m-b)
  } else {
    none
  }
}

/// Identical to `cetz.intersection.line-cubic` but returns
/// an array of pairs `(pt, t)` of points and their t parameter
/// along the cubic bezier curve.
#let line-cubic(la, lb, s, e, c1, c2, ray: false) = {
  // Based on:
  //   http://www.particleincell.com/blog/2013/cubic-line-intersection/
  // with some rounding improvements
  let a = lb.at(1) - la.at(1)
  let b = la.at(0) - lb.at(0)
  let c = la.at(0) * (la.at(1) - lb.at(1)) + la.at(1) * (lb.at(0) - la.at(0))

  /// Get cubic bezier function coefficients
  let _cubic-coeff(a, b, c, d) = (
    -a + 3*b - 3*c + d,
    3*a - 6*b + 3*c,
    -3*a +3*b,
    a)

  let x-coeff = _cubic-coeff(s.at(0), c1.at(0), c2.at(0), e.at(0))
  let y-coeff = _cubic-coeff(s.at(1), c1.at(1), c2.at(1), e.at(1))

  let roots = _cubic-roots(a * x-coeff.at(0) + b * y-coeff.at(0),
                           a * x-coeff.at(1) + b * y-coeff.at(1),
                           a * x-coeff.at(2) + b * y-coeff.at(2),
                           a * x-coeff.at(3) + b * y-coeff.at(3) + c)

  let pts = ()
  for t in roots {
    let pt = cubic-point(s, e, c1, c2, t)
    if ray {
      pts.push((pt, t))
    } else {
      let s = if calc.abs(lb.at(0) - la.at(0)) >= 1e-6 {
        (pt.at(0) - la.at(0)) / (lb.at(0) - la.at(0))
      } else {
        (pt.at(1) - la.at(1)) / (lb.at(1) - la.at(1))
      }
      if s >= 0 and s <= 1 {
        pts.push((pt, t))
      }
    }
  }
  return pts
}


/// Identical to `cetz.intersection.line-path` but returns
/// an array of pairs `(pt, (subpath-i, segment-i, t))` of each
/// intersection point and its index/parameter along the path.
#let line-path(la, lb, path) = {
  let pts = ()

  for (subpath-i, (start, closed, segments)) in path.at("segments", default: ()).enumerate() {
    let origin = start
    for (segment-i, (kind, ..args)) in segments.enumerate() {
      if kind == "l" {
        let pt_t = line-line(la, lb, origin, args.last())
        if pt_t != none {
          let (pt, t) = pt_t
          pts.push((pt, (subpath-i, segment-i, t)))
        }
      } else if kind == "c" {
        let (c1, c2, e) = args
        pts += line-cubic(la, lb, origin, e, c1, c2)
          .map(((pt, t)) => (pt, (subpath-i, segment-i, t)))
      }

      origin = args.last()
    }

    if closed {
      let pt_t = line-line(la, lb, origin, start)
      if pt_t != none {
        let (pt, t) = pt_t
        pts.push((pt, (subpath-i, segment-i, t)))
      }
    }
  }

  return pts
}

/// Identical to `cetz.intersection.path-path` but returns
/// an array of pairs `(pt, (subpath-i, segment-i, t))` of each
/// intersection point and its index/parameter along the *second* path.
#let path-path(a, b, samples: 8) = {
  let pts = ()

  for ((start, closed, segments)) in a.at("segments", default: ()) {
    let origin = start
    for ((kind, ..args)) in segments {
      if kind == "l" {
        pts += line-path(origin, args.last(), b)
      } else if kind == "c" {
        let (c1, c2, e) = args
        let line-strip = range(samples + 1).map(t => {
          cubic-point(origin, e, c1, c2, t / samples)
        })

        for i in range(1, line-strip.len()) {
          pts += line-path(line-strip.at(i - 1), line-strip.at(i), b)
        }
      }

      origin = args.last()
    }

    if closed {
      pts += line-path(origin, start, b)
    }
  }
  return pts
}
