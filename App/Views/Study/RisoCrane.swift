import SwiftUI

/// A paper crane printed in three inks. Each facet is shaded as if lit from the upper right, and
/// each ink is its own plate with its own screen angle, laid over the others a hair out of
/// register. Navy line work holds the folds.
struct RisoCrane: View {
  var body: some View {
    ZStack {
      plate(Self.mustard)
        .risoPlate(RisoInk.mustard, angle: .degrees(0), pitch: 2.9, seed: 3)
      plate(Self.vermilion)
        .risoPlate(RisoInk.vermilion, angle: .degrees(15), pitch: 2.9, seed: 5)
        .offset(x: -0.9, y: 0.5)
      plate(Self.navy)
        .risoPlate(RisoInk.navy, angle: .degrees(45), pitch: 2.9, seed: 7)
        .offset(x: 0.5, y: -0.4)
      Canvas { context, size in
        let transform = Self.transform(in: size)
        var folds = Path()
        for facet in [Self.farWing, Self.nearWing, Self.flankLeft, Self.flankRight, Self.neck, Self.head, Self.tail] {
          folds.addLines(facet.map { $0.applying(transform) })
          folds.closeSubpath()
        }
        context.stroke(folds, with: .color(RisoInk.navy.opacity(0.85)), style: StrokeStyle(lineWidth: 0.7, lineJoin: .round))
      }
      .risoInk(seed: 9)
    }
    .aspectRatio(Self.box.width / Self.box.height, contentMode: .fit)
    .accessibilityHidden(true)
  }

  /// One ink's share of the crane, drawn as tone: each facet darkens away from the light.
  private func plate(_ facets: [Facet]) -> some View {
    Canvas { context, size in
      let transform = Self.transform(in: size)
      for facet in facets {
        let points = facet.points.map { $0.applying(transform) }
        let shape = Path { path in
          path.addLines(points)
          path.closeSubpath()
        }
        let bounds = shape.boundingRect
        context.fill(
          shape,
          with: .linearGradient(
            Gradient(colors: [.black.opacity(facet.tone * 0.55), .black.opacity(min(facet.tone * 1.25, 1))]),
            startPoint: CGPoint(x: bounds.maxX, y: bounds.minY),
            endPoint: CGPoint(x: bounds.minX, y: bounds.maxY)
          )
        )
      }
      for (width, tone) in [(66.0, 0.06), (50.0, 0.12), (32.0, 0.22)] where facets.contains(where: \.isShadowPlate) {
        let rect = CGRect(x: 104 - width, y: 126 - width * 0.1, width: width * 2, height: width * 0.2)
        context.fill(Path(ellipseIn: rect).applying(transform), with: .color(.black.opacity(tone)))
      }
    }
  }

  private struct Facet {
    var points: [CGPoint]
    var tone: Double
    var isShadowPlate = false
  }

  private static let box = CGSize(width: 200, height: 140)

  private static func transform(in size: CGSize) -> CGAffineTransform {
    let scale = min(size.width / box.width, size.height / box.height)
    return CGAffineTransform(translationX: (size.width - box.width * scale) / 2, y: (size.height - box.height * scale) / 2)
      .scaledBy(x: scale, y: scale)
  }

  // The crane in profile: two broad wings raised over a folded body, the neck and head to the
  // left, the tail to the right.
  private static let belly = [CGPoint(x: 64, y: 98), CGPoint(x: 100, y: 82), CGPoint(x: 140, y: 98), CGPoint(x: 100, y: 116)]
  private static let farWing = [CGPoint(x: 78, y: 92), CGPoint(x: 114, y: 86), CGPoint(x: 58, y: 14)]
  private static let nearWing = [CGPoint(x: 84, y: 94), CGPoint(x: 128, y: 94), CGPoint(x: 150, y: 6)]
  private static let flankLeft = [CGPoint(x: 64, y: 98), CGPoint(x: 100, y: 98), CGPoint(x: 100, y: 116)]
  private static let flankRight = [CGPoint(x: 100, y: 98), CGPoint(x: 140, y: 98), CGPoint(x: 100, y: 116)]
  private static let neck = [CGPoint(x: 64, y: 98), CGPoint(x: 80, y: 96), CGPoint(x: 26, y: 38)]
  private static let head = [CGPoint(x: 26, y: 38), CGPoint(x: 34, y: 42), CGPoint(x: 12, y: 52)]
  private static let tail = [CGPoint(x: 140, y: 98), CGPoint(x: 124, y: 96), CGPoint(x: 188, y: 40)]

  private static let mustard = [
    Facet(points: nearWing, tone: 0.55),
    Facet(points: flankRight, tone: 0.8),
    Facet(points: tail, tone: 0.5),
  ]
  private static let vermilion = [
    Facet(points: nearWing, tone: 0.75),
    Facet(points: belly, tone: 0.2),
    Facet(points: head, tone: 1),
    Facet(points: tail, tone: 0.3),
  ]
  private static let navy = [
    Facet(points: farWing, tone: 0.55, isShadowPlate: true),
    Facet(points: flankLeft, tone: 0.6),
    Facet(points: neck, tone: 0.45),
    Facet(points: flankRight, tone: 0.12),
  ]
}
